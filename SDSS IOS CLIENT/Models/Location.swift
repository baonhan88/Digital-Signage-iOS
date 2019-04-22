//
//  Location.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 26/04/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import EVReflection

class Location: EVObject {
    var latitude: Float = 0
    var longitude: Float = 0
    
    /*init() {
        self.latitude = 0
        self.longitude = 0
    }
    
    init(data: [String: Any]) {
        self.latitude = data[Constants.Network.paramLatitude] as? Float
        self.longitude = data[Constants.Network.paramLongitude] as? Float
    }*/

}
