//
//  UITableView+Extension.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 30/05/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

extension UITableView {
    func registerCellClass(_ cellClass: AnyClass) {
        let identifier = String.className(cellClass)
        self.register(cellClass, forCellReuseIdentifier: identifier)
    }
    
    func registerCellNib(_ cellClass: AnyClass) {
        let identifier = String.className(cellClass)
        let nib = UINib(nibName: identifier, bundle: nil)
        self.register(nib, forCellReuseIdentifier: identifier)
    }
}
