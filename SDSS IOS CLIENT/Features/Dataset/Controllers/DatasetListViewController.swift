//
//  DatasetListViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 21/06/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import SVProgressHUD

class DatasetListViewController: BaseTableViewController {
    
    fileprivate var datasetList: NSMutableArray = []
    fileprivate var pageInfo = PageInfo()
    fileprivate var loadingData = true
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.datasetList = []
        
        self.refreshControl?.addTarget(self,
                                       action: #selector(handleRefresh),
                                       for: UIControlEvents.valueChanged)
        
        // register all cells
        self.tableView.register(UINib(nibName: "DatasetListCell", bundle: nil), forCellReuseIdentifier: "DatasetListCell")
        
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
        self.title = localizedString(key: "dataset_title")
        
        let addButton = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(addDatasetButtonClicked(barButton:)))
        navigationItem.rightBarButtonItem = addButton
    }
    
    func handleRefresh() {
        // reset all data
        datasetList.removeAllObjects()
        pageInfo = PageInfo()
        
        // call API get data
        loadMoreData()
    }
    
    fileprivate func loadMoreData() {
        if pageInfo.hasNext {
            loadingData = true
            
            // show loading
            SVProgressHUD.show()
            
            NetworkManager.shared.getDatasetList(filter: "", // filter should be empty now -> will apply later,
                                                 sort: "-updatedDate",
                                                 token: Utility.getToken(),
                                                 page: pageInfo.current + 1,
                                                 perPage: Network.perPage) {
                                                    (success, playList, pageInfo, message) in
                                                    
                                                    weak var weakSelf = self
                                                    
                                                    weakSelf?.refreshControl?.endRefreshing()
                                                    
                                                    // remove loading
                                                    SVProgressHUD.dismiss()
                                                    
                                                    if (success) {
                                                        weakSelf?.datasetList.addObjects(from: playList!)
                                                        
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

extension DatasetListViewController {
    
    func addDatasetButtonClicked(barButton: UIBarButtonItem) {
        ControllerManager.showDatasetAddEditScreen(controller: self, dataset: nil)
        
//        let alert = UIAlertController(title: localizedString(key: "playlist_add_alert_title"),
//                                      message: localizedString(key: "playlist_add_alert_message"),
//                                      preferredStyle: .alert)
//        
//        alert.addTextField { (textField) in
//            
//        }
//        
//        alert.addAction(UIAlertAction(title: localizedString(key: "common_cancel"),
//                                      style: .default,
//                                      handler: nil))
//        
//        alert.addAction(UIAlertAction(title: localizedString(key: "common_ok"),
//                                      style: .default,
//                                      handler: { [weak alert] (_) in
//                                        
//                                        weak var weakSelf = self
//                                        
//                                        guard let textField = alert?.textFields![0] else {
//                                            return
//                                        }
//                                        
//                                        if !Utility.isValidName(name: textField.text!) {
//                                            Utility.showAlertWithErrorMessage(message: localizedString(key: "playlist_edit_name_invalid"),
//                                                                              controller: weakSelf!,
//                                                                              completion: nil)
//                                            return
//                                        }
//                                        
//                                        // show loading
//                                        SVProgressHUD.show()
//                                        
//                                        NetworkManager.shared.addPlayList(name: textField.text!, token: Utility.getToken(), completion: {
//                                            (success, id, message) in
//                                            
//                                            weak var weakSelf = self
//                                            
//                                            // remove loading
//                                            SVProgressHUD.dismiss()
//                                            
//                                            if (success) {
//                                                // refresh data
//                                                weakSelf?.handleRefresh()
//                                                
//                                            } else {
//                                                // show error message
//                                                Utility.showAlertWithErrorMessage(message: message, controller: self, completion: nil)
//                                            }
//                                        })
//        }))
//        
//        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension DatasetListViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (datasetList.count)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DatasetListCell") as? DatasetListCell
        cell?.delegate = self
        
        if datasetList.count > 0 {
            cell?.initViewWithDataset(datasetList[indexPath.row] as! Dataset)
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = (datasetList.count) - 1
        if indexPath.row == lastElement && loadingData == false {
            loadMoreData()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        ControllerManager.showDatasetRowUpdateScreen(controller: self, dataset: datasetList[indexPath.row] as! Dataset)
    }
}

// MARK: - DatasetListCellDelegate

extension DatasetListViewController: DatasetListCellDelegate {
    
    func handleTapOnEditButton(dataset: Dataset) {
        ControllerManager.showDatasetAddEditScreen(controller: self, dataset: dataset)
    }
    
    func handleTapOnDeleteButton(dataset: Dataset) {
        let alert = UIAlertController(title: localizedString(key: "dataset_delete_confirm_title"),
                                      message: localizedString(key: "dataset_delete_confirm_message"),
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: localizedString(key: "common_no"),
                                      style: UIAlertActionStyle.default,
                                      handler: nil))
        
        alert.addAction(UIAlertAction(title: localizedString(key: "common_yes"),
                                      style: UIAlertActionStyle.default,
                                      handler: { (alert) in
                                        
                                        // show loading
                                        SVProgressHUD.show()
                                        
                                        NetworkManager.shared.deleteDataset(id: dataset.id, token: Utility.getToken()) {
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

// MARK: - DatasetAddEditViewControllerDelegate

extension DatasetListViewController: DatasetAddEditViewControllerDelegate {
    
    func handleAddDataset(dataset: Dataset) {
        // show loading
        SVProgressHUD.show()
        
        NetworkManager.shared.addDataset(dataset: dataset, token: Utility.getToken(), completion: {
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
    }
    
    func handleEditDataset(dataset: Dataset) {
        // show loading
        SVProgressHUD.show()
        
        NetworkManager.shared.updateDataset(id: dataset.id, name: dataset.name, columns: dataset.columns, data: nil, token: Utility.getToken(), completion: {
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
        })

    }
}
