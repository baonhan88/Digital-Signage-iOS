//
//  AssetFilterViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 22/10/2018.
//  Copyright © 2018 SLab. All rights reserved.
//

import UIKit

protocol AssetFilterViewControllerDelegate {
    func handleFilter(assetFilter: AssetFilter)
}

class AssetFilterViewController: BaseTableViewController {
    
    var assetFilter: AssetFilter = AssetFilter()
    
    var delegate: AssetFilterViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.tableView.register(UINib(nibName: "AssetFilterMinePublicCell", bundle: nil), forCellReuseIdentifier: "AssetFilterMinePublicCell")
        self.tableView.register(UINib(nibName: "AssetFilterTagCell", bundle: nil), forCellReuseIdentifier: "AssetFilterTagCell")
        self.tableView.register(UINib(nibName: "AssetFilterTypeCell", bundle: nil), forCellReuseIdentifier: "AssetFilterTypeCell")

        initNavigationBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func initNavigationBar() {
        self.title = localizedString(key: "filter_title")
        
        let cancelButton = UIBarButtonItem.init(title: localizedString(key: "common_cancel"), style: .plain, target: self, action: #selector(cancelButtonClicked(barButton:)))
        let doneButton = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(doneButtonClicked(barButton:)))
        
        navigationItem.rightBarButtonItem = doneButton
        navigationItem.leftBarButtonItem = cancelButton
    }

    func initController() {
        self.tableView.reloadData()
    }

}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension AssetFilterViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AssetFilterMinePublicCell") as? AssetFilterMinePublicCell
            
            cell?.initView(self.assetFilter)
            
            return cell!
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AssetFilterTypeCell") as? AssetFilterTypeCell
            
            cell?.initView(self.assetFilter)
            
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AssetFilterTagCell") as? AssetFilterTagCell
            
            cell?.initView(self.assetFilter)
            
            return cell!
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 1 {
            ControllerManager.showCommonTypeListScreen(controller: self, selectedTypeList: assetFilter.selectedTypeList)
        } else if (indexPath.row == 2) {
            ControllerManager.showCommonTagListScreen(controller: self, selectedTagIdList: assetFilter.selectedTagIdList)
        }
    }
}

// MARK: - Handle Events

extension AssetFilterViewController {
    
    func cancelButtonClicked(barButton: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func doneButtonClicked(barButton: UIBarButtonItem) {
        delegate?.handleFilter(assetFilter: self.assetFilter)
        
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - CommonTypeListViewControllerDelegate

extension AssetFilterViewController: CommonTypeListViewControllerDelegate {
    
    func handleDoneButton(typeList: [String], selectedTypeList: [String]) {
        assetFilter.typeList = typeList
        
        if selectedTypeList.count != 0 {
            assetFilter.selectedTypeList = selectedTypeList
            tableView.reloadData()
        }
    }
}

// MARK: - CommonTagListViewControllerDelegate

extension AssetFilterViewController: CommonTagListViewControllerDelegate {
    
    func handleDoneButton(tagList: [Tag], selectedTagIdList: [String]) {
        assetFilter.tagList = tagList
        
        if selectedTagIdList.count != 0 {
            assetFilter.selectedTagIdList = selectedTagIdList
            tableView.reloadData()
        }
    }
}
