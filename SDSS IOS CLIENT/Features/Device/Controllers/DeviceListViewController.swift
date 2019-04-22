//
//  DeviceListViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 26/04/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import SVProgressHUD
import CocoaAsyncSocket

class DeviceListViewController: BaseTableViewController {
    
    var deviceList: NSMutableArray = []
    var pageInfo = PageInfo()
    var loadingData = true
    
    var timer: Timer?
    
    var broadcastAddress: String?
    
    var selectedDevice: Device?
    
    fileprivate var filterString = ""
    var deviceFilter: DeviceFilter = DeviceFilter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.deviceList = []
        
        self.refreshControl?.addTarget(self,
                                       action: #selector(handleRefresh),
                                       for: UIControlEvents.valueChanged)
        
        // register all cells
        self.tableView.register(UINib(nibName: "DeviceListCell", bundle: nil), forCellReuseIdentifier: "DeviceListCell")
        
        // init navigation bar
        initNavigationBar()
        
        // load data
        loadMoreData()
        
        // set up broadcast data to local addresses
        let netInfo = Utility.getIFAddresses()
        let netInfoHelper = NetInfoHelper(ip: netInfo.first!.ip, netmask: netInfo.first!.netmask)
        broadcastAddress = netInfoHelper.broadcast
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.removeTimer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func initNavigationBar() {
        self.title = localizedString(key: "device_title")
        
        let addButton = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(addDeviceButtonClicked(barButton:)))
        
        let categoryImage = UIImage(named: "icon_category_small")!
        let categoryButton = UIBarButtonItem(image: categoryImage,  style: .plain, target: self, action: #selector(categoryButtonClicked(barButton:)))
        
   //     let qrCodeImage = UIImage(named: "icon_qr_code")!
     //   let qrCodeButton = UIBarButtonItem(image: qrCodeImage,  style: .plain, target: self, action: #selector(qrCodeButtonClicked(barButton:)))
        
        let filterImage = UIImage(named: "icon_filter")!
        let filterButton = UIBarButtonItem(image: filterImage,  style: .plain, target: self, action: #selector(filterButtonClicked(barButton:)))
        
        navigationItem.rightBarButtonItems = [categoryButton, addButton, filterButton]
    }
    
    func initTimerToSendBroadcast() {
        if self.timer == nil {
            // start timer to send broadcast data each "sendBroadcastDelayTime"
            timer = Timer.scheduledTimer(timeInterval: TimeInterval(Socket.sendBroadcastDelayTime),
                                         target: self,
                                         selector: #selector(sendBroadcastSocket),
                                         userInfo: nil,
                                         repeats: true)
        }
    }
    
    func removeTimer() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
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
    
    func handleRefresh() {
        // reset all data
        deviceList.removeAllObjects()
        pageInfo = PageInfo()
        
        // call API get data
        loadMoreData()
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
                                                filter: filterString) {
                                                    (success, deviceList, pageInfo, message) in
                                                    
                                                    weak var weakSelf = self
                                                    
                                                    weakSelf?.refreshControl?.endRefreshing()
                                                    
                                                    // remove loading
                                                    SVProgressHUD.dismiss()
                                                    
                                                    // save deviceList to UserDefault to use whenever can't connect internet
                                                    let encodedData = NSKeyedArchiver.archivedData(withRootObject: deviceList ?? [])
                                                    UserDefaults.standard.set(encodedData, forKey: Network.paramDeviceList)
                                                    
                                                    if (success) {
                                                        weakSelf?.deviceList.addObjects(from: deviceList!)
                                                        
                                                        weakSelf?.pageInfo = pageInfo!
                                                        
                                                        if (weakSelf?.deviceList.count)! > 0 {
                                                            weakSelf?.initTimerToSendBroadcast()
                                                        }
                                                        
                                                        weakSelf?.tableView.reloadData()
                                                        
                                                    } else {
                                                        // show error message
                                                        Utility.showAlertWithErrorMessage(message: message, controller: self, completion: nil)
                                                    }
                                                    
                                                    weakSelf?.loadingData = false
            }
        }
    }
    
//    fileprivate func processEditDeviceName(withNewName name: String, ofDevice device: Device) {
//        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
//        
//        if !Utility.isValidName(name: trimmedName) {
//            Utility.showAlertWithErrorMessage(message: localizedString(key: "device_edit_name_invalid"),
//                                              controller: self,
//                                              completion: nil)
//            return
//        }
//        
//        // show loading
//        SVProgressHUD.show()
//        
//        NetworkManager.shared.editNameDevice(id: device.id,
//                                             name: trimmedName,
//                                             token: Utility.getToken()) {
//                                                (success, message) in
//                                                
//                                                weak var weakSelf = self
//                                                
//                                                // remove loading
//                                                SVProgressHUD.dismiss()
//                                                
//                                                if (success) {
//                                                    // refresh data
//                                                    weakSelf?.handleRefresh()
//                                                    
//                                                } else {
//                                                    // show error message
//                                                    Utility.showAlertWithErrorMessage(message: message, controller: self, completion: nil)
//                                                }
//                                                
//        }
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "playContentSegue" {
            if let desNavigation = segue.destination as? UINavigationController {
                let destVC = desNavigation.topViewController as? DevicePlayingContentViewController
                destVC?.device = selectedDevice!
            }
        }
    }
}

// MARK: - Handle Events

extension DeviceListViewController {
    
    func addDeviceButtonClicked(barButton: UIBarButtonItem) {
        self.performSegue(withIdentifier: "registerDeviceSegue", sender: nil)
    }
    
    func categoryButtonClicked(barButton: UIBarButtonItem) {
        ControllerManager.showCategoryListScreen(controller: self)
    }
    
    func qrCodeButtonClicked(barButton: UIBarButtonItem) {
        ControllerManager.showBarCodeScannerScreen(controller: self)
    }
    
    func filterButtonClicked(barButton: UIBarButtonItem) {
        ControllerManager.showDeviceFilterScreen(controller: self, currentDeviceFilter: self.deviceFilter)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension DeviceListViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (deviceList.count)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceListCell") as? DeviceListCell
        cell?.delegate = self
        
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
}

// MARK: - DeviceListCellDelegate

extension DeviceListViewController: DeviceListCellDelegate {
    
    func handleControlButton(device: Device) {
        ControllerManager.showDeviceControlScreen(controller: self, device: device)
    }
    
    func handleContentListButton(device: Device) {
        ControllerManager.showDeviceCurrentPlayingScreen(controller: self, device: device)
    }
    
    func handleEditButton(device: Device) {
        ControllerManager.showDeviceSettingScreen(controller: self, currentDevice: device)
    }
    
    func handlePlayButton(device: Device) {
        if device.liveStatus == DeviceStatus.offline.statusString() {
            Utility.showAlertWithErrorMessage(message: localizedString(key: "device_offline_can_not_play_content"), controller: self)
            return
        }
        
        selectedDevice = device

        self.performSegue(withIdentifier: "playContentSegue", sender: nil)
    }
    
    func handleDeleteButton(device: Device) {
        let alert = UIAlertController(title: localizedString(key: "device_delete_confirm_title"),
                                      message: localizedString(key: "device_delete_confirm_message"),
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: localizedString(key: "common_no"),
                                      style: UIAlertActionStyle.default,
                                      handler: nil))
        
        alert.addAction(UIAlertAction(title: localizedString(key: "common_yes"),
                                      style: UIAlertActionStyle.default,
                                      handler: { (alert) in
                                        
                                        // show loading
                                        SVProgressHUD.show()
                                        
                                        NetworkManager.shared.deleteDevice(id: device.id,
                                                                           token: Utility.getToken()) {
                                                                            (success, message) in
                                                                            
                                                                            weak var weakSelf = self
                                                                            
                                                                            // remove loading
                                                                            SVProgressHUD.dismiss()
                                                                            
                                                                            if (success) {
                                                                                // refresh data
                                                                                weakSelf?.handleRefresh()
                                                                                
                                                                            } else {
                                                                                // show error message
                                                                                Utility.showAlertWithErrorMessage(message: message, controller: self, completion: nil)
                                                                            }
                                                                            
                                        }
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - GCDAsyncUdpSocketDelegate

// handle all socket events
extension DeviceListViewController: GCDAsyncUdpSocketDelegate {
    func udpSocket(_ sock: GCDAsyncUdpSocket, didConnectToAddress address: Data) {
        dLog(message: "didConnectToAddress")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotConnect error: Error?) {
        dLog(message: "didNotConnect \(String(describing: error))")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
        dLog(message: "didSendDataWithTag")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotSendDataWithTag tag: Int, dueToError error: Error?) {
        dLog(message: "didNotSendDataWithTag")
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
                    device.liveStatus = DeviceStatus.offline.statusString()
                } else {
                    device.liveStatus = DeviceStatus.online.statusString()
                }
                return device
            }
        }
        
        return nil
    }
}

// MARK - DeviceFilterViewControllerDelegate

extension DeviceListViewController: DeviceFilterViewControllerDelegate {
    
    func handleFilter(deviceFilter: DeviceFilter) {
        self.deviceFilter = deviceFilter
        
        filterString = deviceFilter.generateSelectedFilterJson()
        
        dLog(message: "filterString = " + filterString)
        
        if filterString != "" {
            handleRefresh()
        }
    }
}

// MARK - DeviceSettingViewControllerDelegate

extension DeviceListViewController: DeviceSettingViewControllerDelegate {
    
    func handleSettingChanged(device: Device) {
        SVProgressHUD.show()
        
        NetworkManager.shared.updateDevice(id: device.id,
                                           content: nil,
                                           scheduleContent: nil,
                                           events: nil,
                                           isDim: nil,
                                           playStatus: nil,
                                           group: device.group.toJsonString(),
                                           autoScale: device.autoScale,
                                           name: device.name,
                                           token: Utility.getToken()) {
                                            [weak self] (success, message) in
                                            
                                            SVProgressHUD.dismiss()
                                            
                                            if success {
                                                SVProgressHUD.showSuccess(withStatus: localizedString(key: "common_action_success"))
                                                self?.handleRefresh()
                                            } else {
                                                Utility.showAlertWithErrorMessage(message: message, controller: self!)
                                            }
        }
    }
}
