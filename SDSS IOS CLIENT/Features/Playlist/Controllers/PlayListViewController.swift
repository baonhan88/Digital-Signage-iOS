//
//  PlayListViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 21/06/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import SVProgressHUD

class PlayListViewController: BaseTableViewController {
    
    fileprivate var playList: NSMutableArray = []
    fileprivate var pageInfo = PageInfo()
    fileprivate var loadingData = true
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.playList = []
        
        self.refreshControl?.addTarget(self,
                                       action: #selector(handleRefresh),
                                       for: UIControlEvents.valueChanged)
        
        // register all cells
        self.tableView.register(UINib(nibName: "PlayListCell", bundle: nil), forCellReuseIdentifier: "PlayListCell")
        
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
        self.title = localizedString(key: "playlist_title")
        
//        let addButton = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(addPlayListButtonClicked(barButton:)))
//        navigationItem.rightBarButtonItem = addButton
    }
    
    func handleRefresh() {
        // reset all data
        playList.removeAllObjects()
        pageInfo = PageInfo()
        
        // call API get data
        loadMoreData()
    }
    
    fileprivate func loadMoreData() {
        if pageInfo.hasNext {
            loadingData = true
            
            // show loading
            SVProgressHUD.show()
            
            NetworkManager.shared.getPlayList(token: Utility.getToken(),
                                              sort: "-updatedDate",
                                              page: pageInfo.current + 1,
                                              perPage: Network.perPage) {
                                                    (success, playList, pageInfo, message) in
                                                    
                                                    weak var weakSelf = self
                                                    
                                                    weakSelf?.refreshControl?.endRefreshing()
                                                    
                                                    // remove loading
                                                    SVProgressHUD.dismiss()
                                                    
                                                    if (success) {
                                                        weakSelf?.playList.addObjects(from: playList!)
                                                        
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
    
    fileprivate func processEditPlayListName(withNewName name: String, ofPlayList playList: PlayList) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        if !Utility.isValidName(name: trimmedName) {
            Utility.showAlertWithErrorMessage(message: localizedString(key: "playlist_edit_name_invalid"),
                                              controller: self,
                                              completion: nil)
            return
        }
        
        // show loading
        SVProgressHUD.show()
        
        NetworkManager.shared.editNamePlayList(id: playList.id, name: trimmedName, token: Utility.getToken()) {
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

extension PlayListViewController {
    
    func addPlayListButtonClicked(barButton: UIBarButtonItem) {
        let alert = UIAlertController(title: localizedString(key: "playlist_add_alert_title"),
                                      message: localizedString(key: "playlist_add_alert_message"),
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
                                            Utility.showAlertWithErrorMessage(message: localizedString(key: "playlist_edit_name_invalid"),
                                                                              controller: weakSelf!,
                                                                              completion: nil)
                                            return
                                        }
                                        
                                        // show loading
                                        SVProgressHUD.show()
                                        
                                        NetworkManager.shared.addPlayList(name: textField.text!, token: Utility.getToken(), completion: {
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

extension PlayListViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (playList.count)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayListCell") as? PlayListCell
        cell?.delegate = self
        
        if playList.count > 0 {
            cell?.initViewWithPlayList(playList[indexPath.row] as! PlayList)
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = (playList.count) - 1
        if indexPath.row == lastElement && loadingData == false {
            loadMoreData()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        ControllerManager.goToPlayListDetailScreen(playList: playList[indexPath.row] as! PlayList, controller: self)
    }
}

// MARK: - PlayListCellDelegate

extension PlayListViewController: PlayListCellDelegate {
    
    func handleTapOnEditButton(playList: PlayList) {
        let alert = UIAlertController(title: localizedString(key: "playlist_edit_name_alert_title"),
                                      message: localizedString(key: "playlist_edit_name_alert_message"),
                                      preferredStyle: .alert)
        
        alert.addTextField { (textField) in            
            textField.text = playList.name
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
                                        
                                        weakSelf?.processEditPlayListName(withNewName: textField.text!, ofPlayList: playList)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleTapOnDeleteButton(playList: PlayList) {
        let alert = UIAlertController(title: localizedString(key: "playlist_delete_confirm_title"),
                                      message: localizedString(key: "playlist_delete_confirm_message"),
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: localizedString(key: "common_no"),
                                      style: UIAlertActionStyle.default,
                                      handler: nil))
        
        alert.addAction(UIAlertAction(title: localizedString(key: "common_yes"),
                                      style: UIAlertActionStyle.default,
                                      handler: { (alert) in
                                        
                                        // show loading
                                        SVProgressHUD.show()
                                        
                                        NetworkManager.shared.deletePlayList(id: playList.id, token: Utility.getToken()) {
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
