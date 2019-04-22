//
//  ScheduleWeeklyViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 03/07/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol ScheduleWeeklyViewControllerDelegate {
    func handleGoToWeeklyEditor(weeklySchedule: WeeklySchedule)
}

class ScheduleWeeklyViewController: BaseTableViewController {
    
    fileprivate var weeklyScheduleList: NSMutableArray = []
    fileprivate var pageInfo = PageInfo()
    fileprivate var loadingData = true
    
    var delegate: ScheduleWeeklyViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.weeklyScheduleList = []
        
        self.refreshControl?.addTarget(self,
                                       action: #selector(handleRefresh),
                                       for: UIControlEvents.valueChanged)
        
        // register all cells
        self.tableView.register(UINib(nibName: "WeeklyScheduleCell", bundle: nil), forCellReuseIdentifier: "WeeklyScheduleCell")
        
        // load data
        loadMoreData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleRefresh() {
        // reset all data
        weeklyScheduleList.removeAllObjects()
        pageInfo = PageInfo()
        
        // call API get data
        loadMoreData()
    }
    
    fileprivate func loadMoreData() {
        if pageInfo.hasNext {
            loadingData = true
            
            // show loading
            SVProgressHUD.show()
            
            NetworkManager.shared.getWeeklyScheduleList(token: Utility.getToken(),
                                                        sort: "-updatedDate",
                                                        page: pageInfo.current + 1,
                                                        perPage: Network.perPage) {
                (success, weeklyScheduleList, pageInfo, message) in
                
                weak var weakSelf = self
                
                weakSelf?.refreshControl?.endRefreshing()
                
                // remove loading
                SVProgressHUD.dismiss()
                
                if (success) {
                    weakSelf?.weeklyScheduleList.addObjects(from: weeklyScheduleList!)
                    
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
    
    fileprivate func processEditWeeklyScheduleName(withNewName name: String, of weeklySchedule: WeeklySchedule) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        if !Utility.isValidName(name: trimmedName) {
            Utility.showAlertWithErrorMessage(message: localizedString(key: "schedule_edit_name_invalid"),
                                              controller: self,
                                              completion: nil)
            return
        }
        
        // show loading
        SVProgressHUD.show()
        
        NetworkManager.shared.editNameWeeklySchedule(id: weeklySchedule.id, name: trimmedName, token: Utility.getToken()) {
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

extension ScheduleWeeklyViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (weeklyScheduleList.count)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeeklyScheduleCell") as? WeeklyScheduleCell
        cell?.delegate = self
        
        if weeklyScheduleList.count > 0 {
            cell?.initViewWithWeeklySchedule(weeklyScheduleList[indexPath.row] as! WeeklySchedule)
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = (weeklyScheduleList.count) - 1
        if indexPath.row == lastElement && loadingData == false {
            loadMoreData()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)

        delegate?.handleGoToWeeklyEditor(weeklySchedule: weeklyScheduleList[indexPath.row] as! WeeklySchedule)
    }
}

// MARK: - WeeklyScheduleCellDelegate

extension ScheduleWeeklyViewController: WeeklyScheduleCellDelegate {
    
    func handleTapOnEditButton(weeklySchedule: WeeklySchedule) {
        let alert = UIAlertController(title: localizedString(key: "playlist_edit_name_alert_title"),
                                      message: localizedString(key: "playlist_edit_name_alert_message"),
                                      preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = weeklySchedule.name
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
                                        
                                        weakSelf?.processEditWeeklyScheduleName(withNewName: textField.text!, of: weeklySchedule)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleTapOnDeleteButton(weeklySchedule: WeeklySchedule) {
        let alert = UIAlertController(title: localizedString(key: "schedule_weekly_delete_confirm_title"),
                                      message: localizedString(key: "schedule_weekly_delete_confirm_message"),
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: localizedString(key: "common_no"),
                                      style: UIAlertActionStyle.default,
                                      handler: nil))
        
        alert.addAction(UIAlertAction(title: localizedString(key: "common_yes"),
                                      style: UIAlertActionStyle.default,
                                      handler: { (alert) in
                                        
                                        // show loading
                                        SVProgressHUD.show()
                                        
                                        NetworkManager.shared.deleteWeeklySchedule(id: weeklySchedule.id, token: Utility.getToken()) {
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
