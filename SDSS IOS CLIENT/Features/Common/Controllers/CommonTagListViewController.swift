//
//  CommonTagListViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 04/05/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol CommonTagListViewControllerDelegate {
    func handleDoneButton(tagList: [Tag], selectedTagIdList: [String])
}

class CommonTagListViewController: BaseTableViewController {
    
    fileprivate var tagList: NSMutableArray = []
    var currentSelectedTagIdList: [String] = []
    
    fileprivate var pageInfo = PageInfo()
    fileprivate var loadingData = true
    
    var delegate: CommonTagListViewControllerDelegate?
        
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
        tagList.removeAllObjects()
        pageInfo = PageInfo()
        
        // call API get data
        loadMoreData()
    }
    
    fileprivate func loadMoreData() {
        if pageInfo.hasNext {
            loadingData = true
            
            // show loading
            SVProgressHUD.show()
            
            NetworkManager.shared.getTagList(token: Utility.getToken(),
                                             sort: "-updatedDate",
                                             page: pageInfo.current + 1,
                                             perPage: Network.perPage) {
                                                (success, tagList, pageInfo, message) in
                                                
                                                weak var weakSelf = self
                                                
                                                weakSelf?.refreshControl?.endRefreshing()
                                                
                                                // remove loading
                                                SVProgressHUD.dismiss()
                                                
                                                if (success) {
                                                    weakSelf?.tagList.addObjects(from: tagList!)
                                                    
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
        delegate?.handleDoneButton(tagList: tagList as! [Tag], selectedTagIdList: currentSelectedTagIdList)
    
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension CommonTagListViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tagList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommonTagCell", for: indexPath)
        
        let tag = tagList[indexPath.row] as! Tag
        cell.textLabel?.text = tag.value
        
        cell.accessoryType = UITableViewCellAccessoryType.none

        for selectedTagId in currentSelectedTagIdList {
            if tag.id == selectedTagId {
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
                break
            } 
        }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = (tagList.count) - 1
        if indexPath.row == lastElement && loadingData == false {
            loadMoreData()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let tag = tagList[indexPath.row] as! Tag
        if currentSelectedTagIdList.count == 0 {
            currentSelectedTagIdList.append(tag.id)
        } else {
            var isExist = false
            
            var count = 0
            
            for selectedTagId in currentSelectedTagIdList {
                if selectedTagId == tag.id {
                    isExist = true
                    currentSelectedTagIdList.remove(at: count)
                    break
                }
                count += 1
            }
            
            if isExist == false {
                currentSelectedTagIdList.append(tag.id)
            }
        }
        
        tableView.reloadData()
    }
}
