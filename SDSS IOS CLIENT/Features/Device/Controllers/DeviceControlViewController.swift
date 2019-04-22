//
//  DeviceControlViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 04/05/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import SVProgressHUD

class DeviceControlViewController: BaseTableViewController {
    
    var device: Device = Device()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavigationBar()
        
        // register all cells
        self.tableView.register(UINib(nibName: "DeviceControlDimCell", bundle: nil), forCellReuseIdentifier: "DeviceControlDimCell")
        self.tableView.register(UINib(nibName: "DeviceControlControlCell", bundle: nil), forCellReuseIdentifier: "DeviceControlControlCell")
        self.tableView.register(UINib(nibName: "DeviceControlWifiSettingCell", bundle: nil), forCellReuseIdentifier: "DeviceControlWifiSettingCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initController() {
        
    }
    
    fileprivate func initNavigationBar() {
        self.title = localizedString(key: "device_current_control_title")
        
        let cancelButton = UIBarButtonItem.init(title: localizedString(key: "common_cancel"), style: .plain, target: self, action: #selector(cancelButtonClicked(barButton:)))
        self.navigationItem.leftBarButtonItem = cancelButton
    }
    
    fileprivate func generateIdListJson() -> String {
        let idList: NSMutableArray = NSMutableArray()
        idList.add(device.id)
        
        let jsonData: NSData
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: idList, options: JSONSerialization.WritingOptions()) as NSData
            let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue)! as String
            
            return jsonString
            
        } catch _ {
            dLog(message: "JSON Failure")
        }
        
        return ""
    }
}

// MARK: - Handle Events

extension DeviceControlViewController {
    
    func cancelButtonClicked(barButton: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension DeviceControlViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceControlDimCell") as? DeviceControlDimCell
            
            cell?.initView(device: device)
            cell?.delegate = self
            
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceControlControlCell") as? DeviceControlControlCell
            
            cell?.initView(device: device)
            cell?.delegate = self

            return cell!
        }
        /*else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceControlWifiSettingCell") as? DeviceControlWifiSettingCell
            
            cell?.initView(device: device)
            cell?.delegate = self

            return cell!
        }*/
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - DeviceControlDimCellDelegate

extension DeviceControlViewController: DeviceControlDimCellDelegate {
    
    func handleResetAction(device: Device) {
        SVProgressHUD.show()
        
        NetworkManager.shared.controlDevice(action: "CLEAN_STORAGE", idList: generateIdListJson(), token: Utility.getToken()) { [weak self]
            (success, message) in
            
            SVProgressHUD.dismiss()
            
            if success {
                SVProgressHUD.showSuccess(withStatus: localizedString(key: "common_action_success"))
                self?.tableView.reloadData()
            } else {
                Utility.showAlertWithErrorMessage(message: message, controller: self!)
            }
        }
    }
    
    func handleDimAction(device: Device, isDim: Bool) {
        SVProgressHUD.show()
        
        NetworkManager.shared.updateDevice(id: device.id,
                                           content: nil,
                                           scheduleContent: nil,
                                           events: nil,
                                           isDim: isDim,
                                           playStatus: nil,
                                           group: nil,
                                           autoScale: nil,
                                           name: nil,
                                           token: Utility.getToken()) {
                                            [weak self] (success, message) in
            
            SVProgressHUD.dismiss()
            
            if success {
                SVProgressHUD.showSuccess(withStatus: localizedString(key: "common_action_success"))
                self?.device.isDim = isDim
            } else {
                Utility.showAlertWithErrorMessage(message: message, controller: self!)
            }
        }
    }
}

// MARK: - DeviceControlControlCellDelegate

extension DeviceControlViewController: DeviceControlControlCellDelegate {
    
    func handleTogglePlayStopAction(device: Device, isPlay: Bool) {
        SVProgressHUD.show()
        
        var actionString = ""
        if isPlay {
            actionString = "PLAY"
        } else {
            actionString = "PAUSE"
        }
        
        NetworkManager.shared.updateDevice(id: device.id,
                                           content: nil,
                                           scheduleContent: nil,
                                           events: nil,
                                           isDim: nil,
                                           playStatus: actionString,
                                           group: nil,
                                           autoScale: nil,
                                           name: nil,
                                           token: Utility.getToken()) {
                                            [weak self] (success, message) in
            
            SVProgressHUD.dismiss()
            
            if success {
                SVProgressHUD.showSuccess(withStatus: localizedString(key: "common_action_success"))
                self?.device.playStatus = actionString
                self?.tableView.reloadData()
            } else {
                Utility.showAlertWithErrorMessage(message: message, controller: self!)
            }
        }
    }
}

// MARK: - DeviceControlWifiSettingCellDelegate

extension DeviceControlViewController: DeviceControlWifiSettingCellDelegate {
    
    func handleWifiSettingAction(device: Device) {
        
    }
}
