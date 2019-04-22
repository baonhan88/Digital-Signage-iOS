//
//  Region.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 16/05/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import EVReflection

class Region: EVObject {
    var id: String = ""
    var type: String = ""
    var lock: Bool = false
    var zOrder: Int = 0
    var slideEffect: Int = 0
    var slideTime: Int = 0
    var objects: [Media]? = []
}
