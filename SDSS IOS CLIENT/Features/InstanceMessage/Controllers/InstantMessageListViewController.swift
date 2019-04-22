//
//  InstantMessageListViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 21/06/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import SVProgressHUD

class InstantMessageListViewController: BaseTableViewController {
    
    fileprivate var displayEventList: NSMutableArray = []
    fileprivate var pageInfo = PageInfo()
    fileprivate var loadingData = true
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.displayEventList = []
        
        self.refreshControl?.addTarget(self,
                                       action: #selector(handleRefresh),
                                       for: UIControlEvents.valueChanged)
        
        // register all cells
        self.tableView.register(UINib(nibName: "IMListCell", bundle: nil), forCellReuseIdentifier: "IMListCell")
        
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
        self.title = localizedString(key: "im_title")
        
        let addButton = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(addDisplayEventButtonClicked(barButton:)))
        navigationItem.rightBarButtonItem = addButton
    }
    
    func handleRefresh() {
        // reset all data
        displayEventList.removeAllObjects()
        pageInfo = PageInfo()
        
        // call API get data
        loadMoreData()
    }
    
    fileprivate func loadMoreData() {
        if pageInfo.hasNext {
            loadingData = true
            
            // show loading
            SVProgressHUD.show()
            
            NetworkManager.shared.getDisplayEventList(token: Utility.getToken(),
                                                      sort: "-updatedDate",
                                                      page: pageInfo.current + 1,
                                                      perPage: Network.perPage) {
                                                        (success, displayEventList, pageInfo, message) in
                                                    
                                                        weak var weakSelf = self
                                                    
                                                        weakSelf?.refreshControl?.endRefreshing()
                                                        
                                                        // remove loading
                                                        SVProgressHUD.dismiss()
                                                        
                                                        if (success) {
                                                            weakSelf?.displayEventList.addObjects(from: displayEventList!)
                                                            
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

// MARK: - Handle Events

extension InstantMessageListViewController {
    
    func addDisplayEventButtonClicked(barButton: UIBarButtonItem) {
        ControllerManager.showInstantMessageScreen(controller: self, displayEvent: nil)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension InstantMessageListViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (displayEventList.count)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IMListCell") as? IMListCell
        cell?.delegate = self
        
        if displayEventList.count > 0 {
            cell?.initView(displayEventList[indexPath.row] as! DisplayEvent)
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = (displayEventList.count) - 1
        if indexPath.row == lastElement && loadingData == false {
            loadMoreData()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - PlayListCellDelegate

extension InstantMessageListViewController: IMListCellDelegate {
    
    func handleTapOnEditButton(displayEvent: DisplayEvent) {
        ControllerManager.showInstantMessageScreen(controller: self, displayEvent: displayEvent)
    }
    
    func handleTapOnDeleteButton(displayEvent: DisplayEvent) {
        let alert = UIAlertController(title: localizedString(key: "im_list_delete_confirm_title"),
                                      message: localizedString(key: "im_list_delete_confirm_message"),
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: localizedString(key: "common_no"),
                                      style: UIAlertActionStyle.default,
                                      handler: nil))
        
        alert.addAction(UIAlertAction(title: localizedString(key: "common_yes"),
                                      style: UIAlertActionStyle.default,
                                      handler: { (alert) in
                                        
                                        // show loading
                                        SVProgressHUD.show()
                                        
                                        NetworkManager.shared.deleteDisplayEvent(id: displayEvent.id, token: Utility.getToken()) {
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
