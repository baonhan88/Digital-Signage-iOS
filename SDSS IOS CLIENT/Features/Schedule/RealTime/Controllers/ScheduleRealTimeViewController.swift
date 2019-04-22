//
//  ScheduleRealTimeViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 03/07/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol ScheduleRealTimeViewControllerDelegate {
    func handleGoToRealTimeEditor(realTimeSchedule: RealTimeSchedule)
}

class ScheduleRealTimeViewController: BaseTableViewController {
    
    fileprivate var realTimeScheduleList: NSMutableArray = []
    fileprivate var pageInfo = PageInfo()
    fileprivate var loadingData = true
    
    var delegate: ScheduleRealTimeViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.realTimeScheduleList = []
        
        self.refreshControl?.addTarget(self,
                                       action: #selector(handleRefresh),
                                       for: UIControlEvents.valueChanged)
        
        // register all cells
        self.tableView.register(UINib(nibName: "RealTimeScheduleCell", bundle: nil), forCellReuseIdentifier: "RealTimeScheduleCell")
        
        // load data
        loadMoreData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleRefresh() {
        // reset all data
        realTimeScheduleList.removeAllObjects()
        pageInfo = PageInfo()
        
        // call API get data
        loadMoreData()
    }
    
    fileprivate func loadMoreData() {
        if pageInfo.hasNext {
            loadingData = true
            
            // show loading
            SVProgressHUD.show()
            
            NetworkManager.shared.getRealTimeScheduleList(token: Utility.getToken(),
                                                          sort: "-updatedDate",
                                                          page: pageInfo.current + 1,
                                                          perPage: Network.perPage) {
                (success, realTimeScheduleList, pageInfo, message) in
                
                weak var weakSelf = self
                
                weakSelf?.refreshControl?.endRefreshing()
                
                // remove loading
                SVProgressHUD.dismiss()
                
                if (success) {
                    weakSelf?.realTimeScheduleList.addObjects(from: realTimeScheduleList!)
                    
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
    
    fileprivate func processEditRealTimeScheduleName(withNewName name: String, of realTimeSchedule: RealTimeSchedule) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        if !Utility.isValidName(name: trimmedName) {
            Utility.showAlertWithErrorMessage(message: localizedString(key: "schedule_edit_name_invalid"),
                                              controller: self,
                                              completion: nil)
            return
        }
        
        // show loading
        SVProgressHUD.show()
        
        NetworkManager.shared.editNameRealTimeSchedule(id: realTimeSchedule.id, name: trimmedName, token: Utility.getToken()) {
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
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension ScheduleRealTimeViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (realTimeScheduleList.count)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RealTimeScheduleCell") as? RealTimeScheduleCell
        cell?.delegate = self
        
        if realTimeScheduleList.count > 0 {
            cell?.initViewWithRealTimeSchedule(realTimeScheduleList[indexPath.row] as! RealTimeSchedule)
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = (realTimeScheduleList.count) - 1
        if indexPath.row == lastElement && loadingData == false {
            loadMoreData()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        delegate?.handleGoToRealTimeEditor(realTimeSchedule: realTimeScheduleList[indexPath.row] as! RealTimeSchedule)
    }
}

// MARK: - RealTimeScheduleCellDelegate

extension ScheduleRealTimeViewController: RealTimeScheduleCellDelegate {
    
    func handleTapOnEditButton(realTimeSchedule: RealTimeSchedule) {
        let alert = UIAlertController(title: localizedString(key: "playlist_edit_name_alert_title"),
                                      message: localizedString(key: "playlist_edit_name_alert_message"),
                                      preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = realTimeSchedule.name
        }
        
        alert.addAction(UIAlertAction(title: localizedString(key: "common_cancel"),
                                      style: .default,
                                      handler: nil))
        
        alert.addAction(UIAlertAction(title: localizedString(key: "common_ok"),
                                      style: .default,
                                      handler: { [weak alert] (_) in
                                        
                                        weak var weakSelf = self
                                        
                                        guard let textField = alert?.textFields![0] else {
                                            return
                                        }
                                        
                                        weakSelf?.processEditRealTimeScheduleName(withNewName: textField.text!, of: realTimeSchedule)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleTapOnDeleteButton(realTimeSchedule: RealTimeSchedule) {
        let alert = UIAlertController(title: localizedString(key: "schedule_realtime_delete_confirm_title"),
                                      message: localizedString(key: "schedule_realtime_delete_confirm_message"),
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: localizedString(key: "common_no"),
                                      style: UIAlertActionStyle.default,
                                      handler: nil))
        
        alert.addAction(UIAlertAction(title: localizedString(key: "common_yes"),
                                      style: UIAlertActionStyle.default,
                                      handler: { (alert) in
                                        
                                        // show loading
                                        SVProgressHUD.show()
                                        
                                        NetworkManager.shared.deleteRealTimeSchedule(id: realTimeSchedule.id, token: Utility.getToken()) {
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
