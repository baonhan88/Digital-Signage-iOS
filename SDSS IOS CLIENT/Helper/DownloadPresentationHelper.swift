//
//  DownloadPresentationHelper.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 22/06/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import SVProgressHUD

class DownloadPresentationHelper {
    fileprivate var currentDownloadAssetIndex = 0
    
    // input values
    var presentation: Presentation?
    var presentationId: String?
    var controller: UIViewController
    
    var completionHandler: (Bool, String) -> Void = {_,_ in }

    // for download Template
    init(presentation: Presentation, controller: UIViewController) {
        self.presentation = presentation
        self.controller = controller
    }
    
    // for download Presentation
    init(presentationId: String, controller: UIViewController) {
        self.presentationId = presentationId
        self.controller = controller
    }
}

// MARK: - For Template

extension DownloadPresentationHelper {
    // download all assets, design file, thumbnail
    func processDownloadTemplate() {
        SVProgressHUD.show(withStatus: localizedString(key: "common_downloading"))
        
        if presentation?.assetList.count == 0 {
            // don't have asset -> download design
            processDownloadTemplateDesign()
        } else {
            if currentDownloadAssetIndex < (presentation?.assetList.count)! {
                // download asset
                let asset = presentation?.assetList[currentDownloadAssetIndex]
                processDownloadTemplateAsset(asset: asset!)
            } else {
                // downloaded all assets -> download design
                processDownloadTemplateDesign()
            }
        }
    }
    
    fileprivate func processDownloadTemplateAsset(asset: Asset) {
        NetworkManager.shared.downloadTemplateAsset(asset: asset, token: Utility.getToken(), downloadProgress: {
            (progress) in
            
        }) { (success, message) in
            
            weak var weakSelf = self
            
            if success {
                // download next asset
                weakSelf?.currentDownloadAssetIndex += 1
                weakSelf?.processDownloadTemplate()
            } else {
                SVProgressHUD.dismiss()
                Utility.showAlertWithErrorMessage(message: message, controller: (weakSelf?.controller)!)
            }
        }
    }
    
    fileprivate func processDownloadTemplateDesign() {
        NetworkManager.shared.getTemplateDesignData(presentationId: (presentation?.id)!, token: Utility.getToken()) {
            (success, message) in
            
            weak var weakSelf = self
            
            if success {
                // download presentation thumbnail
                weakSelf?.processDownloadTemplateThumbnail()
            } else {
                SVProgressHUD.dismiss()
                
                Utility.showAlertWithErrorMessage(message: message, controller: (weakSelf?.controller)!)
            }
        }
    }
    
    fileprivate func processDownloadTemplateThumbnail() {
        // download presentation thumbnail
        NetworkManager.shared.downloadTemplateThumbnail(presentationId: (self.presentation?.id)!, url: String.init(format: Network.presentationThumbnailUrl, (presentation?.id)!, Utility.getToken()), downloadProgress: {
            (progress) in
            
        }, completion: {
            (success, message) in
            
            weak var weakSelf = self
            
            SVProgressHUD.dismiss()
            
            if success {
                SVProgressHUD.showSuccess(withStatus: localizedString(key: "template_message_download_successful"))
                
                // download template successful -> save data info to templateSlide.json file
                TemplateSlide.processSaveTemplateDownloadedInfo(presentation: (weakSelf?.presentation)!)
                
            } else {
                Utility.showAlertWithErrorMessage(message: localizedString(key: "template_message_download_thumbnail_error"),
                                                  controller: (weakSelf?.controller)!)
            }
        })
    }
}

// MARK: - For Presentation

extension DownloadPresentationHelper {
    // download all assets, design file, thumbnail
    func processDownloadPresentation() {
        processDownloadPresentationDesign()
    }
    
    fileprivate func processDownloadAllPresentationAssets(presentation: Presentation) {
        if presentation.assetList.count == 0 {
            // don't have asset -> download thumbnail
            processDownloadPresentationThumbnail()
        } else {
            if currentDownloadAssetIndex < presentation.assetList.count {
                // download asset
                let asset = presentation.assetList[currentDownloadAssetIndex]
                processDownloadPresentationAsset(asset: asset, presentation: presentation)
            } else {
                // downloaded all assets -> download thumbnail
                processDownloadPresentationThumbnail()
            }
        }
    }
    
    fileprivate func processDownloadPresentationAsset(asset: Asset, presentation: Presentation) {
        NetworkManager.shared.downloadPresentationAsset(presentationId: presentationId!, asset: asset, token: Utility.getToken(), downloadProgress: {
            (progress) in
            
        }) { (success, message) in
            
            weak var weakSelf = self
            
            if success {
                // download next asset
                weakSelf?.currentDownloadAssetIndex += 1
                weakSelf?.processDownloadAllPresentationAssets(presentation: presentation)
            } else {
                weakSelf?.completionHandler(false, message)
            }
        }
    }
    
    fileprivate func processDownloadPresentationDesign() {
        NetworkManager.shared.getPresentationDesignData(presentationId: presentationId!, token: Utility.getToken()) {
            (success, message) in
            
            weak var weakSelf = self
            
            if success {
                // get design file from local
                if let presentation = DesignFileHelper.getPresentationByPresentationId((weakSelf?.presentationId)!) {
                    // download all presentation assets
                    weakSelf?.currentDownloadAssetIndex = 0
                    weakSelf?.processDownloadAllPresentationAssets(presentation: presentation)
                } else {
                    weakSelf?.completionHandler(false, localizedString(key: "common_error"))
                }
          
            } else {
                weakSelf?.completionHandler(false, message)
            }
        }
    }
    
    fileprivate func processDownloadPresentationThumbnail() {
        // download presentation thumbnail
        NetworkManager.shared.downloadPresentationThumbnail(presentationId: presentationId!, url: String.init(format: Network.presentationThumbnailUrl, (self.presentation?.id)!, Utility.getToken()), downloadProgress: {
            (progress) in
            
        }, completion: {
            (success, message) in
            
            weak var weakSelf = self
            
            weakSelf?.completionHandler(success, message)

        })
    }
}
