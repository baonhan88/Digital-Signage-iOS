//
//  Presentation.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 12/05/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import EVReflection

class Presentation: EVObject {
    var originECoinF: CGFloat = 0
    var height: CGFloat = 0
    var width: CGFloat = 0
    var ratio: String = ""
    var isECoinF: Bool = false
    var isSystem: Bool = false
    var createdDate: String = ""
    var id: String = ""
    var downloadCount: Int = 0
    var isECoinX: Bool = false
    var assetList: [Asset] = []
    var buyCount: CGFloat = 0
    var bgAudio: BgAudio = BgAudio()
    var totalStarCount: CGFloat = 0
    var orientation: String = ""
    var currentECoinF: CGFloat = 0
    var shortDescription: String = ""
    var isPrivate: Bool = false
    var bgImage: BgImage = BgImage()
    var currentECoinX: CGFloat = 0
    var viewCount: Int = 0
    var name: String = ""
    var code: String = ""
    var status: String = ""
    var rateCount: Int = 0
    var updatedDate: String = ""
    var originECoinX: CGFloat = 0
    var tags: [String] = []
    var bgAudioEnable: Bool = false
    var owner: User = User()
    // regions ????
    var lock: Bool = false
    var isBookMark: Bool = false
    var isRecommend: Bool = false
    
    // not use for current API version
//    var thumbnailUrl: String = ""
//    var symbolUrl: String = ""
    var accessRight: Int = 0
    
    // just use for containing data (the name of folder which contain all assets and design file of presentation) 
    var folderName: String = ""
    
    override func setValue(_ value: Any!, forUndefinedKey key: String) {
        if key == "_id" {
            return
        }
    }
    
    override func skipPropertyValue(_ value: Any, key: String) -> Bool {
        if key == "folderName" {
            return true
        }
        return false
    }
    
    /*init() {
        self.id = ""
            self.updatedDate = ""
            self.createdDate = ""
            self.viewCount = 0
            self.downloadCount = 0
            self.status = ""
            self.tags = [""]
            self.assetList = [Asset()]
            self.bgAudioEnable = false
            self.height = 0
            self.width = 0
            self.ratio = ""
            self.orientation = ""
            self.lock = false
            self.shortDescription = ""
            self.owner = User()
            self.name = ""
            self.code = ""
            self.thumbnailUrl = ""
            self.symbolUrl = ""
    }
    
    init(data: [String: Any]) {
        self.id = data[Constants.Network.paramId] as? String
        self.updatedDate = data[Constants.Network.paramUpdatedDate] as? String
        self.createdDate = data[Constants.Network.paramCreatedDate] as? String
        self.viewCount = data[Constants.Network.paramViewCount] as? Int
        self.downloadCount = data[Constants.Network.paramDownloadCount] as? Int
        self.status = data[Constants.Network.paramStatus] as? String
        self.tags = data[Constants.Network.paramTags] as? [String]
    
        if let assetList = data[Constants.Network.paramAssetList] as? [[String: Any]] {
            self.assetList = assetList.flatMap({ (dict) > Asset? in
                return Asset(data: dict)
            })
        }

        self.bgAudioEnable = data[Constants.Network.paramBgAudioEnable] as? Bool
        self.height = data[Constants.Network.paramHeight] as? Int
        self.width = data[Constants.Network.paramWidth] as? Int
        self.ratio = data[Constants.Network.paramRatio] as? String
        self.orientation = data[Constants.Network.paramOrientation] as? String
        self.lock = data[Constants.Network.paramLock] as? BooleanLiteralType
        self.shortDescription = data[Constants.Network.paramShortDescription] as? String

        if let ownerDict = data[Constants.Network.paramOwner] as? [String: Any] {
            self.owner = User(data: ownerDict)
                
            self.name = data[Constants.Network.paramName] as? String
            self.code = data[Constants.Network.paramCode] as? String
            self.thumbnailUrl = data[Constants.Network.paramThumbnailUrl] as? String
            self.symbolUrl = data[Constants.Network.paramSymbolUrl] as? String
        }
    }*/
}
