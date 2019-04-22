//
//  WeeklyPresentation.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 03/07/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import EVReflection

class RealTimeSchedulePresentation: EVObject {
    var youtube: String = ""
    var sourceLink: String = ""
    var zOrder: Int = 0
    var mimeType: String = ""
    var `repeat`: Bool = false
    var endDate: String = ""
    var presentation: String = ""
    var code: String = ""
    var colorLabel: String = ""
    var type: String = ""
    var eventName: String = ""
    var startDate: String = ""
    var thumbnail: String = ""
    var google_drive: String = ""
    var name: String = ""
    
    // just use for comparing
    var id: String = UUID.init().uuidString
    
    override func skipPropertyValue(_ value: Any, key: String) -> Bool {
        if key == "id" {
            return true
        }
        return false
    }
}
