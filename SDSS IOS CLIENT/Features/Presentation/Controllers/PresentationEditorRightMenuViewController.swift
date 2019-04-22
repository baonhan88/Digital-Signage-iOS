//
//  PresentationEditorRightMenuViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 30/05/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

protocol PresentationEditorRightMenuViewControllerDelegate {
    func handleChooseMediaWithRegion(region: Region)
}

class PresentationEditorRightMenuViewController: BaseTableViewController {

    fileprivate var regionList: [Region] = []
    
    // input value
    var currentPresentationId: String = ""
    var isComeFromTemplate: Bool = true
    var folderName: String = ""
    
    var delegate: PresentationEditorRightMenuViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register all cells
        self.tableView.registerCellNib(PresentationEditorRightMenuCell.self)
        
        // load data
        self.loadLocalPresentationData(shouldLoadFromTmpFolder: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func loadLocalPresentationData(shouldLoadFromTmpFolder: Bool) {
        var fileURL: URL?
        
        if shouldLoadFromTmpFolder {
            // first load from tmp folder (include some changes), if not exist (no change anymore) will load from root design file
            if isComeFromTemplate {
                fileURL = Utility.getUrlFromDocumentWithAppend(url: Dir.savePresentation + folderName + "/" + Dir.tmpFolderName + "/" + folderName + Dir.presentationDesignExtension)
                if !FileManager.default.fileExists(atPath: (fileURL?.path)!) {
                    fileURL = Utility.getUrlFromDocumentWithAppend(url: Dir.template + currentPresentationId + Dir.presentationDesignExtension)
                }
            } else {
                fileURL = Utility.getUrlFromDocumentWithAppend(url: Dir.savePresentation + folderName + "/" + Dir.tmpFolderName + "/" + folderName + Dir.presentationDesignExtension)
                if !FileManager.default.fileExists(atPath: (fileURL?.path)!) {
                    fileURL = Utility.getUrlFromDocumentWithAppend(url: Dir.savePresentation + folderName + "/" + currentPresentationId + Dir.presentationDesignExtension)
                }
            }
        } else {
            if isComeFromTemplate {
                fileURL = Utility.getUrlFromDocumentWithAppend(url: Dir.template + currentPresentationId + Dir.presentationDesignExtension)
            } else {
                fileURL = Utility.getUrlFromDocumentWithAppend(url: Dir.savePresentation + folderName + "/" + currentPresentationId + Dir.presentationDesignExtension)
            }
        }
        
        if FileManager.default.fileExists(atPath: (fileURL?.path)!) {
            do {
                let jsonData = NSData(contentsOfFile: (fileURL?.path)!)
                let jsonDict = try JSONSerialization.jsonObject(with: jsonData! as Data, options: .mutableContainers) as! NSDictionary
                
                guard let regionDictList = jsonDict[DesignFile.paramRegions] else {
                    Utility.showAlertWithErrorMessage(message: localizedString(key: "presentation_editor_load_local_data_error"), controller: self)
                    return
                }
                
                let tmpRegionList = NSMutableArray()
                for regionDict in regionDictList as! [NSDictionary] {
                    let region = Region(dictionary: regionDict)
                    tmpRegionList.add(region)
                }
                regionList = tmpRegionList as! [Region]
                
            } catch {
                dLog(message: error.localizedDescription)
            }
        } else {
            dLog(message: "designFile not exist at path \(String(describing: fileURL?.path))")
        }
        
        // reload tablewview
        self.tableView.reloadData()
    }
}

// MARK: - UITableViewDatasource & UITableViewDelegate

extension PresentationEditorRightMenuViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return regionList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PresentationEditorRightMenuCell") as? PresentationEditorRightMenuCell
        
        if regionList.count > 0 {
            cell?.initViewWithRegion(region: regionList[indexPath.row])
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        delegate?.handleChooseMediaWithRegion(region: regionList[indexPath.row])
    }
}

// MARK: - PresentationEditorViewControllerDelegate

extension PresentationEditorRightMenuViewController: PresentationEditorViewControllerDelegate {
    
    func handleReloadRightMenu() {
        loadLocalPresentationData(shouldLoadFromTmpFolder: true)
    }
}

