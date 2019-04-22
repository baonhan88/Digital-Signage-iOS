//
//  CloudDeviceListViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 26/04/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import SVProgressHUD
import SwiftyJSON

@objc protocol CloudDeviceListViewControllerDelegate {
    @objc optional func handleSendPresentation(pinCodeJsonString: String)
    @objc optional func handleSendInstantMessage(pinCodeJsonString: String)
    @objc optional func handleSendPlayList(pinCodeJsonString: String)
    @objc optional func handleSendWeeklySchedule(pinCodeJsonString: String)
    @objc optional func handleSendRealTimeSchedule(pinCodeJsonString: String)
    @objc optional func handleSendDataset(pinCodeJsonString: String)
    @objc optional func handleSendAsset(pinCodeJsonString: String)
}

class CloudDeviceListViewController: BaseTableViewController {
    
    fileprivate var deviceList: NSMutableArray = []
    fileprivate var pageInfo = PageInfo()
    fileprivate var loadingData = true
    
    var delegate: CloudDeviceListViewControllerDelegate?
    
    var currentDeviceListType: DeviceListType = .unknown
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.deviceList = []
        
        self.refreshControl?.addTarget(self,
                                       action: #selector(handleRefresh(refreshControl:)),
                                       for: UIControlEvents.valueChanged)
        
        // register all cells
        self.tableView.register(UINib(nibName: "CloudDeviceListCell", bundle: nil), forCellReuseIdentifier: "CloudDeviceListCell")
        
        // init navigation bar
        initNavigationBar()
        
        // load data
        loadMoreData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func initNavigationBar() {
        self.title = localizedString(key: "device_list_cloud_title")
        
        // init cloud icon
        let cloudImage   = UIImage(named: "icon_send")!
        let cloudButton   = UIBarButtonItem(image: cloudImage,  style: .plain, target: self, action: #selector(sendCloudButtonClicked(barButton:)))
        
        // init update icon
        let updateImage   = UIImage(named: "icon_control_to_update")!
        let updateButton   = UIBarButtonItem(image: updateImage,  style: .plain, target: self, action: #selector(controlToUpdateButtonClicked(barButton:)))
        
        navigationItem.rightBarButtonItems = [cloudButton, updateButton]
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        // reset all data
        deviceList.removeAllObjects()
        pageInfo = PageInfo()
        
        // call API get data
        loadMoreData()
    }

    fileprivate func generateSelectedDeviceJson() -> String {
        let selectedDeviceArray: NSMutableArray = NSMutableArray()
        for device in deviceList as! [Device] {
            if device.isChoose {
                selectedDeviceArray.add(device.pinCode)
            }
        }
        
        let jsonData: NSData
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: selectedDeviceArray, options: JSONSerialization.WritingOptions()) as NSData
            let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue)! as String
            
            return jsonString
            
        } catch _ {
            dLog(message: "JSON Failure")
        }
        
        return ""
    }
    
    fileprivate func isValidData() -> Bool {
        // check user must choose at least one device
        for device in deviceList as! [Device] {
            if device.isChoose {
                return true
            }
        }
        
        return false
    }
    
    fileprivate func sortDeviceListWithOnlineOnTop() {
        let tmpArrayList = NSMutableArray.init()
        
        for device in deviceList as! [Device] {
            if device.liveStatus == DeviceStatus.offline.statusString() {
                tmpArrayList.add(device)
            } else if device.liveStatus == DeviceStatus.online.statusString() {
                tmpArrayList.insert(device, at: 0)
            }
        }
        
        deviceList = tmpArrayList
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
                                                        weakSelf?.sortDeviceListWithOnlineOnTop()
      
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

// MARK: - UITableViewDelegate & UITableViewDataSource

extension CloudDeviceListViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (deviceList.count)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 107
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CloudDeviceListCell") as? CloudDeviceListCell
        
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
        
        let device = deviceList[indexPath.row] as! Device
        device.isChoose = !device.isChoose
        
        tableView.reloadData()
    }
}

// MARK: - handle Events

extension CloudDeviceListViewController {
    
    func sendCloudButtonClicked(barButton: UIBarButtonItem) {
        processSendToCloudWithIsUpdate(isUpdate: false)
    }
    
    func controlToUpdateButtonClicked(barButton: UIBarButtonItem) {
        processSendToCloudWithIsUpdate(isUpdate: true)
    }
    
    func processSendToCloudWithIsUpdate(isUpdate: Bool) {
        if !isValidData() {
            Utility.showAlertWithErrorMessage(message: localizedString(key: "im_error_empty_device"), controller: self, completion: nil)
            return
        }
        
        switch currentDeviceListType {
            
        case .instantMessage:
            delegate?.handleSendInstantMessage!(pinCodeJsonString: generateSelectedDeviceJson())
            break
            
        case .presentation:
            delegate?.handleSendPresentation!(pinCodeJsonString: generateSelectedDeviceJson())
            break
            
        case .playList:
            delegate?.handleSendPlayList!(pinCodeJsonString: generateSelectedDeviceJson())
            break
            
        case .weeklySchedule:
            delegate?.handleSendWeeklySchedule!(pinCodeJsonString: generateSelectedDeviceJson())
            break
            
        case .realTimeSchedule:
            delegate?.handleSendRealTimeSchedule!(pinCodeJsonString: generateSelectedDeviceJson())
            break
        
        case .dataset:
            delegate?.handleSendDataset!(pinCodeJsonString: generateSelectedDeviceJson())
            break
            
        case .asset:
            delegate?.handleSendAsset!(pinCodeJsonString: generateSelectedDeviceJson())
            break
            
        default:
            return
        }
    }
}
