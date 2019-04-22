//
//  InstantMessage.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 08/05/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import EVReflection

class InstantMessage: EVObject {
    var message: String = ""
    var ttsMsg: String = ""
    var isTTS: Bool = false
    var volTTS: Int = 10
    var duration: Int = 10
    
    var animationEffect: Int = 0
    var isBold: Bool = false
    var isItalic: Bool = false
    
    var fontName: String = "Arial"
    var fontSize: Int = 30
    var fontColor: String = "#ffffff"
    
    var positionName: String = ""
    var position: String = "middlecenter"
    var customTopPosition: Int = 0
    var customLeftPosition: Int = 0
    
    var isFullscreen: Bool = false
    var isLoopSchedule: Bool = false
    var isSchedule: Bool = false
    var TTSRepeat: Bool = false
    var effect: Int = 0
    var bgColor: String = "#ffffff"
    var color: String = "#000000"
    var timeSchedule: String = ""
    var isTextLoop: Bool = false
    var textEffectIn: String = ""
    
    func generateJsonContentData() -> String {
        let jsonObject: NSMutableDictionary = NSMutableDictionary()
        
        jsonObject.setValue(message, forKey: "message")
        jsonObject.setValue(ttsMsg, forKey: "ttsMsg")
        jsonObject.setValue(isTTS, forKey: "isTTS")
        jsonObject.setValue(position, forKey: "position")
        jsonObject.setValue(fontColor, forKey: "color")
        jsonObject.setValue(isBold, forKey: "isBold")
        jsonObject.setValue(isItalic, forKey: "isItalic")
        jsonObject.setValue(fontSize, forKey: "fontSize")
        jsonObject.setValue(fontName, forKey: "fontName")
        
        let jsonData: NSData
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions()) as NSData
            let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue)! as String
            
            return jsonString
            
        } catch _ {
            print ("JSON Failure")
        }
        
        return ""
    }
}
