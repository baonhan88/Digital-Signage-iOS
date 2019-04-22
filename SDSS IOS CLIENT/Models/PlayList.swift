//
//  PlayList.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 21/06/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import EVReflection

class PlayList: EVObject {
    var id: String = ""
    var name: String = ""
    var updatedDate: String = ""
    var createdDate: String = ""
    var displayList: [PlayListPresentation] = []
    var shortDescription: String = ""
    var group: Group = Group()
    var status: String = ""
    var owner: User = User()
    var totalTime: Int = 0
    var code: String = ""
    var isLoop: Bool = false
    
    override func setValue(_ value: Any!, forUndefinedKey key: String) {
        if key == "_id" {
            return
        }
    }
}
