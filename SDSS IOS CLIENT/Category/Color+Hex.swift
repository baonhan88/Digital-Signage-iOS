//
//  Color+Hex.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 08/05/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
//    convenience init(sixDigitHexString:String) {
//        let hexString:NSString = sixDigitHexString.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) as NSString
//        let scanner            = Scanner(string: hexString as String)
//        
//        if (hexString.hasPrefix("#")) {
//            scanner.scanLocation = 1
//        }
//        
//        var color:UInt32 = 0
//        scanner.scanHexInt32(&color)
//        
//        let mask = 0x000000FF
//        let r = Int(color >> 16) & mask
//        let g = Int(color >> 8) & mask
//        let b = Int(color) & mask
//        
//        let red   = CGFloat(r) / 255.0
//        let green = CGFloat(g) / 255.0
//        let blue  = CGFloat(b) / 255.0
//        
//        self.init(red:red, green:green, blue:blue, alpha:1)
//    }
    
    public convenience init?(hexString: String) {
        let r, g, b, a: CGFloat
        
        if hexString.hasPrefix("#") && hexString.characters.count == 9 {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            let hexColor = hexString.substring(from: start)
            
            if hexColor.characters.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    a = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    r = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        } else if hexString.characters.count == 6 || hexString.characters.count == 7 {
            let hexString:NSString = hexString.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) as NSString
            let scanner = Scanner(string: hexString as String)
            
            if (hexString.hasPrefix("#")) {
                scanner.scanLocation = 1
            }
            
            var color:UInt32 = 0
            scanner.scanHexInt32(&color)
            
            let mask = 0x000000FF
            let r = Int(color >> 16) & mask
            let g = Int(color >> 8) & mask
            let b = Int(color) & mask
            
            let red   = CGFloat(r) / 255.0
            let green = CGFloat(g) / 255.0
            let blue  = CGFloat(b) / 255.0
            
            self.init(red:red, green:green, blue:blue, alpha:1)
            return
        }
        
        return nil
    }
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let argb:Int = (Int)(a*255)<<24 | (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return NSString(format:"#%08x", argb) as String
    }
}
