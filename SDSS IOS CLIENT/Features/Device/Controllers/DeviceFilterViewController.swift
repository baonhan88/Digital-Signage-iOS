//
//  DeviceFilterViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 22/10/2018.
//  Copyright © 2018 SLab. All rights reserved.
//

import UIKit

protocol DeviceFilterViewControllerDelegate {
    func handleFilter(deviceFilter: DeviceFilter)
}

class DeviceFilterViewController: BaseTableViewController {
    
    var deviceFilter: DeviceFilter = DeviceFilter()
    
    var delegate: DeviceFilterViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.tableView.register(UINib(nibName: "DeviceFilterSelectAllCell", bundle: nil), forCellReuseIdentifier: "DeviceFilterSelectAllCell")
        self.tableView.register(UINib(nibName: "DeviceFilterCatetoryCell", bundle: nil), forCellReuseIdentifier: "DeviceFilterCatetoryCell")
        self.tableView.register(UINib(nibName: "DeviceFilterMineOnlineCell", bundle: nil), forCellReuseIdentifier: "DeviceFilterMineOnlineCell")

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

extension DeviceFilterViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceFilterSelectAllCell") as? DeviceFilterSelectAllCell
            
            cell?.initView(deviceFilter)
            
            return cell!
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceFilterMineOnlineCell") as? DeviceFilterMineOnlineCell
            
            cell?.initView(deviceFilter)
            
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceFilterCatetoryCell") as? DeviceFilterCatetoryCell
            
            cell?.initView(deviceFilter)
            
            return cell!
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 2 {
            ControllerManager.showCommonGroupListScreen(controller: self, selectedGroup: deviceFilter.group)
        }
    }
}

// MARK: - Handle Events

extension DeviceFilterViewController {
    
    func cancelButtonClicked(barButton: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func doneButtonClicked(barButton: UIBarButtonItem) {
        delegate?.handleFilter(deviceFilter: deviceFilter)
        
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - CommonGroupListViewControllerDelegate

extension DeviceFilterViewController: CommonGroupListViewControllerDelegate {
    
    func handleDoneButton(selectedGroup: Group?) {
        if selectedGroup != nil {
            deviceFilter.group = selectedGroup!
            tableView.reloadData()
        }
    }
}
