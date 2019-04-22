//
//  AssetSelectionCollectionViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 30/08/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import SVProgressHUD
import AlamofireImage

protocol AssetSelectionCollectionViewControllerDelegate {
    func handleUpdateAssetFromCloud(assetDetail: AssetDetail)
}

private let reuseIdentifier = "AssetSelectionCell"

class AssetSelectionCollectionViewController: UICollectionViewController {
    
    var assetType: AssetType = AssetType.none
    
    fileprivate var assetDetailList: NSMutableArray = []
    fileprivate var pageInfo = PageInfo()
    fileprivate var loadingData = true
    
    var delegate: AssetSelectionCollectionViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UINib(nibName: "AssetSelectionCell", bundle: nil),
                                      forCellWithReuseIdentifier: reuseIdentifier)
        
        // init navigation bar
        initNavigationBar()
        
        // load data
        loadMoreData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    fileprivate func initNavigationBar() {
        self.title = localizedString(key: "asset_list_title")
    }
    
    fileprivate func loadMoreData() {
        if self.assetType.name() == AssetType.none.name() {
            return
        }
        
        if pageInfo.hasNext {
            loadingData = true
            
            // show loading
            SVProgressHUD.show()
            
            NetworkManager.shared.getAssetListFromCloud(filter: "",
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
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension AssetSelectionCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetDetailList.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? AssetSelectionCell
        
        let assetDetail = assetDetailList[indexPath.row] as? AssetDetail
        
        let placeholderImage = UIImage(named: "icon_template_placeholder")!
        
        if let thumbnailUrl = URL.init(string: NetworkManager.shared.baseURL + String.init(format: Network.assetThumbnailUrl, (assetDetail?.id)!,  Utility.getToken())) {
            Utility.clearImageFromCache(withURL: thumbnailUrl)
            cell?.imageView.af_setImage(withURL: thumbnailUrl, placeholderImage: placeholderImage)
        }
        
        if self.assetType == AssetType.video {
            cell?.iconImageView.isHidden = false
            cell?.iconImageView.image = UIImage.init(named: "icon_video")
        } else {
            cell?.iconImageView.isHidden = true
        }
        
        return cell!
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let assetDetail = assetDetailList[indexPath.row] as? AssetDetail {
            delegate?.handleUpdateAssetFromCloud(assetDetail: assetDetail)
            
            self.navigationController?.popViewController(animated: true)
        }
    }
}
