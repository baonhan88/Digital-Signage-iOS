//
//  Weekly.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 03/07/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import EVReflection

class RealTimeSchedule: EVObject {
    var id: String = ""
    var name: String = ""
    var updatedDate: String = ""
    var createdDate: String = ""
    var displayCalendar: [RealTimeSchedulePresentation] = []
    var shortDescription: String = ""
    var group: Group = Group()
    var status: String = ""
    var owner: User = User()
    var code: String = ""
    
    override func setValue(_ value: Any!, forUndefinedKey key: String) {
        if key == "_id" {
            return
        }
    }
}
