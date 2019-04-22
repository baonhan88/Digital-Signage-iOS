//
//  AssetEditViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 22/10/2018.
//  Copyright © 2018 SLab. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol AssetEditViewControllerDelegate {
    func handleEditAsset(assetDetail: AssetDetail)
}

class AssetEditViewController: BaseTableViewController {
    
    var assetDetail: AssetDetail = AssetDetail()
    
    var delegate: AssetEditViewControllerDelegate?
    
    var tagList: NSMutableArray = NSMutableArray.init()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.tableView.register(UINib(nibName: "AssetEditNameCell", bundle: nil), forCellReuseIdentifier: "AssetEditNameCell")
        self.tableView.register(UINib(nibName: "AssetEditTagCell", bundle: nil), forCellReuseIdentifier: "AssetEditTagCell")

        initNavigationBar()
        
        getTagList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func initNavigationBar() {
        self.title = localizedString(key: "asset_edit_title")
        
        let cancelButton = UIBarButtonItem.init(title: localizedString(key: "common_cancel"), style: .plain, target: self, action: #selector(cancelButtonClicked(barButton:)))
        let doneButton = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(doneButtonClicked(barButton:)))
        
        navigationItem.rightBarButtonItem = doneButton
        navigationItem.leftBarButtonItem = cancelButton
    }

    func initController() {
        self.tableView.reloadData()
    }
    
    func getTagList() {
        // show loading
        SVProgressHUD.show()
        
        NetworkManager.shared.getTagList(token: Utility.getToken(),
                                         sort: "-updatedDate",
                                         page: 1,
                                         perPage: Network.perPage) {
                                            (success, tagList, pageInfo, message) in
                                            
                                            weak var weakSelf = self
                                            
                                            // remove loading
                                            SVProgressHUD.dismiss()
                                            
                                            if (success) {
                                                weakSelf?.tagList.addObjects(from: tagList!)
                                            
                                            } else {
                                                // show error message
                                                Utility.showAlertWithErrorMessage(message: message, controller: self, completion: nil)
                                            }
        }

    }

}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension AssetEditViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AssetEditNameCell") as? AssetEditNameCell
            
            cell?.initView(assetDetail.name)
            cell?.delegate = self
            
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AssetEditTagCell") as? AssetEditTagCell
            
            cell?.initView(assetDetail.tags, tagList: self.tagList as! [Tag])
            
            return cell!
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 1 {
            ControllerManager.showCommonTagListScreen(controller: self, selectedTagIdList: assetDetail.tags)
        }
    }
}

// MARK: - Handle Events

extension AssetEditViewController {
    
    func cancelButtonClicked(barButton: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func doneButtonClicked(barButton: UIBarButtonItem) {
        delegate?.handleEditAsset(assetDetail: assetDetail)
        
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - CommonTagListViewControllerDelegate

extension AssetEditViewController: CommonTagListViewControllerDelegate {
    
    func handleDoneButton(tagList: [Tag], selectedTagIdList: [String]) {
        self.tagList = tagList as! NSMutableArray
        
        if selectedTagIdList.count != 0 {
            self.assetDetail.tags = selectedTagIdList
            
            tableView.reloadData()
        }
    }
}

// MARK: - AssetEditNameCellDelegate

extension AssetEditViewController: AssetEditNameCellDelegate {
    
    func handleAssetNameChanged(assetName: String) {
        assetDetail.name = assetName
        
        tableView.reloadData()
    }
}
