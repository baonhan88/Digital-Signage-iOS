//
//  BgImage.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 19/06/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import EVReflection

class BgImage: EVObject {
    var value: String = ""
    var type: String = ""
    var assetExt: String = ""
    var md5: String = ""
    
    func isEmpty() -> Bool {
        if self.value == "" && self.type == "" && self.assetExt == "" && self.md5 == "" {
            return true
        }
        return false
    }
}
