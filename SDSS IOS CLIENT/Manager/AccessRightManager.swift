//
//  AccessRightManager.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 14/07/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

enum AccessRightType {
    case none
    case read
    case use
    case design
    case update
    case clone
    case sale
    
    func value() -> Int {
        switch self {
        case .none:
            return 0
        case .read:
            return 1
        case .use:
            return 2
        case .design:
            return 4
        case .update:
            return 8
        case .clone:
            return 16
        case .sale:
            return 32
        }
    }
}

class AccessRightManager: NSObject {
    
    static func canRead(accessRight: Int) -> Bool {
        if (accessRight & AccessRightType.read.value()) == AccessRightType.read.value() {
            return true
        }
        return false
    }
    
    static func canUse(accessRight: Int) -> Bool {
        if (accessRight & AccessRightType.use.value()) == AccessRightType.use.value() {
            return true
        }
        return false
    }
    
    static func canDesign(accessRight: Int) -> Bool {
        if (accessRight & AccessRightType.design.value()) == AccessRightType.design.value() {
            return true
        }
        return false
    }
    
    static func canUpdate(accessRight: Int) -> Bool {
        if (accessRight & AccessRightType.update.value()) == AccessRightType.update.value() {
            return true
        }
        return false
    }
    
    static func canClone(accessRight: Int) -> Bool {
        if (accessRight & AccessRightType.clone.value()) == AccessRightType.clone.value() {
            return true
        }
        return false
    }
    
    static func canSale(accessRight: Int) -> Bool {
        if (accessRight & AccessRightType.sale.value()) == AccessRightType.sale.value() {
            return true
        }
        return false
    }
    
    static func removeAccessRight(with type: AccessRightType, rootAccessRight: Int) -> Int {
        var newAccessRight = rootAccessRight
        
        switch type {
        case .none:
            break
        case .read:
            if newAccessRight & AccessRightType.read.value() == AccessRightType.read.value() {
                newAccessRight -= AccessRightType.read.value()
            }
            break
        case .use:
            if newAccessRight & AccessRightType.use.value() == AccessRightType.use.value() {
                newAccessRight -= AccessRightType.use.value()
            }
            break
        case .design:
            if newAccessRight & AccessRightType.design.value() == AccessRightType.design.value() {
                newAccessRight -= AccessRightType.design.value()
            }
            break
        case .update:
            if newAccessRight & AccessRightType.update.value() == AccessRightType.update.value() {
                newAccessRight -= AccessRightType.update.value()
            }
            break
        case .clone:
            if newAccessRight & AccessRightType.clone.value() == AccessRightType.clone.value() {
                newAccessRight -= AccessRightType.clone.value()
            }
            break
        case .sale:
            if newAccessRight & AccessRightType.sale.value() == AccessRightType.sale.value() {
                newAccessRight -= AccessRightType.sale.value()
            }
            break
        }
        
        return newAccessRight
    }
    
    static func removeAccessRights(with types: [AccessRightType], rootAccessRight: Int) -> Int {
        var newAccessRight = rootAccessRight
        
        for type in types {
            newAccessRight = removeAccessRight(with: type, rootAccessRight: newAccessRight)
        }
        
        return newAccessRight
    }
}


