//
//  PageInfo.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 26/04/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import EVReflection

class PageInfo: EVObject {
    var current: Int = 0
    var prev: Int = 0
    var hasPrev: Bool = false
    var next: Int = 0
    var hasNext: Bool = true
    var total: Int = 0
    
    /*init() {
        self.current = 0
        self.hasNext = true
    }
    
    init(data: [String: Any]) {
        self.current = data[Constants.Network.paramCurrent] as? Int
        self.prev = data[Constants.Network.paramPrev] as? Int
        self.hasPrev = data[Constants.Network.paramHasPrev] as? Bool
        self.next = data[Constants.Network.paramNext] as? Int
        self.hasNext = data[Constants.Network.paramHasNext] as? Bool
        self.total = data[Constants.Network.paramTotal] as? Int
    }*/

}
