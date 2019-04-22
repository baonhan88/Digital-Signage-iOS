//
//  DatasetAddEditViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 12/12/2018.
//  Copyright © 2018 SLab. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol DatasetAddEditViewControllerDelegate {
    func handleAddDataset(dataset: Dataset)
    func handleEditDataset(dataset: Dataset)
}

class DatasetAddEditViewController: BaseTableViewController {

    var dataset: Dataset?
    var isEditMode: Bool = false
    
    var delegate: DatasetAddEditViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.tableView.register(UINib(nibName: "DatasetAddEditNameCell", bundle: nil), forCellReuseIdentifier: "DatasetAddEditNameCell")
        self.tableView.register(UINib(nibName: "DatasetAddEditTypeCell", bundle: nil), forCellReuseIdentifier: "DatasetAddEditTypeCell")
        self.tableView.register(UINib(nibName: "DatasetAddEditColumsCell", bundle: nil), forCellReuseIdentifier: "DatasetAddEditColumsCell")
        
        initNavigationBar()
        
        if dataset == nil {
            dataset = Dataset.init()
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    fileprivate func initNavigationBar() {
        self.title = localizedString(key: "dataset_add_title")
        
        let cancelButton = UIBarButtonItem.init(title: localizedString(key: "common_cancel"), style: .plain, target: self, action: #selector(cancelButtonClicked(barButton:)))
        let doneButton = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(doneButtonClicked(barButton:)))
        
        navigationItem.rightBarButtonItem = doneButton
        navigationItem.leftBarButtonItem = cancelButton
    }

}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension DatasetAddEditViewController {
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 2
        }
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 88
        }
        
        return 44
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return localizedString(key: "dataset_add_edit_description_header_title")
        } else if section == 1 {
            return localizedString(key: "dataset_add_edit_columns_header_title")
        }
        
        return ""
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 { // name
                let cell = tableView.dequeueReusableCell(withIdentifier: "DatasetAddEditNameCell") as? DatasetAddEditNameCell
                cell?.initViewWithName(name: (dataset?.name)!)
                cell?.delegate = self
                
                return cell!
            } else { // type
                let cell = tableView.dequeueReusableCell(withIdentifier: "DatasetAddEditTypeCell") as? DatasetAddEditTypeCell
                
                return cell!
            }
        } else { // columns
            let cell = tableView.dequeueReusableCell(withIdentifier: "DatasetAddEditColumsCell") as? DatasetAddEditColumsCell
            cell?.initViewWithColumns(columns: (dataset?.columns)!)
            cell?.delegate = self
            
            return cell!
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    fileprivate func isValidData() -> Bool {
        // check name
        if !Utility.isValidName(name: (dataset?.name)!) {
            Utility.showAlertWithErrorMessage(message: localizedString(key: "dataset_add_edit_name_invalid"),
                                              controller: self,
                                              completion: nil)
            return false
        }
        
        // check columns
        if dataset?.columns.count == 0 {
            Utility.showAlertWithErrorMessage(message: localizedString(key: "dataset_add_edit_columns_invalid"),
                                              controller: self,
                                              completion: nil)
            return false
        }
        
        for column in (dataset?.columns)! {
            if column.name == "" {
                Utility.showAlertWithErrorMessage(message: localizedString(key: "dataset_add_edit_columns_name_empty"),
                                                  controller: self,
                                                  completion: nil)
                return false
            }
        }
        
        return true
    }
 
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}

// MARK: - Handle Events

extension DatasetAddEditViewController {
    
    func cancelButtonClicked(barButton: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func doneButtonClicked(barButton: UIBarButtonItem) {
        dLog(message: "dataset = " + (dataset?.description)!)
        
        if (isValidData() == false) {
            return
        }
        
        if isEditMode {
            delegate?.handleEditDataset(dataset: dataset!)
        } else {
            delegate?.handleAddDataset(dataset: dataset!)
        }
        
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - DatasetAddEditNameCellDelegate

extension DatasetAddEditViewController: DatasetAddEditNameCellDelegate {
    
    func handleNameChanged(name: String) {
        dataset?.name = name
    }
}

// MARK: - DatasetAddEditColumsCellDelegate

extension DatasetAddEditViewController: DatasetAddEditColumsCellDelegate {
    
    func handleColumn1Changed(text: String) {
        if dataset?.columns.count == 0 {
            dataset?.initColumns()
        }
        
        let column1 = dataset?.columns[0]
        column1?.name = text
    }
    
    func handleColumn2Changed(text: String) {
        if dataset?.columns.count == 0 {
            dataset?.initColumns()
        }
        
        let column2 = dataset?.columns[1]
        column2?.name = text
    }
    
    func handleColumn3Changed(text: String) {
        if dataset?.columns.count == 0 {
            dataset?.initColumns()
        }
        
        let column3 = dataset?.columns[2]
        column3?.name = text
    }
    
    func handleColumn4Changed(text: String) {
        if dataset?.columns.count == 0 {
            dataset?.initColumns()
        }
        
        let column4 = dataset?.columns[3]
        column4?.name = text
    }
}
