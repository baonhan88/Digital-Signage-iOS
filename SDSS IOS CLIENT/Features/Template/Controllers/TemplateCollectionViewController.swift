//
//  TemplateCollectionViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 17/10/2018.
//  Copyright © 2018 SLab. All rights reserved.
//

import UIKit
import SVProgressHUD

private let reuseIdentifier = "TemplateCollectionViewCell"

class TemplateCollectionViewController: BaseCollectionViewController {
    
    var presentationList: NSMutableArray = []
    fileprivate var presentation: Presentation = Presentation()
    
    var pageInfo = PageInfo()
    var loadingData = true
    
    var currentTag: String?
    
    var totalDownloaded: Int = 0
    var currentDownloadAssetIndex: Int = 0
    
    fileprivate var filterString = ""
    fileprivate var templateFilter = TemplateFilter.init()
    
    fileprivate var pinCodeJsonString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavigationBar()
        
        // Register cell classes
        self.collectionView!.register(UINib(nibName: "TemplateCollectionViewCell", bundle: nil),
                                      forCellWithReuseIdentifier: reuseIdentifier)
        
        loadMoreData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func initNavigationBar() {
        // set title
        self.navigationItem.title = localizedString(key: "dashboard_template_title")
        
        // init setting icon
        let filterImage   = UIImage(named: "icon_filter.png")!
        let filterButton   = UIBarButtonItem(image: filterImage,  style: .plain, target: self, action: #selector(filterButtonClicked(_sender:)))
        
        // init group icon
        let groupImage   = UIImage(named: "icon_category_small.png")!
        let groupButton   = UIBarButtonItem(image: groupImage,  style: .plain, target: self, action: #selector(groupButtonClicked(_sender:)))
        
        navigationItem.rightBarButtonItems = [groupButton, filterButton]
    }
    
    func handleRefresh() {
        // reset all data
        presentationList.removeAllObjects()
        pageInfo = PageInfo()
        
        // call API get data
        loadMoreData()
    }
    
    func loadMoreData() {
        if pageInfo.hasNext {
            loadingData = true
            
            // show loading
            SVProgressHUD.show()
            
            NetworkManager.shared.getPresentationList(filter: filterString,
                                                      sort: "-updatedDate",
                                                      token: Utility.getToken(),
                                                      page: pageInfo.current + 1,
                                                      perPage: Network.perPage) {
                                                        (success, presentationList, pageInfo, message) in
                                                        
                                                        weak var weakSelf = self
                                                        
                                                        // remove loading
                                                        SVProgressHUD.dismiss()
                                                        
                                                        if (success) {
                                                            weakSelf?.presentationList.addObjects(from: presentationList!)
                                                            
                                                            weakSelf?.pageInfo = pageInfo!
                                                            weakSelf?.collectionView?.reloadData()
                                                            
                                                        } else {
                                                            // show error message
                                                            Utility.showAlertWithErrorMessage(message: message, controller: self, completion: nil)
                                                        }
                                                        
                                                        weakSelf?.loadingData = false
            }
        }
    }
    
    func editNameButtonClicked(presentation: Presentation) {
        // Create the alert controller.
        let alert = UIAlertController(title: "",
                                      message: localizedString(key: "presentation_editor_save_presentation_message"),
                                      preferredStyle: .alert)
        
        // Add the text field
        alert.addTextField { (textField) in
            weak var weakSelf = self

            textField.text = weakSelf?.presentation.name
            textField.placeholder = localizedString(key: "presentation_editor_input_name_placeholder")
        }
        
        // add cancel action
        alert.addAction(UIAlertAction(title: localizedString(key: "common_cancel"), style: .cancel, handler: { (_) in
            // just dismiss alert
        }))
        
        // add OK action
        alert.addAction(UIAlertAction(title: localizedString(key: "common_ok"), style: .default, handler: { [weak alert] (_) in
            weak var weakSelf = self
            
            // process save presentation
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            let trimmedName = (textField?.text!)!.trimmingCharacters(in: .whitespacesAndNewlines)
            if Utility.isValidName(name: trimmedName) {
                weakSelf?.processEditPresentationName(trimmedName, presentation: presentation)
            } else {
                Utility.showAlertWithErrorMessage(message: localizedString(key: "presentation_editor_input_name_invalid"), controller: weakSelf!)
            }
        }))
        
        // Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func processEditPresentationName(_ name: String, presentation: Presentation) {
        SVProgressHUD.show()
        
        // edit name on cloud
        NetworkManager.shared.editNamePresentation(id: presentation.id, name: name, token: Utility.getToken()) {
            [weak self] (success, message) in
            
            SVProgressHUD.dismiss()
            
            if success {
                // edit name on local
                //                DesignFileHelper.editPresentationName(name, presentationId: presentation.id)
                
                SVProgressHUD.showSuccess(withStatus: localizedString(key: "common_edited"))
                
                self?.handleRefresh()
            } else {
                Utility.showAlertWithErrorMessage(message: message, controller: self!)
            }
        }
    }
    
    fileprivate func processDeletePresentation(presentation: Presentation) {
        // delete presentation on Cloud
        SVProgressHUD.show()
        
        NetworkManager.shared.deletePresentation(id: presentation.id, token: Utility.getToken()) {
            [weak self] (success, message) in
            
            SVProgressHUD.dismiss()
            
            if success {
                Utility.showAlertWithSuccessMessage(message: localizedString(key: "common_deleted"), controller: self!)
                
                self?.handleRefresh()
            } else {
                Utility.showAlertWithErrorMessage(message: message, controller: self!)
            }
        }
    }
    
    fileprivate func processSendPresentationToCloud() {
        SVProgressHUD.show(withStatus: localizedString(key: "common_sending"))
        
        NetworkManager.shared.controlDeviceToPlay(pinCodeList: self.pinCodeJsonString, contentId: self.presentation.id, contentType: ContentType.presentation.name(), contentName: presentation.name, contentData: nil, token: Utility.getToken()) {
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

// MARK: UICollectionViewDataSource & UICollectionViewDelegate

extension TemplateCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presentationList.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? TemplateCollectionViewCell
        
        let presentation = presentationList[indexPath.row] as! Presentation
        cell?.initView(with: presentation)
        
        return cell!
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let lastElement = (presentationList.count) - 1
        if indexPath.row == lastElement && loadingData == false {
            loadMoreData()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presentation = presentationList[indexPath.row] as! Presentation
        let url = URL(string: Network.baseURL + String.init(format: Network.presentationThumbnailUrl, presentation.id, Utility.getToken()))!
        
        let prevImageView = UIImageView(frame: CGRect(x: 10, y: 60, width: 250, height: 130))
        let placeholderImage = UIImage(named: "icon_template_placeholder")!
        // remove cache
        Utility.clearImageFromCache(withURL: url)
        prevImageView.af_setImage(withURL: url, placeholderImage: placeholderImage)
        
        let spacer = "\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n"
        let previewController = UIAlertController(title: localizedString(key: "template_confirm_message_when_tap_on_presentation"),
                                                  message: spacer,
                                                  preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: localizedString(key: "common_later"), style: .default) { (UIAlertAction) in
            
        }
        
        let deleteAction = UIAlertAction(title: localizedString(key: "common_delete"), style: .default) { (UIAlertAction) in
            weak var weakSelf = self
            
            weakSelf?.processDeletePresentation(presentation: (weakSelf?.presentation)!)
        }
        
        let editAction = UIAlertAction(title: localizedString(key: "common_edit"), style: .default) { (UIAlertAction) in
            weak var weakSelf = self
            
            weakSelf?.editNameButtonClicked(presentation: (weakSelf?.presentation)!)
        }
        
        let sendAction = UIAlertAction(title: localizedString(key: "common_send"), style: .default) { (UIAlertAction) in
            weak var weakSelf = self
            
            // just go to cloud device list screen
            ControllerManager.goToCloudDeviceListScreen(currentDeviceListType: .presentation, controller: weakSelf!)
        }
        
        previewController.addAction(deleteAction)
        previewController.addAction(editAction)
        previewController.addAction(sendAction)
        previewController.addAction(cancelAction)
        previewController.view.addSubview(prevImageView)
        self.present(previewController, animated: true, completion: nil)
    }
}

// MARK: - handle events
extension TemplateCollectionViewController {
    
    func filterButtonClicked(_sender: UIBarButtonItem) {
        ControllerManager.showTemplateFilterScreen(controller: self, currentTemplateFilter: self.templateFilter)
    }
    
    func groupButtonClicked(_sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "groupListSegue", sender: nil)
    }
    
}

// MARK: - CloudDeviceListViewControllerDelegate

extension TemplateCollectionViewController: CloudDeviceListViewControllerDelegate {
    
    func handleSendPresentation(pinCodeJsonString: String) {
        self.pinCodeJsonString = pinCodeJsonString
        processSendPresentationToCloud()
    }
}

// MARK: - TemplateFilterViewControllerDelegate

extension TemplateCollectionViewController: TemplateFilterViewControllerDelegate {
    
    func handleFilter(templateFilter: TemplateFilter) {
        self.templateFilter = templateFilter
        
        // refresh presentation list and attach filter
        filterString = templateFilter.generateSelectedFilterJson()
//        filterString = "[{\"key\":\"tags\",\"operator\":\"in\",\"value\":\"[\"58983da1d095e32608378cb8\",\"58983dc1d095e32608378cb9\"]\"}]"
        
        dLog(message: "aaaa = " + filterString)
        
        if filterString != "" {
            handleRefresh()
        }
    }
}

