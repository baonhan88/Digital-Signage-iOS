//
//  DatasetRowUpdateViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 21/06/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import SVProgressHUD

class DatasetRowUpdateViewController: UITableViewController {
    
    var dataset: Dataset?
    
    fileprivate var needUpdatePresentationList: NSMutableArray = NSMutableArray.init()
    fileprivate var currentUploadPresentationIndex = 0
    fileprivate var pinCodeJsonString = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register all cells
        self.tableView.register(UINib(nibName: "DatasetRowUpdateCell", bundle: nil), forCellReuseIdentifier: "DatasetRowUpdateCell")
        
        // init navigation bar
        initNavigationBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func initNavigationBar() {
        let sendButton = UIBarButtonItem(image: UIImage(named: "icon_send.png"),  style: .plain, target: self, action: #selector(sendButtonClicked(barButton:)))
        let addButton = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(addButtonClicked(barButton:)))
        navigationItem.rightBarButtonItems = [self.editButtonItem, addButton, sendButton]
    }
    
    fileprivate func isValidDurationData(duration: String) -> Bool {
        if duration == "" {
            return true
        }
        
        let letterCharacters = CharacterSet.letters
        let letterRange = duration.rangeOfCharacter(from: letterCharacters)
        
        if letterRange != nil {
            return false
        }
        return true
    }
    
    fileprivate func callAPItoUpdateData() {        
        // show loading
        SVProgressHUD.show()
        
        NetworkManager.shared.updateDataset(id: (dataset?.id)!, name: nil, columns: nil, data: dataset?.dataList, token: Utility.getToken(), completion: {
            (success, message) in
            
            weak var weakSelf = self
            
            // remove loading
            SVProgressHUD.dismiss()
            
            if (success) {
                // reload view
                weakSelf?.tableView.reloadData()
                
            } else {
                // show error message
                Utility.showAlertWithErrorMessage(message: message, controller: self, completion: nil)
            }
        })
    }

}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension DatasetRowUpdateViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (dataset?.dataList.count)!
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DatasetRowUpdateCell") as? DatasetRowUpdateCell
        
        if (dataset?.dataList.count)! > 0 {
            cell?.initViewWithData(datasetData: (dataset?.dataList[indexPath.row])!)
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            dataset?.dataList.remove(at: indexPath.row)
            
            // call API to update new data
            callAPItoUpdateData()
        }
    }
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let itemToMove = dataset?.dataList[fromIndexPath.row]
        dataset?.dataList.remove(at: fromIndexPath.row)
        dataset?.dataList.insert(itemToMove!, at: to.row)
        
        // call API to update new data
        callAPItoUpdateData()
    }
    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
}

// MARK: - Handle Events

extension DatasetRowUpdateViewController {
    
    func addButtonClicked(barButton: UIBarButtonItem) {
        // Create the alert controller.
        let alert = UIAlertController(title: "",
                                      message: "",
                                      preferredStyle: .alert)
        
        // Add Customer text field
        alert.addTextField { (textField) in
            textField.placeholder = localizedString(key: "dataset_row_update_add_new_row_customer")
            textField.keyboardType = UIKeyboardType.alphabet
        }
        
        // Add Time text field
        alert.addTextField { (textField) in
            textField.placeholder = localizedString(key: "dataset_row_update_add_new_row_time")
            textField.keyboardType = UIKeyboardType.alphabet
        }
        
        // Add Slot text field
        alert.addTextField { (textField) in
            textField.placeholder = localizedString(key: "dataset_row_update_add_new_row_slot")
            textField.keyboardType = UIKeyboardType.alphabet
        }
        
        // Add Area text field
        alert.addTextField { (textField) in
            textField.placeholder = localizedString(key: "dataset_row_update_add_new_row_area")
            textField.keyboardType = UIKeyboardType.alphabet
        }
        
        // add cancel action
        alert.addAction(UIAlertAction(title: localizedString(key: "common_cancel"), style: .cancel, handler: { (_) in
            // just dismiss alert
        }))
        
        // add OK action
        alert.addAction(UIAlertAction(title: localizedString(key: "common_ok"), style: .default, handler: { [weak alert] (_) in
            weak var weakSelf = self
            
            let customerTextField = alert?.textFields![0] // Force unwrapping because we know it exists.
            let timeTextField = alert?.textFields![1] // Force unwrapping because we know it exists.
            let slotTextField = alert?.textFields![2] // Force unwrapping because we know it exists.
            let areaTextField = alert?.textFields![3] // Force unwrapping because we know it exists.
            
            if customerTextField?.text == "" || timeTextField?.text == "" || slotTextField?.text == "" || areaTextField?.text == "" {
                Utility.showAlertWithErrorMessage(message: localizedString(key: "dataset_row_update_add_new_row_empty"), controller: weakSelf!)
                return
            }
            
            let newRow: DatasetData = DatasetData.init(customer: (customerTextField?.text)!, time: (timeTextField?.text)!, slot: (slotTextField?.text)!, area: (areaTextField?.text)!)
            
            weakSelf?.dataset?.dataList.append(newRow)
            
            // call API to update new list
            weakSelf?.callAPItoUpdateData()
            
        }))
        
        // Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    func sendButtonClicked(barButton: UIBarButtonItem) {
        ControllerManager.goToCloudDeviceListScreen(currentDeviceListType: .dataset, controller: self)
    }
}

// MARK: - Handle send Dataset to Cloud

extension DatasetRowUpdateViewController {
    
    fileprivate func processCallAPItoSendDataset() {
        SVProgressHUD.show()
        
        NetworkManager.shared.controlDeviceToPlay(pinCodeList: self.pinCodeJsonString, contentId: (dataset?.id)!, contentType: ContentType.dataset.name(), contentName: (dataset?.name)!, contentData: nil, token: Utility.getToken()) {
            (success, message) in
            
            weak var weakSelf = self
            
            SVProgressHUD.dismiss()
            
            if success {
                SVProgressHUD.showSuccess(withStatus: localizedString(key: "common_sent"))
            } else {
                Utility.showAlertWithErrorMessage(message: message, controller: weakSelf!)
            }
        }
    }
}

// MARK: - CloudDeviceListViewControllerDelegate

extension DatasetRowUpdateViewController: CloudDeviceListViewControllerDelegate {
    
    func handleSendDataset(pinCodeJsonString: String) {
        self.pinCodeJsonString = pinCodeJsonString
        processCallAPItoSendDataset()
    }
}
