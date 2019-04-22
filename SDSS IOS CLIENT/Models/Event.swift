//
//  Event.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 17/05/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import EVReflection

class Event: EVObject {
    var id: String = ""
    var name: String = ""
    var eventType: String = ""
//    var playTime: String = ""
    var duration: Int = 0
//    var data: String = ""
    var type: String = ""
    var timeSchedule: String = ""
    var isSchedule: Bool = false
    var isLoopSchedule: Bool = false
}
