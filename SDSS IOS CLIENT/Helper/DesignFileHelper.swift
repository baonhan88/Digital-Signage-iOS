//
//  DesignFileHelper.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 01/06/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import SwiftyJSON
import AVFoundation

class DesignFileHelper {
    static func getPresentationFromDesignFile(fileURL: URL) -> Presentation? {
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            dLog(message: "desgin file not exist at path \(fileURL)")
            return nil
        }
        
        do {
            let jsonData = NSData(contentsOfFile: fileURL.path)
            let jsonDict = try JSONSerialization.jsonObject(with: jsonData! as Data, options: .mutableContainers) as! NSDictionary
            
            guard let presentationInfoDict = jsonDict[DesignFile.paramPresentationInfo] else {
                return nil
            }
            
            return Presentation(dictionary: presentationInfoDict as! NSDictionary)
            
        } catch {
            dLog(message: error.localizedDescription)
        }
        
        return nil
    }
    
    static func getRegionListFromDesignFile(fileURL: URL) -> [Region]? {
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            dLog(message: "desgin file not exist at path \(fileURL)")
            return nil
        }
        
        do {
            let jsonData = try Data.init(contentsOf: fileURL)
            let jsonDict = JSON(data: jsonData).dictionary
            
            guard let regionDictList = jsonDict?[DesignFile.paramRegions]?.arrayObject else {
                return nil
            }
            
            return convertFromRegionDictListToRegionObjectList(regionDictList: regionDictList as! [NSDictionary])
        } catch {
            dLog(message: error.localizedDescription)
        }
        
        return nil
    }
    
    static func getDesignFileStringFromURL(designFileURL: URL) -> String? {
        if !FileManager.default.fileExists(atPath: designFileURL.path) {
            dLog(message: "desgin file not exist at path \(designFileURL)")
            return nil
        }
        
        do {
            let jsonData = try Data.init(contentsOf: designFileURL)
            let json = JSON(data: jsonData)
            
            return json.rawString()
            
        } catch {
            dLog(message: error.localizedDescription)
        }
        
        return nil
    }
    
    static func convertFromRegionObjectListToRegionDictionaryList(regionList: [Region]) -> [NSDictionary] {
        let regionDictList = NSMutableArray()
        for region in regionList {
            regionDictList.add(region.toDictionary())
        }
        return regionDictList as! [NSDictionary]
    }
    
    static func convertFromRegionDictListToRegionObjectList(regionDictList: [NSDictionary]) -> [Region] {
        let tmpRegionList = NSMutableArray()
        for regionDict in regionDictList {
            let region = Region(dictionary: regionDict)
            tmpRegionList.add(region)
        }
        return (tmpRegionList as? [Region])!
    }
    
    static func saveDesignFile(fromPresentation presentation: Presentation, andRegionList regionList: [Region], saveTo fileURL: URL) {
        // convert [Region] -> [NSDictionary]
        let regionDictList = convertFromRegionObjectListToRegionDictionaryList(regionList: regionList)
        
        do {
            let newJson: JSON = [DesignFile.paramPresentationInfo: presentation.toDictionary(), DesignFile.paramRegions: regionDictList]
            let rawData = try newJson.rawData()
            try rawData.write(to: fileURL, options: .atomic)
            
        } catch {
            dLog(message: error.localizedDescription)
        }
    }
    
    static func processSavePresentationWithName(_ name: String,
                                                isComeFromTemplate: Bool,
                                                fromOldDesignFile oldDesignFileURL: URL,
                                                andNewDesignFile  newDesignFileURL: URL,
                                                withCurrentPresentationFolder presentationFolder: URL,
                                                andTmpFolder tmpFolderURL: URL,
                                                completion: @escaping (Bool) -> Void) {
        
        if !FileManager.default.fileExists(atPath: newDesignFileURL.path) { // don't change anymore, just save new presentation with name
            // change name if need
            if isComeFromTemplate {
                guard let newPresentationInfo = getPresentationFromDesignFile(fileURL: oldDesignFileURL),
                    let regionList = getRegionListFromDesignFile(fileURL: oldDesignFileURL) else {
                        
                        dLog(message: "can't load presesntation & region list from url = \(oldDesignFileURL)")
                        completion(false)
                        return
                }
                
                newPresentationInfo.name = name
                // update accessRight by remove Clone & Sale
                newPresentationInfo.accessRight = AccessRightManager.removeAccessRights(with: [.clone, .sale], rootAccessRight: newPresentationInfo.accessRight)
                
                saveDesignFile(fromPresentation: newPresentationInfo, andRegionList: regionList, saveTo: oldDesignFileURL)
            }
            completion(true)
            return
        }
        
        // process remove old asset & add new asset
        guard let oldRegionList = getRegionListFromDesignFile(fileURL: oldDesignFileURL),
            let newRegionList = getRegionListFromDesignFile(fileURL: newDesignFileURL) else {
                
            dLog(message: "can't load region list")
            completion(false)
            return
        }
        
        for oldRegion in oldRegionList {
            if oldRegion.type == MediaType.image.name() {
                for newRegion in newRegionList {
                    if oldRegion.id == newRegion.id {
                        // if have changed
                        let oldImage = Utility.getFirstImageFromRegion(region: oldRegion)
                        let newImage = Utility.getFirstImageFromRegion(region: newRegion)
                        
                        if oldImage?.assetId == "" && newImage?.assetId != "" { // add new asset
                            // copy image asset from tmpFolder to presentationFolder
                            copyFile(fromPath: tmpFolderURL.appendingPathComponent((newImage?.assetId)! + (newImage?.assetExt)!),
                                     toPath: presentationFolder.appendingPathComponent((newImage?.assetId)! + (newImage?.assetExt)!))
                            
                        } else if oldImage?.assetId != "" && newImage?.assetId == "" { // remove old asset
                            removeFile(fileUrl: presentationFolder.appendingPathComponent((oldImage?.assetId)! + (oldImage?.assetExt)!))
                            
                        } else if oldImage?.assetId != "" && newImage?.assetId != "" && oldImage?.assetId != newImage?.assetId { // replace old asset with new asset
                            // copy newImage to presentationFolder
                            copyFile(fromPath: tmpFolderURL.appendingPathComponent((newImage?.assetId)! + (newImage?.assetExt)!),
                                     toPath: presentationFolder.appendingPathComponent((newImage?.assetId)! + (newImage?.assetExt)!))
                            // remove oldImage from presentationFolder
                            removeFile(fileUrl: presentationFolder.appendingPathComponent((oldImage?.assetId)! + (oldImage?.assetExt)!))
                        }
                     }
                }
                
            } else if oldRegion.type == MediaType.video.name() {
                for newRegion in newRegionList {
                    if oldRegion.id == newRegion.id {
                        // if have changed
                        let oldVideo = Utility.getFirstVideoFromRegion(region: oldRegion)
                        let newVideo = Utility.getFirstVideoFromRegion(region: newRegion)
                        
                        if oldVideo?.assetId == "" && newVideo?.assetId != "" { // add new asset
                            // copy video asset from tmpFolder to presentationFolder
                            copyFile(fromPath: tmpFolderURL.appendingPathComponent((newVideo?.assetId)! + (newVideo?.assetExt)!),
                                     toPath: presentationFolder.appendingPathComponent((newVideo?.assetId)! + (newVideo?.assetExt)!))
                            
                        } else if oldVideo?.assetId != "" && newVideo?.assetId == "" { // remove old asset
                            removeFile(fileUrl: presentationFolder.appendingPathComponent((oldVideo?.assetId)! + (oldVideo?.assetExt)!))
                            
                        } else if oldVideo?.assetId != "" && newVideo?.assetId != "" && oldVideo?.assetId != newVideo?.assetId { // replace old asset with new asset
                            // copy newVideo to presentationFolder
                            copyFile(fromPath: tmpFolderURL.appendingPathComponent((newVideo?.assetId)! + (newVideo?.assetExt)!),
                                     toPath: presentationFolder.appendingPathComponent((newVideo?.assetId)! + (newVideo?.assetExt)!))
                            // remove oldVideo from presentationFolder
                            removeFile(fileUrl: presentationFolder.appendingPathComponent((oldVideo?.assetId)! + (oldVideo?.assetExt)!))
                        }
                    }
                }
            }
        }
        
        guard let oldPresentationInfo = getPresentationFromDesignFile(fileURL: oldDesignFileURL),
            let newPresentationInfo = getPresentationFromDesignFile(fileURL: newDesignFileURL) else {
                
            dLog(message: "can't load presentation from \(newDesignFileURL)")
            completion(false)
            return
        }
        
        // process update BgImage
        if (newPresentationInfo.bgImage.type == BgImageType.localImage.name()) && (oldPresentationInfo.bgImage.value != newPresentationInfo.bgImage.value) {
            // copy bgImage from tmp folder to root folder
            copyFile(fromPath: tmpFolderURL.appendingPathComponent(newPresentationInfo.bgImage.value + newPresentationInfo.bgImage.assetExt),
                     toPath: presentationFolder.appendingPathComponent(newPresentationInfo.bgImage.value + newPresentationInfo.bgImage.assetExt))
            // remove old bgImage file
            removeFile(fileUrl: presentationFolder.appendingPathComponent(oldPresentationInfo.bgImage.value + oldPresentationInfo.bgImage.assetExt))
        }
        
        // generate new assetList at new presentationInfo + replace oldDesignFile with newDesignFile + change presentation's name
        if isComeFromTemplate {
            newPresentationInfo.name = name
            // update accessRight by remove Clone & Sale
            newPresentationInfo.accessRight = AccessRightManager.removeAccessRights(with: [.clone, .sale], rootAccessRight: newPresentationInfo.accessRight)
        }
        
        saveDesignFile(fromPresentation: newPresentationInfo, andRegionList: newRegionList, saveTo: oldDesignFileURL)
        
        // remove tmpFolder
        removeFile(fileUrl: tmpFolderURL)
        
        completion(true)
    }
    
    static func generateNewAssetListForPresentation(from regionList: [Region], andPresentation presentation: Presentation) -> Presentation? {
        let newAssetList = NSMutableArray.init()
        
        // add bg image asset
        let bgImage = presentation.bgImage
        if presentation.bgImage.type == BgImageType.localImage.name() {
            let newAsset = Asset()
            newAsset.id = bgImage.value
            newAsset.md5 = bgImage.md5
            newAsset.ext = bgImage.assetExt
            newAssetList.add(newAsset)
        }
        
        // add all assets from region
        for newRegion in regionList {
            if newRegion.type == MediaType.image.name() {
                if let image = Utility.getFirstImageFromRegion(region: newRegion) {
                    if image.sourceType == ImageAssetType.localImage.name() {
                        // create new asset and add to newAssetList
                        let newAsset = Asset()
                        newAsset.id = image.assetId
                        newAsset.ext = image.assetExt
                        newAsset.md5 = image.md5
                        newAssetList.add(newAsset)
                    }
                }
                
            } else if newRegion.type == MediaType.video.name() {
                if let video = Utility.getFirstVideoFromRegion(region: newRegion) {
                    if video.sourceType == VideoAssetType.localVideo.name() {
                        // create new asset and add to newAssetList
                        let newAsset = Asset()
                        newAsset.id = video.assetId
                        newAsset.ext = video.assetExt
                        newAsset.md5 = video.md5
                        newAssetList.add(newAsset)
                    }
                }
            }
        }
        presentation.assetList = newAssetList as! [Asset]
        return presentation
    }
    
    static func updateAssetIdWithOldAsset(_ oldAsset: Asset, replaceWithAssetId newAssetId: String, atDesignFileURL designFileURL: URL) {
        guard let regionList = getRegionListFromDesignFile(fileURL: designFileURL), let presentationInfo = getPresentationFromDesignFile(fileURL: designFileURL) else {
            dLog(message: "can't load presentation at path \(designFileURL.path)")
            return
        }
        
        // update asset on RegionList
        for region in regionList {
            var isUpdated = false
            
            switch region.type {
            case MediaType.image.name():
                if let image = Utility.getFirstImageFromRegion(region: region) {
                    if image.sourceType == ImageAssetType.localImage.name() && image.assetId == oldAsset.id {
                        image.assetId = newAssetId
                        region.objects?[0] = image
                        
                        isUpdated = true
                    }
                }
                break
                
            case MediaType.video.name():
                if let video = Utility.getFirstVideoFromRegion(region: region) {
                    if video.sourceType == VideoAssetType.localVideo.name() && video.assetId == oldAsset.id {
                        video.assetId = newAssetId
                        region.objects?[0] = video
                        
                        isUpdated = true
                    }
                }
                break
                
            default:
                break
            }
            
            if isUpdated {
                break
            }
        }
        
        // update assetList on PresentationInfo
        if presentationInfo.assetList.count > 0 {
            for asset in presentationInfo.assetList {
                if asset.id == oldAsset.id {
                    asset.id = newAssetId
                    break
                }
            }
        }
        
        saveDesignFile(fromPresentation: presentationInfo, andRegionList: regionList, saveTo: designFileURL)
    }
    
    static func updateNewPresentationId(_ newPresentationId: String, fromOldPresentationId oldPresentationId: String) {
        // update folderName, designFile name, presentation thumbnail name, presentationId + code in designFile, id in TemplateSlide.json
        // update folderName
        let oldFolderURL = Utility.getUrlFromDocumentWithAppend(url: Dir.savePresentation + oldPresentationId)
        let newFolderURL = Utility.getUrlFromDocumentWithAppend(url: Dir.savePresentation + newPresentationId)
        if FileManager.default.fileExists(atPath: oldFolderURL.path) {
            replaceFileAt(origionalUrl: oldFolderURL, withItemAt: newFolderURL)
        } else {
            dLog(message: "presentation folder not exist at \(oldFolderURL.path)")
        }
        
        // update designFile name
        let oldDesignFileURL = Utility.getUrlFromDocumentWithAppend(url: Dir.savePresentation + newPresentationId + "/" + oldPresentationId + Dir.presentationDesignExtension)
        let newDesignFileURL = Utility.getUrlFromDocumentWithAppend(url: Dir.savePresentation + newPresentationId + "/" + newPresentationId + Dir.presentationDesignExtension)
        if FileManager.default.fileExists(atPath: oldDesignFileURL.path) {
            replaceFileAt(origionalUrl: oldDesignFileURL, withItemAt: newDesignFileURL)
        } else {
            dLog(message: "design file not exist at \(oldDesignFileURL.path)")
        }
        
        // update presentation thumbnail
        let oldPresentationThumbnailURL = Utility.getUrlFromDocumentWithAppend(url: Dir.savePresentation + newPresentationId + "/" + oldPresentationId + Dir.presentationThumbnailExtension)
        let newPresentationThumbnailURL = Utility.getUrlFromDocumentWithAppend(url: Dir.savePresentation + newPresentationId + "/" + newPresentationId + Dir.presentationThumbnailExtension)
        if FileManager.default.fileExists(atPath: oldPresentationThumbnailURL.path) {
            replaceFileAt(origionalUrl: oldPresentationThumbnailURL, withItemAt: newPresentationThumbnailURL)
        } else {
            dLog(message: "design file not exist at \(oldPresentationThumbnailURL.path)")
        }
        
        // update presentationId + code in design file
        guard let presentation = getPresentationFromDesignFile(fileURL: newDesignFileURL),
            let regionList = getRegionListFromDesignFile(fileURL: newDesignFileURL) else {
            
            dLog(message: "can't load design file at \(newDesignFileURL.path)")
            return
        }
        presentation.id = newPresentationId
        presentation.code = newPresentationId
        saveDesignFile(fromPresentation: presentation, andRegionList: regionList, saveTo: newDesignFileURL)
        
        // update id in TemplateSlide.json
        TemplateSlide.updateNewPresentationId(newPresentationId, fromOldPresentationId: oldPresentationId)
    }
    
    static func getDesignFileUrlByPresentationId(_ presentationId: String) -> URL {
        return Utility.getUrlFromDocumentWithAppend(url: Dir.savePresentation + presentationId + "/" + presentationId + Dir.presentationDesignExtension)
    }
    
    static func getPresentationByPresentationId(_ presentationId: String) -> Presentation? {
        let designFileURL = getDesignFileUrlByPresentationId(presentationId)
        guard let presentation = DesignFileHelper.getPresentationFromDesignFile(fileURL: designFileURL) else {
            dLog(message: "can't load presentation design file from path \(designFileURL)")
            return nil
        }
        
        return presentation
    }
    
    static func getTmpDesignFileUrlByPresentationId(_ presentationId: String) -> URL {
        return Utility.getUrlFromDocumentWithAppend(url: Dir.savePresentation + presentationId + "/" + Dir.tmpFolderName + "/" + presentationId + Dir.presentationDesignExtension)
    }
    
    static func updateOldAssetId(_ oldAssetId: String, withNewAssetId newAssetId: String, andPresentationId presentationId: String) {
        let designFileURL = getDesignFileUrlByPresentationId(presentationId)
        
        guard let presentation = getPresentationFromDesignFile(fileURL: designFileURL),
            let regionList = getRegionListFromDesignFile(fileURL: designFileURL) else {
            
            dLog(message: "can't load design file at path = \(designFileURL.path)")
            return
        }
        
        // update presentationInfo
        for asset in presentation.assetList {
            if asset.id == oldAssetId {
                asset.id = newAssetId
            }
        }
        
        // update regionList
        for region in regionList {
            switch region.type {
                
            case MediaType.image.name():
                guard let image = Utility.getFirstImageFromRegion(region: region) else {
                    return
                }
                if image.assetId == oldAssetId {
                    image.assetId = newAssetId
                    region.objects?[0] = image
                }
                
            case MediaType.video.name():
                guard let video = Utility.getFirstVideoFromRegion(region: region) else {
                    return
                }
                if video.assetId == oldAssetId {
                    video.assetId = newAssetId
                    region.objects?[0] = video
                }
                
            default:
                break
            }
        }
        
        // save new design file
        saveDesignFile(fromPresentation: presentation, andRegionList: regionList, saveTo: designFileURL)
    }
    
    static func editPresentationName(_ name: String, presentationId: String) {
        // edit Presentation Name on root design file
        let designFileURL = getDesignFileUrlByPresentationId(presentationId)
        
        guard let presentation = getPresentationFromDesignFile(fileURL: designFileURL),
            let regionList = getRegionListFromDesignFile(fileURL: designFileURL) else {
                
                dLog(message: "can't load design file at path = \(designFileURL.path)")
                return
        }
        
        presentation.name = name
        
        saveDesignFile(fromPresentation: presentation, andRegionList: regionList, saveTo: designFileURL)
        
        // edit Presentation name on tmp design file
        let tmpDesignFileURL = getTmpDesignFileUrlByPresentationId(presentationId)
        
        if FileManager.default.fileExists(atPath: tmpDesignFileURL.path) {
            guard let tmpPresentation = getPresentationFromDesignFile(fileURL: tmpDesignFileURL),
                let tmpRegionList = getRegionListFromDesignFile(fileURL: tmpDesignFileURL) else {
                    
                    dLog(message: "can't load design file at path = \(tmpDesignFileURL.path)")
                    return
            }
            
            tmpPresentation.name = name
            
            saveDesignFile(fromPresentation: tmpPresentation, andRegionList: tmpRegionList, saveTo: tmpDesignFileURL)
        }
    }
}

// MARK: - For MediaType - Video

extension DesignFileHelper {
    static func updateYoutubeVideoInfo(designFileUrl: URL, newYoutubeUrl: String, region: Region) {
        guard let presentation = getPresentationFromDesignFile(fileURL: designFileUrl),
            let regionList = getRegionListFromDesignFile(fileURL: designFileUrl) else {
                
            dLog(message: "can't load design file from URL = \(designFileUrl.path)")
            return
        }
        
        if regionList.count > 0 {
            for tmpRegion in regionList {
                if tmpRegion.id == region.id && region.type == MediaType.video.name() {
                    if let video = Utility.getFirstVideoFromRegion(region: region) {
                        // update with new youtube video
                        video.sourcePath = newYoutubeUrl
                        video.sourceType = VideoAssetType.youtubeVideo.name()
                        video.md5 = ""
                        video.assetId = ""
                        video.assetExt = ""
                        tmpRegion.objects?[0] = video
                    }
                }
            }
            
            // update asset list on PresentationInfo
            if let newPresentationInfo = generateNewAssetListForPresentation(from: regionList, andPresentation: presentation) {
                // save presentation & regionList to URL
                saveDesignFile(fromPresentation: newPresentationInfo, andRegionList: regionList, saveTo: designFileUrl)
            }
        }
    }
    
    static func updateLocalVideoInfo(designFileUrl: URL, newLocalVideoId: String, newLocalVideoMd5: String, region: Region) {
        guard let presentation = getPresentationFromDesignFile(fileURL: designFileUrl),
            let regionList = getRegionListFromDesignFile(fileURL: designFileUrl) else {
                
            dLog(message: "can't load design file from URL = \(designFileUrl.path)")
            return
        }
        
        if regionList.count > 0 {
            // update video info in region list
            for tmpRegion in regionList {
                if tmpRegion.id == region.id && region.type == MediaType.video.name() {
                    if let video = Utility.getFirstVideoFromRegion(region: region) {
                        // update with new local video
                        video.sourcePath = ""
                        video.sourceType = VideoAssetType.localVideo.name()
                        video.md5 = newLocalVideoMd5
                        video.assetId = newLocalVideoId
                        video.assetExt = Dir.cameraRollVideoExtension
                        tmpRegion.objects?[0] = video
                    }
                }
            }
            
            // update asset list on PresentationInfo
            if let newPresentationInfo = generateNewAssetListForPresentation(from: regionList, andPresentation: presentation) {
                // save presentation & regionList to URL
                saveDesignFile(fromPresentation: newPresentationInfo, andRegionList: regionList, saveTo: designFileUrl)
            }
        }
    }
    
    static func thumbnailForLocalVideoAtURL(url: URL) -> UIImage? {
        
        let asset = AVAsset(url: url)
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
        
        var time = asset.duration
        time.value = min(time.value, 2)
        
        do {
            let imageRef = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage.init(cgImage: imageRef)
        } catch {
            dLog(message: error.localizedDescription)
            return nil
        }
        
    }
    
    static func saveVideoAtAssetURL(videoURL: URL, toFileURL tofileURL: URL, completion: @escaping (Bool) -> Void) {
        let asset = AVAsset(url: videoURL)

        let exportSession = AVAssetExportSession.init(asset: asset, presetName: AVAssetExportPresetHighestQuality)
        exportSession?.outputURL = tofileURL
        exportSession?.outputFileType = AVFileTypeQuickTimeMovie
        exportSession?.exportAsynchronously(completionHandler: { 
            if FileManager.default.fileExists(atPath: tofileURL.path) {
                dLog(message: "save local image success with path \(tofileURL.path)")
                completion(true)
            } else {
                completion(false)
            }
        })
    }
}

// MARK: - For MediaType - Image

extension DesignFileHelper {
    static func updateLocalImageInfo(designFileUrl: URL, newLocalImageId: String, newLocalImageMd5: String, region: Region) {
        guard let presentation = getPresentationFromDesignFile(fileURL: designFileUrl),
            let regionList = getRegionListFromDesignFile(fileURL: designFileUrl) else {
                
            dLog(message: "can't load design file from URL = \(designFileUrl.path)")
            return
        }
        
        if regionList.count > 0 {
            for tmpRegion in regionList {
                if tmpRegion.id == region.id && region.type == MediaType.image.name() {
                    if let image = Utility.getFirstImageFromRegion(region: region) {
                        image.sourcePath = ""
                        image.sourceType = ImageAssetType.localImage.name()
                        image.md5 = newLocalImageMd5
                        image.assetId = newLocalImageId
                        image.assetExt = Dir.cameraRollImageExtension
                        tmpRegion.objects?[0] = image
                    }
                }
            }
            
            // update asset list on PresentationInfo
            if let newPresentationInfo = generateNewAssetListForPresentation(from: regionList, andPresentation: presentation) {
                // save presentation & regionList to URL
                saveDesignFile(fromPresentation: newPresentationInfo, andRegionList: regionList, saveTo: designFileUrl)
            }
        }
    }
}

// MARK: - For MediaType - Webpage

extension DesignFileHelper {
    static func updateWebpageInfo(designFileUrl: URL, newWebpageUrl: String, region: Region) {
        guard let regionList = getRegionListFromDesignFile(fileURL: designFileUrl) else {
            dLog(message: "can't load region list")
            return
        }
        
        if regionList.count > 0 {
            for tmpRegion in regionList {
                if tmpRegion.id == region.id && region.type == MediaType.webpage.name() {
                    if let webpage = Utility.getFirstWebpageFromRegion(region: region) {
                        webpage.sourcePath = newWebpageUrl
                        webpage.sourceType = WebAssetType.remote.name()
                        webpage.md5 = ""
                        webpage.assetId = ""
                        webpage.assetExt = ""
                        tmpRegion.objects?[0] = webpage
                        
                        // get presenation info
                        let presentation = getPresentationFromDesignFile(fileURL: designFileUrl)
                        
                        // save presentation & regionList to URL
                        saveDesignFile(fromPresentation: presentation!, andRegionList: regionList, saveTo: designFileUrl)
                    }
                }
            }
        }
    }
}

// MARK: - For MediaType - Text

extension DesignFileHelper {
    static func updateTextInfo(designFileUrl: URL, newText: Text, region: Region) {
        guard let regionList = getRegionListFromDesignFile(fileURL: designFileUrl) else {
            dLog(message: "can't load region list")
            return
        }
        
        if regionList.count > 0 {
            for tmpRegion in regionList {
                if tmpRegion.id == region.id && region.type == MediaType.text.name() {
                    // update with new Text
                    tmpRegion.objects?[0] = newText
                    
                    // get presenation info
                    let presentation = getPresentationFromDesignFile(fileURL: designFileUrl)
                    
                    // save presentation & regionList to URL
                    saveDesignFile(fromPresentation: presentation!, andRegionList: regionList, saveTo: designFileUrl)
                }
            }
        }
    }
}

// MARK: - For MediaType - Frame

extension DesignFileHelper {
    static func updateFrameInfo(designFileUrl: URL, newFrame: Frame, region: Region) {
        guard let regionList = getRegionListFromDesignFile(fileURL: designFileUrl) else {
            dLog(message: "can't load region list")
            return
        }
        
        if regionList.count > 0 {
            for tmpRegion in regionList {
                if tmpRegion.id == region.id && region.type == MediaType.frame.name() {
                    // update with new Text
                    tmpRegion.objects?[0] = newFrame
                    
                    // get presenation info
                    let presentation = getPresentationFromDesignFile(fileURL: designFileUrl)
                    
                    // save presentation & regionList to URL
                    saveDesignFile(fromPresentation: presentation!, andRegionList: regionList, saveTo: designFileUrl)
                }
            }
        }
    }
}

// MARK: - Update BgImage

extension DesignFileHelper {
    
    static func updateBgImageInfo(designFileUrl: URL, newColor: UIColor) {
        guard let presentation = getPresentationFromDesignFile(fileURL: designFileUrl),
            let regionList = getRegionListFromDesignFile(fileURL: designFileUrl) else {
                
            dLog(message: "can't load design")
            return
        }
        
        presentation.bgImage.value = newColor.toHexString()
        
        // save presentation & regionList to URL
        saveDesignFile(fromPresentation: presentation, andRegionList: regionList, saveTo: designFileUrl)
    }
    
    static func updateBgImageInfo(designFileUrl: URL, newLocalImageId: String, newLocalImageMd5: String) {
        guard let presentation = getPresentationFromDesignFile(fileURL: designFileUrl),
            let regionList = getRegionListFromDesignFile(fileURL: designFileUrl) else {
                
            dLog(message: "can't load design file from URL = \(designFileUrl.path)")
            return
        }
        
        // update BgImage
        presentation.bgImage.md5 = newLocalImageMd5
        presentation.bgImage.assetExt = Dir.cameraRollImageExtension
        presentation.bgImage.value = newLocalImageId
            
        // update asset list on PresentationInfo
        if let newPresentationInfo = generateNewAssetListForPresentation(from: regionList, andPresentation: presentation) {
            // save presentation & regionList to URL
            saveDesignFile(fromPresentation: newPresentationInfo, andRegionList: regionList, saveTo: designFileUrl)
        }
    }
}

// MARK: - Common file handler: create, copy, delete...

extension DesignFileHelper {
    static func createNewFolder(folderUrl: URL) {
        do {
            try FileManager.default.createDirectory(atPath: folderUrl.path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            dLog(message: error.localizedDescription)
        }
    }
    
    static func copyFile(fromPath: URL, toPath: URL) {
        do {
            try FileManager.default.copyItem(at: fromPath, to: toPath)
        } catch {
            dLog(message: error.localizedDescription)
        }
    }
    
    static func removeFile(fileUrl: URL) {
        do {
            try FileManager.default.removeItem(at: fileUrl)
        } catch {
            dLog(message: error.localizedDescription)
        }
    }
    
    static func replaceFileAt(origionalUrl: URL, withItemAt itemURL: URL) {
        do {
            try FileManager.default.copyItem(at: origionalUrl, to: itemURL)
            try FileManager.default.removeItem(at: origionalUrl)

            // not working
//            _ = try FileManager.default.replaceItemAt(origionalUrl, withItemAt: itemURL)
        } catch {
            dLog(message: error.localizedDescription)
        }
    }
}
