//
//  UploadPresentationHelper.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 22/06/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import SVProgressHUD
import SwiftyJSON

protocol UploadPresentationHelperDelegate {
    func handleAfterUpdatePresentationId(witOldPresentationId oldPresentationId: String, andNewPresentationId newPresentationId: String)
}

class UploadPresentationHelper {
    fileprivate var assetList: [Asset] = []
    fileprivate var currentUploadAssetIndex = 0
    
    var delegate: UploadPresentationHelperDelegate?
    
    var completionHandler: (Bool, String) -> Void = {_,_ in }
    
    // input value
    var presentationId: String
    
    init(presentationId: String) {
        self.presentationId = presentationId
    }
    
    func processUploadPresentation() {
        guard let tmpPresentation = DesignFileHelper.getPresentationByPresentationId(self.presentationId) else {
            dLog(message: "can't load presentation design file with presentationId \(presentationId)")
            self.completionHandler(false, localizedString(key: "common_error_message"))
            return
        }
        
        // process check asset exist
        self.processCheckAssetExist(presentation: tmpPresentation)
    }
    
    fileprivate func processCheckAssetExist(presentation: Presentation) {
        // generate md5List
        let md5List = NSMutableArray.init()
        for asset in presentation.assetList {
            md5List.add(asset.md5)
        }
        
        if md5List.count == 0 {
            processUpdatePresentation()
            return
        }
        
        // generate string of JSON array from Array
        let md5JsonString = JSON(md5List)
        
        // call API checkAsset -> request with md5 list -> response with assetList exist in server
        NetworkManager.shared.checkAssetExist(md5s: md5JsonString.rawString()!, token: Utility.getToken()) {
            (success, assetList, message) in
            
            weak var weakSelf = self
            
            if success {
                // compare that assetList with local assetList to detect asset not exist in server
                let tmpShouldUploadAssetList = NSMutableArray.init()
                for localAsset in presentation.assetList {
                    var isExist = false
                    for asset in assetList {
                        if localAsset.md5 == asset.md5 {
                            isExist = true

                            if localAsset.id != asset.id {
                                // exist in server but need update id for localAsset
                                localAsset.processUpdateAssetWithNewAsset(asset, andPresentationId: (weakSelf?.presentationId)!)
                            }
                            
                            break
                        }
                    }
                    if !isExist {
                        tmpShouldUploadAssetList.add(localAsset)
                    }
                }
                
                // upload all assets not exist in server to server
                weakSelf?.assetList = tmpShouldUploadAssetList as! [Asset]
                weakSelf?.processUploadAllAssets()
            } else {
                weakSelf?.completionHandler(false, message)
            }
        }
    }
    
    fileprivate func processUploadAllAssets() {
        if assetList.count == 0 {
            processUpdatePresentation()
        } else {
            if currentUploadAssetIndex < assetList.count {
                // download asset
                let asset = assetList[currentUploadAssetIndex]
                dLog(message: "upload asset with: index = \(currentUploadAssetIndex), assetId = \(asset.id)")
                processUploadAsset(asset: asset)
            } else {
                processUpdatePresentation()
            }
        }
    }
    
    fileprivate func processUploadAsset(asset: Asset) {
        let fileURL = Utility.getUrlFromDocumentWithAppend(url: Dir.savePresentation + presentationId + "/" + asset.id + asset.ext)
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                let fileData = try Data(contentsOf: fileURL)
                NetworkManager.shared.createAsset(md5: asset.md5, token: Utility.getToken(), fileName: (asset.id + asset.ext), fileData: fileData, completion: {
                    (success, assetId, message) in
                    
                    weak var weakSelf = self
                    
                    if success {
                        dLog(message: "upload success with assetId = \(assetId)")
                        // update design file with new assetId
                        let designFileURL = DesignFileHelper.getDesignFileUrlByPresentationId((weakSelf?.presentationId)!)
                        DesignFileHelper.updateAssetIdWithOldAsset(asset, replaceWithAssetId: assetId, atDesignFileURL: designFileURL)
                        
                        // update name of local file with name = new assetId
                        let presentationFolderURL = Utility.getUrlFromDocumentWithAppend(url: Dir.savePresentation + (weakSelf?.presentationId)!)
                        DesignFileHelper.replaceFileAt(origionalUrl: fileURL,
                                                       withItemAt: presentationFolderURL.appendingPathComponent(assetId + asset.ext))
                        
                        // upload next asset if exist
                        weakSelf?.currentUploadAssetIndex += 1
                        weakSelf?.processUploadAllAssets()
                        
                    } else {
                        weakSelf?.completionHandler(false, message)
                    }
                    
                })
            } catch {
                self.completionHandler(false, localizedString(key: "common_error_message"))
                dLog(message: error.localizedDescription)
            }
        } else {
            self.completionHandler(false, localizedString(key: "common_error_message"))
            dLog(message: "asset not exist at path \(fileURL.path)")
        }
    }
    
    fileprivate func processUpdatePresentation() {
        let designFileURL = DesignFileHelper.getDesignFileUrlByPresentationId(self.presentationId)
        
        guard let tmpPresentation = DesignFileHelper.getPresentationByPresentationId(self.presentationId),
            let regionList = DesignFileHelper.getRegionListFromDesignFile(fileURL: designFileURL) else {
                
                dLog(message: "can't load presentation design file with presentationId \(presentationId)")
                self.completionHandler(false, localizedString(key: "common_error_message"))
                return
        }
        
        // check if don't have accessRight to update -> don't do this step -> return completion
        if !AccessRightManager.canUpdate(accessRight: tmpPresentation.accessRight) {
            completionHandler(true, "")
            return
        }
        
        var bgImage: String? = nil
        if !tmpPresentation.bgImage.isEmpty() {
            bgImage = tmpPresentation.bgImage.toJsonString()
        }
        
        // check presentation exist -> if not exist -> parse id response from server and update all things
        NetworkManager.shared.updatePresentation(id: tmpPresentation.id, code: tmpPresentation.code, name: tmpPresentation.name, lock: tmpPresentation.lock, orientation: tmpPresentation.orientation, shortDescription: tmpPresentation.shortDescription, ratio: tmpPresentation.ratio, width: tmpPresentation.width, height: tmpPresentation.height, bgAudioEnable: tmpPresentation.bgAudioEnable, bgImage: bgImage, tags: tmpPresentation.tags, assetList: tmpPresentation.assetList.toJsonString(), regions: regionList.toJsonString(), token: Utility.getToken()) {
            
            (success, presentationId, message) in
            
            weak var weakSelf = self
            
            if success {
                // not exist in server, server created new presentation with newId
                if presentationId != tmpPresentation.id {
                    // need update id for this presentation
                    // update Presentation in Local: folderName, designFile name, presentation thumbnail name, presentationId + code in designFile, id in TemplateSlide.json
                    DesignFileHelper.updateNewPresentationId(presentationId, fromOldPresentationId: tmpPresentation.id)
                    weakSelf?.presentationId = presentationId
                    
                    // get newest design file data & update folderName with newPresentationId
                    weakSelf?.delegate?.handleAfterUpdatePresentationId(witOldPresentationId: tmpPresentation.id, andNewPresentationId: presentationId)
                }
                
                // upload presentation thumbnail to server
                weakSelf?.processUpdatePresentationThumbnail(completion: {
                    (success, message) in
                    
                    weak var weakSelf = self
                    
                    weakSelf?.completionHandler(success, message)
                    
                })
            } else {
                weakSelf?.completionHandler(false, message)
            }
        }
    }
    
    fileprivate func processUpdatePresentationThumbnail(completion: @escaping (Bool, String) -> Void) {
        let presentationThumbnailURL = Utility.getUrlFromDocumentWithAppend(url: Dir.savePresentation + presentationId + "/" + presentationId + Dir.presentationThumbnailExtension)
        
        if FileManager.default.fileExists(atPath: presentationThumbnailURL.path) {
            do {
                let fileData = try Data.init(contentsOf: presentationThumbnailURL)
                
                NetworkManager.shared.updatePresentationThumbnail(presentaionId: self.presentationId, token: Utility.getToken(), fileName: (self.presentationId + Dir.presentationThumbnailExtension), fileData: fileData) {
                    
                    (success, message) in
                    
                    completion(success, message)
                }
            } catch {
                dLog(message: error.localizedDescription)
                completion(false, localizedString(key: "common_error_message"))
            }
        }
    }
}

