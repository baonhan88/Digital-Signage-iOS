//
//  DeviceSettingViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 22/10/2018.
//  Copyright © 2018 SLab. All rights reserved.
//

import UIKit

protocol DeviceSettingViewControllerDelegate {
    func handleSettingChanged(device: Device)
}

class DeviceSettingViewController: BaseTableViewController {
    
    var device: Device?
    
    var delegate: DeviceSettingViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.tableView.register(UINib(nibName: "DeviceSettingNameCell", bundle: nil), forCellReuseIdentifier: "DeviceSettingNameCell")
        self.tableView.register(UINib(nibName: "DeviceSettingCatetoryCell", bundle: nil), forCellReuseIdentifier: "DeviceSettingCatetoryCell")
        self.tableView.register(UINib(nibName: "DeviceSettingAutoFitCell", bundle: nil), forCellReuseIdentifier: "DeviceSettingAutoFitCell")

        initNavigationBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func initNavigationBar() {
        self.title = localizedString(key: "device_setting_title")
        
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

extension DeviceSettingViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceSettingNameCell") as? DeviceSettingNameCell
            
            cell?.initView(device!)
            
            return cell!
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceSettingCatetoryCell") as? DeviceSettingCatetoryCell
            
            cell?.initView(device!)
            
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceSettingAutoFitCell") as? DeviceSettingAutoFitCell
            
            cell?.initView(device!)
            
            return cell!
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 1 {
            ControllerManager.showCommonGroupListScreen(controller: self, selectedGroup: (device?.group)!)
        }
    }
}

// MARK: - Handle Events

extension DeviceSettingViewController {
    
    func cancelButtonClicked(barButton: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func doneButtonClicked(barButton: UIBarButtonItem) {
        delegate?.handleSettingChanged(device: device!)
        
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - CommonGroupListViewControllerDelegate

extension DeviceSettingViewController: CommonGroupListViewControllerDelegate {
    
    func handleDoneButton(selectedGroup: Group?) {
        if selectedGroup != nil {
            device?.group = selectedGroup!
            tableView.reloadData()
        }
    }
}
