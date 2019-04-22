//
//  LocalDeviceListViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 26/04/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import SVProgressHUD
import CocoaAsyncSocket
import SwiftyJSON
import Zip

class LocalDeviceListViewController: BaseTableViewController {
    
    var deviceList: NSMutableArray = NSMutableArray()
    var pageInfo = PageInfo()
    var loadingData = true
    
    var timer: Timer!
    
    var broadcastAddress: String?
//    var socket:GCDAsyncUdpSocket!
//    var socketReceive:GCDAsyncUdpSocket!
//    var error : NSError?
    
    // input data
    var instantMessage = InstantMessage()
    var presentationId: String = "" // for DeviceListType -> presentationId
    var folderName: String = "" // for DeviceListType -> folderName
    var currentDeviceListType: DeviceListType = .unknown
    
    // for Send PlayList
    var playList: PlayList = PlayList()
    
    // for Send RealTimeSchedule
    var realTimeSchedule: RealTimeSchedule = RealTimeSchedule()
    
    // for Send WeeklySchedule
    var weeklySchedule: WeeklySchedule = WeeklySchedule()
    
    // Common
    var currentDownloadPresentationIndex = 0
    var currentUploadPresentationIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl?.addTarget(self,
                                       action: #selector(handleRefresh(refreshControl:)),
                                       for: UIControlEvents.valueChanged)
        
        // register all cells
        self.tableView.register(UINib(nibName: "LocalDeviceListCell", bundle: nil), forCellReuseIdentifier: "LocalDeviceListCell")
        
        // init navigation bar
        initNavigationBar()
        
        if Utility.isInternetAvailable() {
            // load data
            loadMoreData()
        } else {
            getLocalDeviceList()
            self.tableView.reloadData()
        }
        
        // set up broadcast data to local addresses
        let netInfo = Utility.getIFAddresses()
        let netInfoHelper = NetInfoHelper(ip: netInfo.first!.ip, netmask: netInfo.first!.netmask)
        broadcastAddress = netInfoHelper.broadcast
        
        // start timer to send broadcast data each "sendBroadcastDelayTime"
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(Socket.sendBroadcastDelayTime),
                                     target: self,
                                     selector: #selector(sendBroadcastSocket),
                                     userInfo: nil,
                                     repeats: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // stop timer
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
        
        // close socket
//        closeSocket()
    }
    
    fileprivate func initNavigationBar() {
        self.title = localizedString(key: "device_list_local_title")
        
        // init send icon
        let sendImage = UIImage(named: "icon_send")!
        let sendButton = UIBarButtonItem(image: sendImage,  style: .plain, target: self, action: #selector(sendLocalButtonClicked(barButton:)))
        
        navigationItem.rightBarButtonItem = sendButton
    }
    
    fileprivate func isValidData() -> Bool {
        for device in (deviceList as? [Device])! {
            if device.isChoose && device.isLocalOnline {
                return true
            }
        }
        
        return false
    }
    
    fileprivate func closeSocket() {
        // close socket
//        if socket != nil {
//            socket.pauseReceiving()
//            socket.close()
//            socket = nil
//        }
        
        SocketManager.shared.socket.pauseReceiving()
    }
    
    fileprivate func boolToString(bool: Bool) -> String {
        if bool {
            return "true"
        }
        return "false"
    }
    
    fileprivate func getSendingDevice() -> Device? {
        for device in (deviceList as? [Device])! {
            if device.isChoose && device.liveStatus == "ONLINE" {
                return device
            }
        }
        return nil
    }
    
    fileprivate func getLocalDeviceList() {
        // retrieving a deviceList from UserDefault
        if let data = UserDefaults.standard.data(forKey: Network.paramDeviceList),
            let deviceList = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Device] {
            //            deviceList.forEach({print( $0.id, $0.pinCode, $0.socketId)})
            self.deviceList = deviceList as! NSMutableArray
        }
    }
    
    func sendLocalButtonClicked(barButton: UIBarButtonItem) {
        switch currentDeviceListType {
            
        case .instantMessage:
            processSendInstantMessage()
            break
            
        case .presentation:
            processPlayPresentationInLocalDevice(withPresentationId: self.presentationId)
            break
            
        case .playList:
            processSendPlayList()
            break
            
        case .weeklySchedule:
            processSendWeeklySchedule()
            break
            
        case .realTimeSchedule:
            processSendRealTimeSchedule()
            break
            
        default:
            break
        }
    }
    
    func sendBroadcastSocket() {
        let deviceType = Socket.deviceType.base64Encoded()
        let packageType = Socket.packageType.base64Encoded()
        
        let dataString = Socket.socketPrefix + Socket.socketSeparator + deviceType! + Socket.socketSeparator + packageType!
        let message = dataString.data(using: String.Encoding.utf8)
        
//        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        SocketManager.shared.socket.setDelegate(self)
        
        SocketManager.shared.socket.send(message!,
                                         toHost: broadcastAddress!,
                                         port: UInt16(Socket.port),
                                         withTimeout: TimeInterval(Socket.timeout),
                                         tag: 0)
        
        do {
            try SocketManager.shared.socket.enableReusePort(true)
            try SocketManager.shared.socket.bind(toPort: UInt16(Socket.port))
            try SocketManager.shared.socket.enableBroadcast(true)
            try SocketManager.shared.socket.beginReceiving()
        } catch {
            dLog(message: error.localizedDescription)
        }
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        // reset all data
        deviceList.removeAllObjects()
        pageInfo = PageInfo()
        
        // call API get data
        loadMoreData()
    }
    
    fileprivate func unChooseAllDevice() {
        for device in (deviceList as? [Device])! {
            device.isChoose = false
        }
    }
    
    fileprivate func loadMoreData() {
        if pageInfo.hasNext {
            loadingData = true
            
            // show loading
            SVProgressHUD.show()
            
            NetworkManager.shared.getDeviceList(token: Utility.getToken(),
                                                sort: "-liveStatus",
                                                page: pageInfo.current + 1,
                                                perPage: Network.perPage,
                                                filter: "") {
                                                    (success, deviceList, pageInfo, message) in
                                                    
                                                    weak var weakSelf = self
                                                    
                                                    weakSelf?.refreshControl?.endRefreshing()
                                                    
                                                    // remove loading
                                                    SVProgressHUD.dismiss()
                                                    
                                                    if (success) {
                                                        weakSelf?.deviceList.addObjects(from: deviceList!)
      
                                                        weakSelf?.pageInfo = pageInfo!
                                                        weakSelf?.tableView.reloadData()
                                                        
                                                    } else {
                                                        // show error message
                                                        Utility.showAlertWithErrorMessage(message: message, controller: self, completion: nil)
                                                    }
                                                    
                                                    weakSelf?.loadingData = false
            }
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension LocalDeviceListViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (deviceList.count)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "LocalDeviceListCell") as? LocalDeviceListCell
        
        if cell == nil {
            cell = (Bundle.main.loadNibNamed("LocalDeviceListCell", owner: self, options: nil)?.first as? LocalDeviceListCell)!
        }
        if deviceList.count > 0 {
            cell?.initViewWithDeviceData(device: (deviceList[indexPath.row] as! Device))
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = (deviceList.count) - 1
        if indexPath.row == lastElement && loadingData == false {
            loadMoreData()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        unChooseAllDevice()
        
        let device = deviceList[indexPath.row] as! Device
        device.isChoose = true
        
        tableView.reloadData()
    }
}

// MARK: - GCDAsyncUdpSocketDelegate

// handle all socket events
extension LocalDeviceListViewController: GCDAsyncUdpSocketDelegate {
    func udpSocket(_ sock: GCDAsyncUdpSocket, didConnectToAddress address: Data) {
        //        dLog(message: "didConnectToAddress")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotConnect error: Error?) {
        //        dLog(message: "didNotConnect \(String(describing: error))")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
        //        dLog(message: "didSendDataWithTag")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotSendDataWithTag tag: Int, dueToError error: Error?) {
        //        dLog(message: "didNotSendDataWithTag")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        //        dLog(message: "didReceiveData")
        
        var host: NSString?
        var port1: UInt16 = 0
        GCDAsyncUdpSocket.getHost(&host, port: &port1, fromAddress: address)
        
        //        dLog(message: "From \(host!)")
        
        let gotData: NSString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
        print(gotData)
        let device = parseResponseData(data: gotData as String, host: host! as String)
        if device != nil {
            didReceiveResponseFromDevice(localDevice: device!)
        }
    }
    
    fileprivate func didReceiveResponseFromDevice(localDevice: Device) {
        var isShouldRefresh = false
        var index = 0
        
        for device in deviceList as! [Device] {
            if device.pinCode == localDevice.pinCode {
                if device.isLocalOnline == false {
                    device.isLocalOnline = true
                    device.ipAddress = localDevice.ipAddress
                    isShouldRefresh = true
                    
                    //                    self.deviceList.replaceObject(at: index, with: device)
                    dLog(message: "found local device with pinCode = " + device.pinCode)
                }
            }
            index += 1
        }
        
        if isShouldRefresh && loadingData == false {
            dLog(message: "reload table")
            
            // reload data
            self.tableView.reloadData()
        }
    }
    
    fileprivate func parseResponseData(data: String?, host: String) -> Device? {
        if data != nil && (data?.hasPrefix(Socket.socketPrefix))! {
            let parts = data?.components(separatedBy: Socket.socketSeparator)
            if parts?.count == 7 {
                let device = Device()
                device.ipAddress = host
                device.name = (parts?[1])!
                device.pinCode = (parts?[2])!
                device.softwareVersion = (parts?[3])!
                device.displayWidth = Int((parts?[4])!)!
                device.displayHeight = Int((parts?[5])!)!
                
                let liveStatus = Int((parts?[6])!)
                if liveStatus == 0 {
                    device.liveStatus = "OFFLINE"
                } else {
                    device.liveStatus = "ONLINE"
                }
                return device
            }
        }
        
        return nil
    }
}

// MARK: - process send Instant Message

extension LocalDeviceListViewController {
    
    fileprivate func processSendInstantMessage() {
        if !isValidData() {
            Utility.showAlertWithErrorMessage(message: localizedString(key: "im_error_choose_device_offline"),
                                              controller: self,
                                              completion: nil)
            return
        }
        
        guard let sendingDevice = getSendingDevice() else {
            dLog(message: "can't get sending device")
            return
        }
        
        // show loading
        SVProgressHUD.show(withStatus: localizedString(key: "common_sending"))
        
        NetworkManager.shared.playLocalInstantMessage(pinCode: sendingDevice.pinCode,
                                                      clientAddress: sendingDevice.ipAddress,
                                                      duration: String(instantMessage.duration),
                                                      position: instantMessage.position,
                                                      imMessage: instantMessage.message,
                                                      isTTS: boolToString(bool: instantMessage.isTTS),
                                                      ttsMessage: instantMessage.ttsMsg,
                                                      color: instantMessage.fontColor,
//                                                      animationEffect: String(instantMessage.animationEffect),
                                                      animationEffect: "",
                                                      fontName: instantMessage.fontName,
                                                      fontSize: String(instantMessage.fontSize),
//                                                      topPosition: String(instantMessage.customTopPosition),
                                                      topPosition: "",
//                                                      leftPosition: String(instantMessage.customLeftPosition),
                                                      leftPosition: "",
                                                      bold: boolToString(bool:instantMessage.isBold),
                                                      italic: boolToString(bool:instantMessage.isItalic)) {
                                                        (success, message) in
                                                        
                                                        // remove loading
                                                        SVProgressHUD.dismiss()
                                                        
                                                        weak var weakSelf = self
                                                        
                                                        if (success) {
                                                            Utility.showAlertWithSuccessMessage(message: message, controller: weakSelf!, completion: {
                                                                
                                                                //                                                                weakSelf?.navigationController?.popViewController(animated: true)
                                                            })
                                                            
                                                        } else {
                                                            // show error message
                                                            Utility.showAlertWithErrorMessage(message: message, controller: weakSelf!, completion: nil)
                                                        }
                                                        
        }
    }
}

// MARK: - Process send Presentation

extension LocalDeviceListViewController {
    
    fileprivate func getPresentationFolderPath(presentationId: String) -> URL {
        return Utility.getUrlFromDocumentWithAppend(url: Dir.savePresentation + presentationId)
    }
    
    fileprivate func getDesignFile(withPresentationId presentationId: String) -> URL {
        return getPresentationFolderPath(presentationId: presentationId).appendingPathComponent(presentationId + Dir.presentationDesignExtension)
    }
    
    fileprivate func processPlayPresentationInLocalDevice(withPresentationId presentationId: String) {
        if !isValidData() {
            Utility.showAlertWithErrorMessage(message: localizedString(key: "im_error_empty_device"), controller: self, completion: nil)
            return
        }
        
        // show loading indicator
        SVProgressHUD.show(withStatus: localizedString(key: "common_sending"))
        
        processUploadPresentationToLocalDevice(withPresentationId: presentationId) {
            (success, message) in
            
            weak var weakSelf = self

            if success {
                // get selected device
                guard let sendingDevice = weakSelf?.getSendingDevice() else {
                    SVProgressHUD.dismiss()
                    Utility.showAlertWithErrorMessage(message: message, controller: weakSelf!)
                    return
                }
                
                // call API to make display presentation on device
                NetworkManager.shared.playLocalPresentation(pinCode: sendingDevice.pinCode, clientAddress: sendingDevice.ipAddress, presentationId: (weakSelf?.presentationId)!, completion: {
                    (success, message) in
                    
                    weak var weakSelf = self
                    
                    SVProgressHUD.dismiss()
                    
                    if success {
                        SVProgressHUD.showSuccess(withStatus: localizedString(key: "common_sent"))
                    } else {
                        Utility.showAlertWithErrorMessage(message: message, controller: weakSelf!)
                    }
                })
            } else {
                SVProgressHUD.dismiss()
                Utility.showAlertWithErrorMessage(message: message, controller: weakSelf!)
            }
        }
    }
    
    fileprivate func processUploadPresentationToLocalDevice(withPresentationId presentationId: String, completion: @escaping (Bool, String) -> Void) {
        guard let tmpPresentation = DesignFileHelper.getPresentationFromDesignFile(fileURL: getDesignFile(withPresentationId: presentationId)) else {
            dLog(message: "can't load presentation design file from path \(getDesignFile(withPresentationId: presentationId))")
            completion(false, localizedString(key: "common_error_message"))
            return
        }
        
        // get selected device
        guard let sendingDevice = getSendingDevice() else {
            dLog(message: "can't get sending device")
            completion(false, localizedString(key: "common_error_message"))
            return
        }
        
        // assetList is empty, so don't need to check it exist or not in local server
        if tmpPresentation.assetList.count == 0 {
            self.processUploadPresentationZipFolder(presentationId: presentationId,
                                                    dataList: nil,
                                                    sendingDevice: sendingDevice,
                                                    completion: completion)
            return
        }
        
        // generate md5List
        let dataList = NSMutableArray.init()
        for asset in tmpPresentation.assetList {
            let dict = Dictionary.init(dictionaryLiteral: ("fileName", asset.id + asset.ext), ("md5", asset.md5))
            dataList.add(dict)
        }
        
        // generate string of JSON array from Array
        var encodedString = ""
        do {
            let data = try JSONSerialization.data(withJSONObject: dataList, options: JSONSerialization.WritingOptions())
            let jsonString = String(data: data, encoding: .utf8)!
            encodedString = jsonString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        } catch {
            dLog(message: error.localizedDescription)
        }
        
        // call API check asset already exist on device
        NetworkManager.shared.checkLocalAssetExist(pinCode: sendingDevice.pinCode, clientAddress: sendingDevice.ipAddress, presentationId: presentationId, data: encodedString) {
            (success, dataList, message) in
            
            weak var weakSelf = self
            
            if success {
                weakSelf?.processUploadPresentationZipFolder(presentationId: presentationId,
                                                   dataList: dataList,
                                                   sendingDevice: sendingDevice,
                                                   completion: completion)
            } else {
                completion(false, message)
            }
        }
    }
    
    fileprivate func processUploadPresentationZipFolder(presentationId: String, dataList: [[String: Any]]?, sendingDevice: Device, completion: @escaping (Bool, String) -> Void) {
        // zip all assets not exist, design file and thumbnail and send to device
        guard let zipFileURL = self.processCreateZipFile(presentationId: presentationId, dataList: dataList) else {
            completion(false, localizedString(key: "common_error_message"))
            return
        }
        
        // call API send to device
        do {
            let zipData = try Data.init(contentsOf: zipFileURL)
            NetworkManager.shared.uploadZipFolderToDevice(clientAddress: sendingDevice.ipAddress, contentId: presentationId, zipFileName: (presentationId + ".zip"), zipData: zipData, completion: { (success, message) in
                
                weak var weakSelf = self
                
                if success {
                    // remove zip file & folder
                    do {
                        try FileManager.default.removeItem(at: zipFileURL)
                        try FileManager.default.removeItem(at: (weakSelf?.getPresentationFolderPath(presentationId: presentationId).appendingPathComponent(Dir.forZipFolderName))!)
                    } catch {
                        dLog(message: error.localizedDescription)
                        completion(false, localizedString(key: "common_error_message"))
                        return
                    }
                    
                    completion(true, "")
                } else {
                    completion(false, message)
                    return
                }
            })
        } catch {
            dLog(message: error.localizedDescription)
            completion(false, localizedString(key: "common_error_message"))
        }
    }
    
    fileprivate func processCreateZipFile(presentationId: String, dataList: [[String: Any]]?) -> URL? {
        // create "ForZip" folder to contain all assets + design file + thumbnail
        let folderToZipURL = getPresentationFolderPath(presentationId: presentationId).appendingPathComponent(Dir.forZipFolderName)
        DesignFileHelper.createNewFolder(folderUrl: folderToZipURL)
        
        // copy all missing assets to that folder
        if dataList != nil && (dataList?.count)! > 0 {
            for dataDict in dataList! {
                guard let fileName = dataDict["fileName"] as? String, let status = dataDict["status"] as? String else {
                    continue
                }
                if status == "1" {
                    let copyFileFromURL = getPresentationFolderPath(presentationId: presentationId).appendingPathComponent(fileName)
                    let toURL = folderToZipURL.appendingPathComponent(fileName)
                    if FileManager.default.fileExists(atPath: copyFileFromURL.path) {
                        DesignFileHelper.copyFile(fromPath: copyFileFromURL, toPath: toURL)
                    }
                }
            }
        }
        
        // copy design file to that folder
        let desPresentationDesignFileURL = folderToZipURL.appendingPathComponent(presentationId + Dir.presentationDesignExtension)
        if FileManager.default.fileExists(atPath: getDesignFile(withPresentationId: presentationId).path) {
            DesignFileHelper.copyFile(fromPath: getDesignFile(withPresentationId: presentationId), toPath: desPresentationDesignFileURL)
        } else {
            dLog(message: "design file not exist at path \(getDesignFile(withPresentationId: presentationId))")
            return nil
        }
        
        // copy thumbnail to that folder and change name to localPresentationId.png
        let presentationThumbnailURL = getPresentationFolderPath(presentationId: presentationId).appendingPathComponent(presentationId + Dir.presentationThumbnailExtension)
        if FileManager.default.fileExists(atPath: presentationThumbnailURL.path) {
            let desPresentationThumbnailURL = folderToZipURL.appendingPathComponent(presentationId + Dir.presentationThumbnailExtension)
            DesignFileHelper.copyFile(fromPath: presentationThumbnailURL, toPath: desPresentationThumbnailURL)
        } else {
            dLog(message: "presentation thumbnail not exist at path \(presentationThumbnailURL.path)")
            return nil
        }
        
        // zip all files on that folder
        do {
            let fileNameList = FileManager.default.enumerator(atPath: folderToZipURL.path)
            let fileUrlList = NSMutableArray.init()
            while let fileName = fileNameList?.nextObject() as? String {
                fileUrlList.add(URL.init(fileURLWithPath: folderToZipURL.path + "/" + fileName))
            }
            return try Zip.quickZipFiles(fileUrlList as! [URL], fileName: presentationId)
        } catch {
            dLog(message: error.localizedDescription)
        }
        
        return nil
    }
}

// MARK: - process send PlayList

extension LocalDeviceListViewController {
    
    fileprivate func processSendPlayList() {
        // user must choose a device before run this action
        if !isValidData() {
            Utility.showAlertWithErrorMessage(message: localizedString(key: "im_error_empty_device"), controller: self, completion: nil)
            return
        }
        
        SVProgressHUD.show(withStatus: localizedString(key: "common_sending"))

        // download all presentations which is not exist in local
        currentDownloadPresentationIndex = 0
        processDownloadAllPresentationInPlayList()
    }
    
    fileprivate func processDownloadAllPresentationInPlayList() {
        if playList.displayList.count == 0 {
            // download done -> process next step
            // for each presentation -> zip presentation folder -> send zip folder to local displayer
            currentUploadPresentationIndex = 0
            processZipAllPresentationAndSendToLocalServer()
            
        } else {
            if currentDownloadPresentationIndex < playList.displayList.count {
                let playListPresentation = playList.displayList[currentDownloadPresentationIndex]
                
                // Has presentation existed in local?
                let presentationURL = Utility.getUrlFromDocumentWithAppend(url: Dir.savePresentation + playListPresentation.presentation)
                if FileManager.default.fileExists(atPath: presentationURL.path) {
                    // process download next presentation
                    currentDownloadPresentationIndex += 1
                    processDownloadAllPresentationInPlayList()
                } else {
                    // process download presentation
                    let downloadPresentationHelper = DownloadPresentationHelper.init(presentationId: playListPresentation.presentation, controller: self)
                    downloadPresentationHelper.completionHandler = {
                        (success, message) in
                        
                        weak var weakSelf = self
                        
                        dLog(message: "playlist -> download presentation done with id = \(playListPresentation.presentation)")

                        if success {
                            // download presentation successful -> save data info to templateSlide.json file
                            TemplateSlide.processSaveNewPresentation(presentationId: playListPresentation.presentation, completion: {
                                (success) in
                                
                                weak var weakSelf = self

                                if !success {
                                    SVProgressHUD.dismiss()
                                    Utility.showAlertWithErrorMessage(message: localizedString(key: "common_error"), controller: weakSelf!)
                                    return
                                }
                            })
                            
                            // download next presentation
                            weakSelf?.currentDownloadPresentationIndex += 1
                            weakSelf?.processDownloadAllPresentationInPlayList()
                        } else {
                            SVProgressHUD.dismiss()
                            Utility.showAlertWithErrorMessage(message: message, controller: weakSelf!)
                        }
                    }
                    downloadPresentationHelper.processDownloadPresentation()
                }
            } else {
                // download done -> process next step
                // for each presentation -> zip presentation folder -> send zip folder to local displayer
                currentUploadPresentationIndex = 0
                processZipAllPresentationAndSendToLocalServer()
            }
        }
    }
    
    fileprivate func processZipAllPresentationAndSendToLocalServer() {
        if playList.displayList.count == 0 {
            // upload done -> next step
            // create file "playListId.evpl" -> zip it -> send it to local displayer
            processSendPlayListDesignFileToLocalServer()
        } else {
            if currentUploadPresentationIndex < playList.displayList.count {
                let playListPresentation = playList.displayList[currentUploadPresentationIndex]
                processUploadPresentationToLocalDevice(withPresentationId: playListPresentation.presentation, completion: {
                    (success, message) in
                    
                    weak var weakSelf = self
                    
                    dLog(message: "playlist -> send zip done with presentation id = \(playListPresentation.presentation)")

                    if success {
                        // upload next presentation
                        weakSelf?.currentUploadPresentationIndex += 1
                        weakSelf?.processZipAllPresentationAndSendToLocalServer()
                    } else {
                        SVProgressHUD.dismiss()
                        Utility.showAlertWithErrorMessage(message: message, controller: weakSelf!)
                    }
                })
            } else {
                // upload done -> next step
                // create file "playListId.evpl" -> zip it -> send it to local displayer
                processSendPlayListDesignFileToLocalServer()
            }
        }
    }
    
    fileprivate func processSendPlayListDesignFileToLocalServer() {
        // create file "playListId.evpl"
        let playListDesignFileURL = Utility.getUrlFromDocumentWithAppend(url: playList.id + Dir.playListDesignExtension)
        do {
            let rawData = playList.toJsonData()
            try rawData.write(to: playListDesignFileURL, options: .atomic)
        } catch {
            SVProgressHUD.dismiss()
            Utility.showAlertWithErrorMessage(message: localizedString(key: "common_error_message"), controller: self)
            dLog(message: error.localizedDescription)
            return
        }
        
        // zip it
        var zipFileURL: URL?
        do {
            zipFileURL = try Zip.quickZipFiles([playListDesignFileURL], fileName: playList.id)
        } catch {
            SVProgressHUD.dismiss()
            Utility.showAlertWithErrorMessage(message: localizedString(key: "common_error_message"), controller: self)
            dLog(message: error.localizedDescription)
            return
        }
        
        // get selected device
        guard let sendingDevice = getSendingDevice() else {
            dLog(message: "can't get sending device")
            SVProgressHUD.dismiss()
            Utility.showAlertWithErrorMessage(message: localizedString(key: "common_error_message"), controller: self)
            return
        }
        
        do {
            let zipData = try Data.init(contentsOf: zipFileURL!)
            // send it to local displayer
            NetworkManager.shared.uploadZipFolderToDevice(clientAddress: sendingDevice.ipAddress, contentId: playList.id, zipFileName: (playList.id + ".zip"), zipData: zipData, completion: {
                (success, message) in
                
                weak var weakSelf = self
                
                dLog(message: "playlist -> send zip design file with zip file url = \(String(describing: zipFileURL?.path))")

                // remove zip file
                do {
                    try FileManager.default.removeItem(at: playListDesignFileURL)
                    try FileManager.default.removeItem(at: zipFileURL!)
                } catch {
                    SVProgressHUD.dismiss()
                    Utility.showAlertWithErrorMessage(message: localizedString(key: "common_error_message"), controller: weakSelf!)
                    dLog(message: error.localizedDescription)
                    return
                }

                if success {
                    // cal API play PlayList
                    weakSelf?.processCallAPItoPLayPlayList(sendingDevice: sendingDevice)
                } else {
                    SVProgressHUD.dismiss()
                    Utility.showAlertWithErrorMessage(message: message, controller: weakSelf!)
                }
            })
        } catch {
            dLog(message: error.localizedDescription)
            SVProgressHUD.dismiss()
            Utility.showAlertWithErrorMessage(message: localizedString(key: "common_error_message"), controller: self)
        }
    }
    
    fileprivate func processCallAPItoPLayPlayList(sendingDevice: Device) {
        NetworkManager.shared.playLocalPlayList(pinCode: sendingDevice.pinCode, clientAddress: sendingDevice.ipAddress, playListId: playList.id) {
            (success, message) in
            
            weak var weakSelf = self

            SVProgressHUD.dismiss()
            
            dLog(message: "playlist -> call api display playlist done")

            if success {
                SVProgressHUD.showSuccess(withStatus: localizedString(key: "common_sent"))
            } else {
                Utility.showAlertWithErrorMessage(message: message, controller: weakSelf!)
            }
        }
    }
}

// MARK: - process send RealTimeSchedule

extension LocalDeviceListViewController {
    
    fileprivate func processSendRealTimeSchedule() {
        // user must choose a device before run this action
        if !isValidData() {
            Utility.showAlertWithErrorMessage(message: localizedString(key: "im_error_empty_device"), controller: self, completion: nil)
            return
        }
        
        SVProgressHUD.show(withStatus: localizedString(key: "common_sending"))
        
        // download all presentations which is not exist in local
        currentDownloadPresentationIndex = 0
        processDownloadAllPresentationInRealTimeSchedule()
    }
    
    fileprivate func processDownloadAllPresentationInRealTimeSchedule() {
        if realTimeSchedule.displayCalendar.count == 0 {
            // download done -> process next step
            // for each presentation -> zip presentation folder -> send zip folder to local displayer
            currentUploadPresentationIndex = 0
            processZipAllPresentationAndSendToLocalServerForRealTimeSchedule()
            
        } else {
            if currentDownloadPresentationIndex < realTimeSchedule.displayCalendar.count {
                let realTimePresentation = realTimeSchedule.displayCalendar[currentDownloadPresentationIndex]
                
                // Has presentation existed in local?
                let presentationURL = Utility.getUrlFromDocumentWithAppend(url: Dir.savePresentation + realTimePresentation.presentation)
                if FileManager.default.fileExists(atPath: presentationURL.path) {
                    // process download next presentation
                    currentDownloadPresentationIndex += 1
                    processDownloadAllPresentationInRealTimeSchedule()
                } else {
                    // process download presentation
                    let downloadPresentationHelper = DownloadPresentationHelper.init(presentationId: realTimePresentation.presentation, controller: self)
                    downloadPresentationHelper.completionHandler = {
                        (success, message) in
                        
                        weak var weakSelf = self
                        
                        dLog(message: "realTimeSchedule -> download presentation done with id = \(realTimePresentation.presentation)")
                        
                        if success {
                            // download presentation successful -> save data info to templateSlide.json file
                            TemplateSlide.processSaveNewPresentation(presentationId: realTimePresentation.presentation, completion: {
                                (success) in
                                
                                weak var weakSelf = self
                                
                                if !success {
                                    SVProgressHUD.dismiss()
                                    Utility.showAlertWithErrorMessage(message: localizedString(key: "common_error"), controller: weakSelf!)
                                    return
                                }
                            })
                            
                            // download next presentation
                            weakSelf?.currentDownloadPresentationIndex += 1
                            weakSelf?.processDownloadAllPresentationInRealTimeSchedule()
                        } else {
                            SVProgressHUD.dismiss()
                            Utility.showAlertWithErrorMessage(message: message, controller: weakSelf!)
                        }
                    }
                    downloadPresentationHelper.processDownloadPresentation()
                }
            } else {
                // download done -> process next step
                // for each presentation -> zip presentation folder -> send zip folder to local displayer
                currentUploadPresentationIndex = 0
                processZipAllPresentationAndSendToLocalServerForRealTimeSchedule()
            }
        }
    }
    
    fileprivate func processZipAllPresentationAndSendToLocalServerForRealTimeSchedule() {
        if realTimeSchedule.displayCalendar.count == 0 {
            // upload done -> next step
            // create file "realTimeScheduleId.evsch" -> zip it -> send it to local displayer
            processSendRealTimeScheduleDesignFileToLocalServer()
        } else {
            if currentUploadPresentationIndex < realTimeSchedule.displayCalendar.count {
                let realTimeSchedulePresentation = realTimeSchedule.displayCalendar[currentUploadPresentationIndex]
                processUploadPresentationToLocalDevice(withPresentationId: realTimeSchedulePresentation.presentation, completion: {
                    (success, message) in
                    
                    weak var weakSelf = self
                    
                    dLog(message: "realTimeSchedule -> send zip done with presentation id = \(realTimeSchedulePresentation.presentation)")
                    
                    if success {
                        // upload next presentation
                        weakSelf?.currentUploadPresentationIndex += 1
                        weakSelf?.processZipAllPresentationAndSendToLocalServerForRealTimeSchedule()
                    } else {
                        SVProgressHUD.dismiss()
                        Utility.showAlertWithErrorMessage(message: message, controller: weakSelf!)
                    }
                })
            } else {
                // upload done -> next step
                // create file "realTimeScheduleId.evsch" -> zip it -> send it to local displayer
                processSendRealTimeScheduleDesignFileToLocalServer()
            }
        }
    }
    
    fileprivate func processSendRealTimeScheduleDesignFileToLocalServer() {
        // create file "realTimeScheduleId.evsch"
        let scheduleDesignFileURL = Utility.getUrlFromDocumentWithAppend(url: realTimeSchedule.id + Dir.scheduleDesignExtension)
        do {
            let rawData = realTimeSchedule.toJsonData()
            try rawData.write(to: scheduleDesignFileURL, options: .atomic)
        } catch {
            SVProgressHUD.dismiss()
            Utility.showAlertWithErrorMessage(message: localizedString(key: "common_error_message"), controller: self)
            dLog(message: error.localizedDescription)
            return
        }
        
        // zip it
        var zipFileURL: URL?
        do {
            zipFileURL = try Zip.quickZipFiles([scheduleDesignFileURL], fileName: realTimeSchedule.id)
        } catch {
            SVProgressHUD.dismiss()
            Utility.showAlertWithErrorMessage(message: localizedString(key: "common_error_message"), controller: self)
            dLog(message: error.localizedDescription)
            return
        }
        
        // get selected device
        guard let sendingDevice = getSendingDevice() else {
            dLog(message: "can't get sending device")
            SVProgressHUD.dismiss()
            Utility.showAlertWithErrorMessage(message: localizedString(key: "common_error_message"), controller: self)
            return
        }
        
        do {
            let zipData = try Data.init(contentsOf: zipFileURL!)
            // send it to local displayer
            NetworkManager.shared.uploadZipFolderToDevice(clientAddress: sendingDevice.ipAddress, contentId: realTimeSchedule.id, zipFileName: (realTimeSchedule.id + ".zip"), zipData: zipData, completion: {
                (success, message) in
                
                weak var weakSelf = self
                
                dLog(message: "realTimeSchedule -> send zip design file with zip file url = \(String(describing: zipFileURL?.path))")
                
                // remove zip file
                do {
                    try FileManager.default.removeItem(at: scheduleDesignFileURL)
                    try FileManager.default.removeItem(at: zipFileURL!)
                } catch {
                    SVProgressHUD.dismiss()
                    Utility.showAlertWithErrorMessage(message: localizedString(key: "common_error_message"), controller: weakSelf!)
                    dLog(message: error.localizedDescription)
                    return
                }
                
                if success {
                    // cal API play RealTimeSchedule
                    weakSelf?.processCallAPItoPLayRealTimeSchedule(sendingDevice: sendingDevice)
                } else {
                    SVProgressHUD.dismiss()
                    Utility.showAlertWithErrorMessage(message: message, controller: weakSelf!)
                }
            })
        } catch {
            dLog(message: error.localizedDescription)
            SVProgressHUD.dismiss()
            Utility.showAlertWithErrorMessage(message: localizedString(key: "common_error_message"), controller: self)
        }
    }
    
    fileprivate func processCallAPItoPLayRealTimeSchedule(sendingDevice: Device) {
        NetworkManager.shared.playLocalScheduleRealTime(pinCode: sendingDevice.pinCode, clientAddress: sendingDevice.ipAddress, scheduleId: realTimeSchedule.id) {
            (success, message) in
            
            weak var weakSelf = self
            
            SVProgressHUD.dismiss()
            
            dLog(message: "realTimeSchedule -> call api display realTimeSchedule done")
            
            if success {
                SVProgressHUD.showSuccess(withStatus: localizedString(key: "common_sent"))
            } else {
                Utility.showAlertWithErrorMessage(message: message, controller: weakSelf!)
            }
        }
    }
}

// MARK: - process send WeeklySchedule

extension LocalDeviceListViewController {
    
    fileprivate func processSendWeeklySchedule() {
        // user must choose a device before run this action
        if !isValidData() {
            Utility.showAlertWithErrorMessage(message: localizedString(key: "im_error_empty_device"), controller: self, completion: nil)
            return
        }
        
        SVProgressHUD.show(withStatus: localizedString(key: "common_sending"))
        
        // download all presentations which is not exist in local
        currentDownloadPresentationIndex = 0
        processDownloadAllPresentationInWeeklySchedule()
    }
    
    fileprivate func processDownloadAllPresentationInWeeklySchedule() {
        if weeklySchedule.displaySchedule.count == 0 {
            // download done -> process next step
            // for each presentation -> zip presentation folder -> send zip folder to local displayer
            currentUploadPresentationIndex = 0
            processZipAllPresentationAndSendToLocalServerForWeeklySchedule()
            
        } else {
            if currentDownloadPresentationIndex < weeklySchedule.displaySchedule.count {
                let weeklyPresentation = weeklySchedule.displaySchedule[currentDownloadPresentationIndex]
                
                // Has presentation existed in local?
                let presentationURL = Utility.getUrlFromDocumentWithAppend(url: Dir.savePresentation + weeklyPresentation.presentation)
                if FileManager.default.fileExists(atPath: presentationURL.path) {
                    // process download next presentation
                    currentDownloadPresentationIndex += 1
                    processDownloadAllPresentationInWeeklySchedule()
                } else {
                    // process download presentation
                    let downloadPresentationHelper = DownloadPresentationHelper.init(presentationId: weeklyPresentation.presentation, controller: self)
                    downloadPresentationHelper.completionHandler = {
                        (success, message) in
                        
                        weak var weakSelf = self
                        
                        dLog(message: "weeklySchedule -> download presentation done with id = \(weeklyPresentation.presentation)")
                        
                        if success {
                            // download presentation successful -> save data info to templateSlide.json file
                            TemplateSlide.processSaveNewPresentation(presentationId: weeklyPresentation.presentation, completion: {
                                (success) in
                                
                                weak var weakSelf = self
                                
                                if !success {
                                    SVProgressHUD.dismiss()
                                    Utility.showAlertWithErrorMessage(message: localizedString(key: "common_error"), controller: weakSelf!)
                                    return
                                }
                            })
                            
                            // download next presentation
                            weakSelf?.currentDownloadPresentationIndex += 1
                            weakSelf?.processDownloadAllPresentationInWeeklySchedule()
                        } else {
                            SVProgressHUD.dismiss()
                            Utility.showAlertWithErrorMessage(message: message, controller: weakSelf!)
                        }
                    }
                    downloadPresentationHelper.processDownloadPresentation()
                }
            } else {
                // download done -> process next step
                // for each presentation -> zip presentation folder -> send zip folder to local displayer
                currentUploadPresentationIndex = 0
                processZipAllPresentationAndSendToLocalServerForWeeklySchedule()
            }
        }
    }
    
    fileprivate func processZipAllPresentationAndSendToLocalServerForWeeklySchedule() {
        if weeklySchedule.displaySchedule.count == 0 {
            // upload done -> next step
            // create file "weeklyScheduleId.evsch" -> zip it -> send it to local displayer
            processSendWeeklyScheduleDesignFileToLocalServer()
        } else {
            if currentUploadPresentationIndex < weeklySchedule.displaySchedule.count {
                let weeklySchedulePresentation = weeklySchedule.displaySchedule[currentUploadPresentationIndex]
                processUploadPresentationToLocalDevice(withPresentationId: weeklySchedulePresentation.presentation, completion: {
                    (success, message) in
                    
                    weak var weakSelf = self
                    
                    dLog(message: "weeklySchedule -> send zip done with presentation id = \(weeklySchedulePresentation.presentation)")
                    
                    if success {
                        // upload next presentation
                        weakSelf?.currentUploadPresentationIndex += 1
                        weakSelf?.processZipAllPresentationAndSendToLocalServerForWeeklySchedule()
                    } else {
                        SVProgressHUD.dismiss()
                        Utility.showAlertWithErrorMessage(message: message, controller: weakSelf!)
                    }
                })
            } else {
                // upload done -> next step
                // create file "weeklyScheduleId.evsch" -> zip it -> send it to local displayer
                processSendWeeklyScheduleDesignFileToLocalServer()
            }
        }
    }
    
    fileprivate func processSendWeeklyScheduleDesignFileToLocalServer() {
        // create file "weeklyScheduleId.evsch"
        let scheduleDesignFileURL = Utility.getUrlFromDocumentWithAppend(url: weeklySchedule.id + Dir.scheduleDesignExtension)
        do {
            let rawData = weeklySchedule.toJsonData()
            try rawData.write(to: scheduleDesignFileURL, options: .atomic)
        } catch {
            SVProgressHUD.dismiss()
            Utility.showAlertWithErrorMessage(message: localizedString(key: "common_error_message"), controller: self)
            dLog(message: error.localizedDescription)
            return
        }
        
        // zip it
        var zipFileURL: URL?
        do {
            zipFileURL = try Zip.quickZipFiles([scheduleDesignFileURL], fileName: weeklySchedule.id)
        } catch {
            SVProgressHUD.dismiss()
            Utility.showAlertWithErrorMessage(message: localizedString(key: "common_error_message"), controller: self)
            dLog(message: error.localizedDescription)
            return
        }
        
        // get selected device
        guard let sendingDevice = getSendingDevice() else {
            dLog(message: "can't get sending device")
            SVProgressHUD.dismiss()
            Utility.showAlertWithErrorMessage(message: localizedString(key: "common_error_message"), controller: self)
            return
        }
        
        do {
            let zipData = try Data.init(contentsOf: zipFileURL!)
            // send it to local displayer
            NetworkManager.shared.uploadZipFolderToDevice(clientAddress: sendingDevice.ipAddress, contentId: weeklySchedule.id, zipFileName: (weeklySchedule.id + ".zip"), zipData: zipData, completion: {
                (success, message) in
                
                weak var weakSelf = self
                
                dLog(message: "weeklySchedule -> send zip design file with zip file url = \(String(describing: zipFileURL?.path))")
                
                // remove zip file
                do {
                    try FileManager.default.removeItem(at: scheduleDesignFileURL)
                    try FileManager.default.removeItem(at: zipFileURL!)
                } catch {
                    SVProgressHUD.dismiss()
                    Utility.showAlertWithErrorMessage(message: localizedString(key: "common_error_message"), controller: weakSelf!)
                    dLog(message: error.localizedDescription)
                    return
                }
                
                if success {
                    // cal API play WeeklySchedule
                    weakSelf?.processCallAPItoPLayWeeklySchedule(sendingDevice: sendingDevice)
                } else {
                    SVProgressHUD.dismiss()
                    Utility.showAlertWithErrorMessage(message: message, controller: weakSelf!)
                }
            })
        } catch {
            dLog(message: error.localizedDescription)
            SVProgressHUD.dismiss()
            Utility.showAlertWithErrorMessage(message: localizedString(key: "common_error_message"), controller: self)
        }
    }
    
    fileprivate func processCallAPItoPLayWeeklySchedule(sendingDevice: Device) {
        NetworkManager.shared.playLocalScheduleWeekly(pinCode: sendingDevice.pinCode, clientAddress: sendingDevice.ipAddress, scheduleId: weeklySchedule.id) {
            (success, message) in
            
            weak var weakSelf = self
            
            SVProgressHUD.dismiss()
            
            dLog(message: "weeklySchedule -> call api display weeklySchedule done")
            
            if success {
                SVProgressHUD.showSuccess(withStatus: localizedString(key: "common_sent"))
            } else {
                Utility.showAlertWithErrorMessage(message: message, controller: weakSelf!)
            }
        }
    }
}
