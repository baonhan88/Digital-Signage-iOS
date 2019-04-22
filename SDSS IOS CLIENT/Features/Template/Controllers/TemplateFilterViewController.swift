//
//  TemplateFilterViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 22/10/2018.
//  Copyright © 2018 SLab. All rights reserved.
//

import UIKit

protocol TemplateFilterViewControllerDelegate {
    func handleFilter(templateFilter: TemplateFilter)
}

class TemplateFilterViewController: BaseTableViewController {
    
    var templateFilter: TemplateFilter = TemplateFilter()
    
    var delegate: TemplateFilterViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.tableView.register(UINib(nibName: "TemplateMinePublicLockCell", bundle: nil), forCellReuseIdentifier: "TemplateMinePublicLockCell")
        self.tableView.register(UINib(nibName: "TemplateCatetoryCell", bundle: nil), forCellReuseIdentifier: "TemplateCatetoryCell")
        self.tableView.register(UINib(nibName: "TemplateTagCell", bundle: nil), forCellReuseIdentifier: "TemplateTagCell")

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

extension TemplateFilterViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TemplateMinePublicLockCell") as? TemplateMinePublicLockCell
            
            cell?.initViewWithTemplateFilter(templateFilter)
            
            return cell!
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TemplateCatetoryCell") as? TemplateCatetoryCell
            
            cell?.initViewWithTemplateFilter(templateFilter)
            
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TemplateTagCell") as? TemplateTagCell
            
            cell?.initViewWithTemplateFilter(templateFilter)
            
            return cell!
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 1 {
            ControllerManager.showCommonGroupListScreen(controller: self, selectedGroup: templateFilter.group)
        } else if (indexPath.row == 2) {
            ControllerManager.showCommonTagListScreen(controller: self, selectedTagIdList: templateFilter.selectedTagIdList)
        }
    }
}

// MARK: - Handle Events

extension TemplateFilterViewController {
    
    func cancelButtonClicked(barButton: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func doneButtonClicked(barButton: UIBarButtonItem) {
        delegate?.handleFilter(templateFilter: templateFilter)
        
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - CommonGroupListViewControllerDelegate

extension TemplateFilterViewController: CommonGroupListViewControllerDelegate {
    
    func handleDoneButton(selectedGroup: Group?) {
        if selectedGroup != nil {
            templateFilter.group = selectedGroup!
            tableView.reloadData()
        }
    }
}

// MARK: - CommonTagListViewControllerDelegate

extension TemplateFilterViewController: CommonTagListViewControllerDelegate {
    
    func handleDoneButton(tagList: [Tag], selectedTagIdList: [String]) {
        templateFilter.tagList = tagList
        
        if selectedTagIdList.count != 0 {
            templateFilter.selectedTagIdList = selectedTagIdList
            tableView.reloadData()
        }
    }
}
