//
//  DisplayEvent.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 11/01/2019.
//  Copyright © 2019 SLab. All rights reserved.
//

import UIKit
import EVReflection

class DisplayEvent: EVObject {
    var id: String = ""
    var name: String = ""
    var updatedDate: String = ""
    var createdDate: String = ""
    var duration: Int = 10
    var playTime: String = "2019-01-16T10:52:34 09:00"
    var contentData: InstantMessage = InstantMessage()
    var status: String = ""
    var infoLevel: String = "INFO"
    var eventType: String = ""
    var isSystem: Bool = false
    var isPrivate: Bool = false
    var owner: User = User()
    
    override func setValue(_ value: Any!, forUndefinedKey key: String) {
        if key == "_id" {
            return
        } else if key == "data" {
            self.contentData = (InstantMessage)(json: value as? String)
            
            return
        }

    }
}
