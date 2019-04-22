//
//  DeviceCurrentPlayingViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 04/05/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import SVProgressHUD

class DeviceCurrentPlayingViewController: BaseTableViewController {
    
    var device: Device = Device()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavigationBar()
        
        // register all cells
        self.tableView.register(UINib(nibName: "DeviceCurrentPlayingEventCell", bundle: nil), forCellReuseIdentifier: "DeviceCurrentPlayingEventCell")
        self.tableView.register(UINib(nibName: "DeviceCurerntPlayingContentCell", bundle: nil), forCellReuseIdentifier: "DeviceCurerntPlayingContentCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initController() {
        
    }
    
    fileprivate func initNavigationBar() {
        self.title = localizedString(key: "device_current_playing_title")
        
        navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    fileprivate func processUpdateDevice() {
        SVProgressHUD.show()
        
        NetworkManager.shared.updateDevice(id: device.id,
                                           content: device.content.toJsonString(),
                                           scheduleContent: device.scheduleContent.toJsonString(),
                                           events: device.events.toJsonString(),
                                           isDim: nil,
                                           playStatus: nil,
                                           group: nil,
                                           autoScale: nil,
                                           name: nil,
                                           token: Utility.getToken()) { (success, message) in
            
            SVProgressHUD.dismiss()
            
            if success {
                
            } else {
                // show error message
                Utility.showAlertWithErrorMessage(message: message, controller: self, completion: nil)
            }
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension DeviceCurrentPlayingViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        var count = 0
        if device.content.id != "" {
            count += 1
        }
        if device.events.count > 0 {
            count += 1
        }
        if device.scheduleContent.count > 0 {
            count += 1
        }
        
        return count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if device.content.id != "" {
            if section == 0 {
                return 1
            } else if section == 1 {
                if device.events.count > 0 {
                    return device.events.count
                } else {
                    if device.scheduleContent.count > 0 {
                        return device.scheduleContent.count
                    }
                }
            } else if section == 2 {
                if device.events.count > 0 && device.scheduleContent.count > 0 {
                    return device.scheduleContent.count
                }
            }
        } else {
            if section == 0 {
                if device.events.count > 0 {
                    return device.events.count
                } else {
                    if device.scheduleContent.count > 0 {
                        return device.scheduleContent.count
                    }
                }
            } else if section == 1 {
                if device.events.count > 0 && device.scheduleContent.count > 0 {
                    return device.scheduleContent.count
                }
            }
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 44
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if device.content.id != "" {
            if indexPath.section == 0 {
                if indexPath.row == 0 { // content
                    let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCurerntPlayingContentCell") as? DeviceCurerntPlayingContentCell
                    
                    cell?.initView(contentName: device.content.name)
                    
                    return cell!
                }
            } else if indexPath.section == 1 {
                if device.events.count > 0 { // events
                    let event = device.events[indexPath.row]
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCurrentPlayingEventCell") as? DeviceCurrentPlayingEventCell
                    
                    cell?.initView(name: event.name, time: event.timeSchedule)
                    
                    return cell!
                } else { // scheduleContent
                    let content = device.scheduleContent[indexPath.row]
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCurerntPlayingContentCell") as? DeviceCurerntPlayingContentCell
                    
                    cell?.initView(contentName: content.name)
                    
                    return cell!
                }
            } else { // scheduleContent
                let content = device.scheduleContent[indexPath.row]
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCurerntPlayingContentCell") as? DeviceCurerntPlayingContentCell
                
                cell?.initView(contentName: content.name)
                
                return cell!
            }
        } else {
            if indexPath.section == 0 {
                if device.events.count > 0 { // events
                    let event = device.events[indexPath.row]
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCurrentPlayingEventCell") as? DeviceCurrentPlayingEventCell
                    
                    cell?.initView(name: event.name, time: event.timeSchedule)
                    
                    return cell!
                } else { // scheduleContent
                    let content = device.scheduleContent[indexPath.row]
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCurerntPlayingContentCell") as? DeviceCurerntPlayingContentCell
                    
                    cell?.initView(contentName: content.name)
                    
                    return cell!
                }
            } else { // scheduleContent
                let content = device.scheduleContent[indexPath.row]
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCurerntPlayingContentCell") as? DeviceCurerntPlayingContentCell
                
                cell?.initView(contentName: content.name)
                
                return cell!
            }

        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCurerntPlayingContentCell") as? DeviceCurerntPlayingContentCell
        
        cell?.initView(contentName: device.content.name)
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if device.content.id != "" {
            if section == 0 {
                return localizedString(key: "device_current_playing_content_section_title")
            } else if section == 1 {
                if device.events.count > 0 {
                    return localizedString(key: "device_current_playing_event_section_title")
                } else {
                    return localizedString(key: "device_current_playing_schedule_content_section_title")
                }
            } else {
                return localizedString(key: "device_current_playing_schedule_content_section_title")
            }
        } else {
            if section == 0 {
                if device.events.count > 0 {
                    return localizedString(key: "device_current_playing_event_section_title")
                } else {
                    return localizedString(key: "device_current_playing_schedule_content_section_title")
                }
            } else {
                return localizedString(key: "device_current_playing_schedule_content_section_title")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            var isUpdate = false
            
            // Delete the row from the data source
            if device.content.id != "" {
                if indexPath.section == 1 {
                    if device.events.count > 0 {
                        device.events.remove(at: indexPath.row)
                        isUpdate = true
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    } else {
                        device.scheduleContent.remove(at: indexPath.row)
                        isUpdate = true
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                } else if indexPath.section == 2 {
                    device.scheduleContent.remove(at: indexPath.row)
                    isUpdate = true
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            } else {
                if indexPath.section == 0 {
                    if device.events.count > 0 {
                        device.events.remove(at: indexPath.row)
                        isUpdate = true
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    } else {
                        device.scheduleContent.remove(at: indexPath.row)
                        isUpdate = true
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                } else if indexPath.section == 1 {
                    device.scheduleContent.remove(at: indexPath.row)
                    isUpdate = true
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
            
            if isUpdate {
                processUpdateDevice()
            }
        }
    }
}

