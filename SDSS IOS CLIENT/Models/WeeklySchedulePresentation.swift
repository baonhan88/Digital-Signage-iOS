//
//  WeeklySchedulePresentation.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 03/07/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import EVReflection

class WeeklySchedulePresentation: EVObject {
    var youtube: String = ""
    var sourceLink: String = ""
    var zOrder: Int = 0
    var startDay: String = ""
    var mimeType: String = ""
    var type: String = ""
    var presentation: String = ""
    var code: String = ""
    var colorLabel: String = ""
    var eventName: String = ""
    var duration: Int = 0 // minutes
    var thumbnail: String = ""
    var startTime: Int = 0 // minutes
    var name: String = ""
    var google_drive: String = ""
    var playlist: String = ""
    
    // just use for comparing
    var id: String = UUID.init().uuidString
    
    override func skipPropertyValue(_ value: Any, key: String) -> Bool {
        if key == "id" {
            return true
        }
        return false
    }
}
