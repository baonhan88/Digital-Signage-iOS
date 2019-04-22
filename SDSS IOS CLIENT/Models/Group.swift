//
//  PlayListGroup.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 21/06/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import EVReflection

class Group: EVObject {
    var status: String = ""
    var createdDate: String = ""
    var refCount: Int = 0
    var contentType: String = ""
    var updater: User  = User()
    var owner: User = User()
    var updatedDate: String = ""
    var id: String = ""
    var name: String = ""
    var isPrivate: Bool = false
    
    override func setValue(_ value: Any!, forUndefinedKey key: String) {
        if key == "_id" {
            return
        }
    }
}
