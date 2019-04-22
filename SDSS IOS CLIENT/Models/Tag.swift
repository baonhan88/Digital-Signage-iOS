//
//  Tag.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 12/05/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import EVReflection

class Tag: EVObject {
    var id: String = ""
    var refCount: Int = 0
    var accessRight: String = ""
    var createdDate: String = ""
    var owner: User = User()
    var updatedDate: String = ""
    var value: String = ""
    var viValue: String = ""
    var cnValue: String = ""
    var koValue: String = ""
    var symbolUrl: String = ""
    var isPrivate: Bool = false
    var tagType: String = ""
    var updater: User = User()
    var isSystem: Bool = false
    var status: String = ""

    var isMore: Bool = false
    
    // use only for business logic purpose, not come from Cloud
    var isChoose: Bool = false
    
    override func setValue(_ value: Any!, forUndefinedKey key: String) {
        if key == "_id" {
            return
        }
    }
    
    /*init() {
        self.id = ""
        self.value = ""
        self.updatedDate = ""
        self.createdDate = ""
        self.symbolUrl = ""
        self.status = ""
        self.accessRight = ""
        self.isSystem = false
        self.isPrivate = false
        self.updater = User()
        self.owner = User()
        self.tagType = ""
    }
    
    init(data: [String: Any]) {
        self.id = data[Constants.Network.paramId] as? String
        self.value = data[Constants.Network.paramValue] as? String
        self.updatedDate = data[Constants.Network.paramUpdatedDate] as? String
        self.createdDate = data[Constants.Network.paramCreatedDate] as? String
        self.symbolUrl = data[Constants.Network.paramSymbolUrl] as? String
        self.status = data[Constants.Network.paramStatus] as? String
        self.accessRight = data[Constants.Network.paramAccessRight] as? String
        self.isSystem = data[Constants.Network.paramIsSystem] as? Bool
        self.isPrivate = data[Constants.Network.paramIsPrivate] as? Bool
        if let updaterDict = data[Constants.Network.paramUpdater] as? [String: Any] {
            self.updater = User(data: updaterDict)
        }
        if let ownerDict = data[Constants.Network.paramOwner] as? [String: Any] {
            self.owner = User(data: ownerDict)
            self.tagType = data[Constants.Network.paramTagType] as? String
        }
    }*/
}
