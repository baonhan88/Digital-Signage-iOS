//
//  CommonGroupListViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 04/05/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol CommonGroupListViewControllerDelegate {
    func handleDoneButton(selectedGroup:Group?)
}

class CommonGroupListViewController: BaseTableViewController {
    
    fileprivate var groupList: NSMutableArray = []
    var currentGroup: Group = Group()
    
    fileprivate var pageInfo = PageInfo()
    fileprivate var loadingData = true
    
    var delegate: CommonGroupListViewControllerDelegate?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavigationBar()
        
        self.refreshControl?.addTarget(self,
                                       action: #selector(handleRefresh),
                                       for: UIControlEvents.valueChanged)
        // load data
        loadMoreData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func initNavigationBar() {
        // init done icon
        let doneButton   = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonClicked(barButton:)))
        navigationItem.rightBarButtonItem = doneButton
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
    
    
    func doneButtonClicked(barButton: UIBarButtonItem) {
        delegate?.handleDoneButton(selectedGroup: currentGroup)
    
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension CommonGroupListViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommonGroupCell", for: indexPath)
        
        let group = groupList[indexPath.row] as! Group
        cell.textLabel?.text = group.name
        if group.id == currentGroup.id {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = (groupList.count) - 1
        if indexPath.row == lastElement && loadingData == false {
            loadMoreData()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentGroup = groupList[indexPath.row] as! Group
        tableView.reloadData()
    }
}
