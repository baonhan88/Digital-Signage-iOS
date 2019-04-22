//
//  WRCurrentTimeGridline.swift
//
//  Created by wayfinder on 2017. 4. 6..
//  Copyright © 2017년 revo. All rights reserved.
//

import UIKit

class WRCurrentTimeGridline: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.init(r: 253, g: 57, b: 53)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
