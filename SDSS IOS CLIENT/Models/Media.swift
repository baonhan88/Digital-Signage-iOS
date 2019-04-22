//
//  Media.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 16/05/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import EVReflection

class Media: EVObject {
    var x: CGFloat = 0
    var y: CGFloat = 0
    var width: CGFloat = 0
    var height: CGFloat = 0
    var rotate: CGFloat = 0
    var bgColor: String = ""
    var type: String = ""
    
    // What you need to do to get the correct type for when you deserialize inherited classes
    override func getSpecificType(_ dict: NSDictionary) -> EVReflectable {
        guard let type = dict["type"] as? String else {
            return self
        }
        
        switch type {
        case MediaType.webpage.name():
            return Webpage()
        case MediaType.image.name():
            return Image()
        case MediaType.video.name():
            return Video()
        case MediaType.text.name():
            return Text()
        case MediaType.frame.name():
            return Frame()
        case MediaType.widget.name():
            return Widget()
        default:
            return self
        }
    }
}
