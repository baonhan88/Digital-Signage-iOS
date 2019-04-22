//
//  CommonSelectionViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 04/05/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

protocol CommonSelectionViewControllerDelegate {
    func handleDoneButton(currentSelectionIndex: Int, selectionType: SelectionType)
}

enum SelectionType {
    case duration
    case fontName
    case linePattern
}

class CommonSelectionViewController: BaseTableViewController {
    
    var selectionList: NSArray = []
    var currentSelection: Int = 0
    var currentType: SelectionType = SelectionType.duration
    
    var delegate: CommonSelectionViewControllerDelegate?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavigationBar()
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
        delegate?.handleDoneButton(currentSelectionIndex: currentSelection, selectionType: currentType)
        
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension CommonSelectionViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectionList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommonSelectionCell", for: indexPath)
        
        cell.textLabel?.text = selectionList[indexPath.row] as? String
        if indexPath.row == currentSelection {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentSelection = indexPath.row
        tableView.reloadData()
    }
}
