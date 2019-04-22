//
//  WeeklySchedule.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 03/07/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import EVReflection

class WeeklySchedule: EVObject {
    var isLoop: Bool = false
    var createdDate: String = ""
    var displaySchedule: [WeeklySchedulePresentation] = []
    var status: String = ""
    var owner: User = User()
    var code: String = ""
    var updatedDate: String = ""
    var id: String = ""
    var shortDescription: String = ""
    var name: String = ""
    
    
    override func setValue(_ value: Any!, forUndefinedKey key: String) {
        if key == "_id" {
            return
        }
    }
}
