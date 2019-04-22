//
//  AssetCollectionViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 17/10/2018.
//  Copyright © 2018 SLab. All rights reserved.
//

import UIKit
import SVProgressHUD

private let reuseIdentifier = "AssetCollectionViewCell"

class AssetCollectionViewController: BaseCollectionViewController {
    
    var assetDetailList: NSMutableArray = []
    var currentAsset: AssetDetail = AssetDetail()
    
    var pageInfo = PageInfo()
    var loadingData = true
    
    var currentTag: String?
    
    var totalDownloaded: Int = 0
    var currentDownloadAssetIndex: Int = 0
    
    fileprivate var filterString = ""
    fileprivate var assetFilter = AssetFilter.init()
    
    fileprivate var pinCodeJsonString = ""
    
    var imagePickedBlock: ((UIImage) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavigationBar()
        
        
        // Register cell classes
        self.collectionView!.register(UINib(nibName: "AssetCollectionViewCell", bundle: nil),
                                      forCellWithReuseIdentifier: reuseIdentifier)
        
        loadMoreData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func initNavigationBar() {
        // set title
        self.navigationItem.title = localizedString(key: "asset_tile")
        
        // init setting icon
        let filterImage   = UIImage(named: "icon_filter.png")!
        let filterButton   = UIBarButtonItem(image: filterImage,  style: .plain, target: self, action: #selector(filterButtonClicked(_sender:)))
        
        // init upload icon
        let uploadImage   = UIImage(named: "icon_update_design_cloud.png")!
        let uploadButton   = UIBarButtonItem(image: uploadImage,  style: .plain, target: self, action: #selector(uploadButtonClicked(_sender:)))
        
        navigationItem.rightBarButtonItems = [filterButton, uploadButton]
    }
    
    func handleRefresh() {
        // reset all data
        assetDetailList.removeAllObjects()
        pageInfo = PageInfo()
        
        // call API get data
        loadMoreData()
    }
    
    func loadMoreData() {
        if pageInfo.hasNext {
            loadingData = true
            
            // show loading
            SVProgressHUD.show()
            
            NetworkManager.shared.getAssetListFromCloud(filter: filterString,
                                                        sort: "-updatedDate",
                                                        token: Utility.getToken(),
                                                        page: pageInfo.current + 1,
                                                        perPage: Network.perPage) {
                                                            
                                                            [weak self] (success, assetDetailList, pageInfo, message) in
                                                            
                                                            // remove loading
                                                            SVProgressHUD.dismiss()
                                                            
                                                            if (success) {
                                                                self?.assetDetailList.addObjects(from: assetDetailList!)
                                                                
                                                                self?.pageInfo = pageInfo!
                                                                self?.collectionView?.reloadData()
                                                                
                                                            } else {
                                                                // show error message
                                                                Utility.showAlertWithErrorMessage(message: message, controller: self!, completion: nil)
                                                            }
                                                            
                                                            self?.loadingData = false
            }
        }
    }
    
    func editAssetButtonClicked(asset: AssetDetail) {
        ControllerManager.showAssetEditScreen(controller: self, assetDetail: asset)
    }
    
    fileprivate func processDeleteAsset(asset: AssetDetail) {
        // delete presentation on Cloud
        SVProgressHUD.show()
        
        NetworkManager.shared.deleteAsset(id: asset.id, token: Utility.getToken()) {
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
    
    fileprivate func processSendAssetToCloud() {
        SVProgressHUD.show(withStatus: localizedString(key: "common_sending"))
        
        NetworkManager.shared.controlDeviceToPlay(pinCodeList: self.pinCodeJsonString, contentId: self.currentAsset.id, contentType: ContentType.asset.name(), contentName: currentAsset.name, contentData: nil, token: Utility.getToken()) {
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

extension AssetCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetDetailList.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? AssetCollectionViewCell
        
        let assetDetail = assetDetailList[indexPath.row] as? AssetDetail
        
        cell?.initViewWith(assetDetail: assetDetail!)
        
        return cell!
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let lastElement = (assetDetailList.count) - 1
        if indexPath.row == lastElement && loadingData == false {
            loadMoreData()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentAsset = assetDetailList[indexPath.row] as! AssetDetail
        
        var prevImageView = UIImageView.init()
        if let thumbnailUrl = URL.init(string: NetworkManager.shared.baseURL + String.init(format: Network.assetThumbnailUrl, currentAsset.id,  Utility.getToken())) {
            prevImageView = UIImageView(frame: CGRect(x: 10, y: 60, width: 250, height: 130))
            let placeholderImage = UIImage(named: "icon_template_placeholder")!
            // remove cache
            Utility.clearImageFromCache(withURL: thumbnailUrl)
            prevImageView.af_setImage(withURL: thumbnailUrl, placeholderImage: placeholderImage)
        }
        
        let spacer = "\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n"
        let previewController = UIAlertController(title: localizedString(key: "asset_confirm_message_when_tap_on_asset"),
                                                  message: spacer,
                                                  preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: localizedString(key: "common_later"), style: .default) { (UIAlertAction) in
            
        }
        
        let deleteAction = UIAlertAction(title: localizedString(key: "common_delete"), style: .default) { (UIAlertAction) in
            weak var weakSelf = self
            
            weakSelf?.processDeleteAsset(asset: (weakSelf?.currentAsset)!)
        }
        
        let editAction = UIAlertAction(title: localizedString(key: "common_edit"), style: .default) { (UIAlertAction) in
            weak var weakSelf = self
            
            weakSelf?.editAssetButtonClicked(asset: (weakSelf?.currentAsset)!)
        }
        
        let sendAction = UIAlertAction(title: localizedString(key: "common_send"), style: .default) { (UIAlertAction) in
            weak var weakSelf = self
            
            // just go to cloud device list screen
            ControllerManager.goToCloudDeviceListScreen(currentDeviceListType: .asset, controller: weakSelf!)
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
extension AssetCollectionViewController {
    
    func filterButtonClicked(_sender: UIBarButtonItem) {
        ControllerManager.showAssetFilterScreen(controller: self, currentAssetFilter: self.assetFilter)
    }
    
    func uploadButtonClicked(_sender: UIBarButtonItem) {
        PhotoLibraryManager.shared.showActionSheet(vc: self)
        PhotoLibraryManager.shared.imagePickedBlock = {
            (image) in
            
            SVProgressHUD.show(withStatus: localizedString(key: "common_uploading"))
            
            let fileData: Data = UIImagePNGRepresentation(image)!
            
            NetworkManager.shared.uploadAsset(fileName: self.currentAsset.name, fileData: fileData, completion: { (sucess, message) in
                
                SVProgressHUD.dismiss()
                
                SVProgressHUD.showSuccess(withStatus: localizedString(key: "common_uploaded"))
            })
        }
    }
    
}

// MARK: - CloudDeviceListViewControllerDelegate

extension AssetCollectionViewController: CloudDeviceListViewControllerDelegate {
    
    func handleSendAsset(pinCodeJsonString: String) {
        self.pinCodeJsonString = pinCodeJsonString
        
        processSendAssetToCloud()
    }
}

// MARK: - TemplateFilterViewControllerDelegate

extension AssetCollectionViewController: AssetFilterViewControllerDelegate {
    
    func handleFilter(assetFilter: AssetFilter) {
        self.assetFilter = assetFilter
        
        // refresh presentation list and attach filter
        filterString = assetFilter.generateSelectedFilterJson()
//        filterString = "[{\"key\":\"tags\",\"operator\":\"in\",\"value\":\"[\"58983da1d095e32608378cb8\",\"58983dc1d095e32608378cb9\"]\"}]"
        
        dLog(message: "aaaa = " + filterString)
        
        if filterString != "" {
            handleRefresh()
        }
    }
}

// MARK: - AssetEditViewControllerDelegate

extension AssetCollectionViewController: AssetEditViewControllerDelegate {
    
    func handleEditAsset(assetDetail: AssetDetail) {
        loadingData = true

        SVProgressHUD.show()
        
        NetworkManager.shared.editAsset(id: assetDetail.id,
                                        name: assetDetail.name,
                                        tags: Utility.convertToJson(from: assetDetail.tags)!,
                                        token: Utility.getToken()) {
                                            (success, message) in
            
                                            weak var weakSelf = self
                                            
                                            // remove loading
                                            SVProgressHUD.dismiss()
                                            
                                            if (success) {
                                                weakSelf?.collectionView?.reloadData()
                                                
                                            } else {
                                                // show error message
                                                Utility.showAlertWithErrorMessage(message: message, controller: self, completion: nil)
                                            }
                                            
                                            weakSelf?.loadingData = false

            
        }
    }
}


