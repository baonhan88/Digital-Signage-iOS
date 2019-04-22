//
//  CommonTypeListViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 04/05/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol CommonTypeListViewControllerDelegate {
    func handleDoneButton(typeList: [String], selectedTypeList: [String])
}

class CommonTypeListViewController: BaseTableViewController {
    
    fileprivate var typeList: NSMutableArray = []
    var currentSelectedTypeList: [String] = []
    
    var delegate: CommonTypeListViewControllerDelegate?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavigationBar()
        
        // init type list
        typeList.add("IMAGE")
        typeList.add("VIDEO")
        typeList.add("AUDIO")
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
    
    func doneButtonClicked(barButton: UIBarButtonItem) {
        delegate?.handleDoneButton(typeList: typeList as! [String], selectedTypeList: currentSelectedTypeList)
    
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension CommonTypeListViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return typeList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommonTypeCell", for: indexPath)
        
        let type: String = typeList[indexPath.row] as! String
        cell.textLabel?.text = type
        
        cell.accessoryType = UITableViewCellAccessoryType.none

        for selectedType in currentSelectedTypeList {
            if type == selectedType {
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
                break
            } 
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let type: String = typeList[indexPath.row] as! String
        if currentSelectedTypeList.count == 0 {
            currentSelectedTypeList.append(type)
        } else {
            var isExist = false
            
            var count = 0
            
            for selectedType in currentSelectedTypeList {
                if selectedType == type {
                    isExist = true
                    currentSelectedTypeList.remove(at: count)
                    break
                }
                count += 1
            }
            
            if isExist == false {
                currentSelectedTypeList.append(type)
            }
        }
        
        tableView.reloadData()
    }
}
