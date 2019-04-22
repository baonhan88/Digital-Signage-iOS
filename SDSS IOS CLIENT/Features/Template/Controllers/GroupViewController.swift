//
//  GroupViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 17/10/2018.
//  Copyright © 2018 SLab. All rights reserved.
//

import UIKit
import SVProgressHUD

class GroupViewController: BaseTableViewController {
    
    fileprivate var groupList: NSMutableArray = []
    fileprivate var pageInfo = PageInfo()
    fileprivate var loadingData = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.groupList = []
        
        self.refreshControl?.addTarget(self,
                                       action: #selector(handleRefresh),
                                       for: UIControlEvents.valueChanged)
        
        // register all cells
        self.tableView.register(UINib(nibName: "GroupCell", bundle: nil), forCellReuseIdentifier: "GroupCell")
        
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
        self.title = localizedString(key: "group_title")
        
        let addButton = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(addGroupButtonClicked(barButton:)))
        navigationItem.rightBarButtonItem = addButton
    }
    
    func handleRefresh() {
        // reset all data
        groupList.removeAllObjects()
        pageInfo = PageInfo()
        
        // call API get data
        loadMoreData()
    }
    
    fileprivate func loadMoreData() {
        if pageInfo.hasNext {
            loadingData = true
            
            // show loading
            SVProgressHUD.show()
            
            NetworkManager.shared.getGroupList(token: Utility.getToken(),
                                               sort: "-updatedDate",
                                               page: pageInfo.current + 1,
                                               perPage: Network.perPage) {
                                                (success, groupList, pageInfo, message) in
                                                
                                                weak var weakSelf = self
                                                
                                                weakSelf?.refreshControl?.endRefreshing()
                                                
                                                // remove loading
                                                SVProgressHUD.dismiss()
                                                
                                                if (success) {
                                                    weakSelf?.groupList.addObjects(from: groupList!)
                                                    
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
    
    fileprivate func processEditGroupName(withNewName name: String, ofGroup group: Group) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !Utility.isValidName(name: trimmedName) {
            Utility.showAlertWithErrorMessage(message: localizedString(key: "group_edit_name_invalid"),
                                              controller: self,
                                              completion: nil)
            return
        }
        
        // show loading
        SVProgressHUD.show()
        
        NetworkManager.shared.editNameGroup(id: group.id, name: trimmedName, token: Utility.getToken()) {
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

// MARK: - Handle Events

extension GroupViewController {
    
    func addGroupButtonClicked(barButton: UIBarButtonItem) {
        let alert = UIAlertController(title: localizedString(key: "group_add_alert_title"),
                                      message: localizedString(key: "group_add_alert_message"),
                                      preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            
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
                                        
                                        if !Utility.isValidName(name: textField.text!) {
                                            Utility.showAlertWithErrorMessage(message: localizedString(key: "group_edit_name_invalid"),
                                                                              controller: weakSelf!,
                                                                              completion: nil)
                                            return
                                        }
                                        
                                        // show loading
                                        SVProgressHUD.show()
                                        
                                        NetworkManager.shared.addGroup(name: textField.text!, contentType: "PRESENTATION", token: Utility.getToken(), completion: {
                                            (success, id, message) in
                                            
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
                                        })
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension GroupViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (groupList.count)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell") as? GroupCell
        cell?.delegate = self
        
        if groupList.count > 0 {
            cell?.initViewWithGroup(groupList[indexPath.row] as! Group)
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = (groupList.count) - 1
        if indexPath.row == lastElement && loadingData == false {
            loadMoreData()
        }
    }
}

// MARK: - GroupCellDelegate

extension GroupViewController: GroupCellDelegate {
    
    func handleTapOnEditButton(group: Group) {
        let alert = UIAlertController(title: localizedString(key: "group_edit_name_alert_title"),
                                      message: localizedString(key: "group_edit_name_alert_message"),
                                      preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = group.name
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
                                        
                                        weakSelf?.processEditGroupName(withNewName: textField.text!, ofGroup: group)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleTapOnDeleteButton(group: Group) {
        let alert = UIAlertController(title: localizedString(key: "group_delete_confirm_title"),
                                      message: localizedString(key: "group_delete_confirm_message"),
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: localizedString(key: "common_no"),
                                      style: UIAlertActionStyle.default,
                                      handler: nil))
        
        alert.addAction(UIAlertAction(title: localizedString(key: "common_yes"),
                                      style: UIAlertActionStyle.default,
                                      handler: { (alert) in
                                        
                                        // show loading
                                        SVProgressHUD.show()
                                        
                                        NetworkManager.shared.deleteGroup(id: group.id, token: Utility.getToken()) {
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

