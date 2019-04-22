//
//  AssetDetail.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 30/08/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import EVReflection

class AssetDetail: EVObject {
    var id: String = ""
    var assetType: String = ""
    var updatedDate: String = ""
    var createdDate: String = ""
    var isPrivate: Bool = false
    var hasThumbnail: Bool = false
    var copyright: String = ""
    var sourceLink: String = ""
    var downloadCount: Int = 0
    var size: Double = 0
    var md5: String = ""
    var height: CGFloat = 0
    var duration: Int = 0
    var width: CGFloat = 0
    var status: String = ""
    var fileType: String = ""
    var owner: User = User()
    var value: Int = 0
    var name: String = ""
    var tags: [String] = []
    var metaData: String = ""
    
    override func setValue(_ value: Any!, forUndefinedKey key: String) {
        if key == "_id" {
            return
        }
    }
}
