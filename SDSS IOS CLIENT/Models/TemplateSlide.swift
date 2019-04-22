//
//  TemplateSlide.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 01/06/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import EVReflection
import SwiftyJSON

class TemplateSlide: EVObject {
    var id: String = ""
    var presentationId: String = ""
    var code: String = ""
    var userId: String = ""
    var name: String = ""
    var duration: Int = 0
    var totalSteps: Int = 0
    var isTemplate: Bool = false
    var thumbnailUrl: String = ""
    var isLatest: Bool = true
    
    static func processSaveTemplateDownloadedInfo(presentation: Presentation) {
        let insertObject = TemplateSlide()
        insertObject.id = presentation.id
        insertObject.presentationId = presentation.id
        insertObject.userId = (UserDefaults.standard.value(forKey: Network.paramUsername) as? String)!
        insertObject.isTemplate = true
        
        // get templateSlider.json file
        let fileUrl = Utility.getUrlFromDocumentWithAppend(url: Dir.templateSlideFile)
        if !FileManager.default.fileExists(atPath: fileUrl.path) { // if not exist -> create new
            let json: JSON = [insertObject.toDictionary()]
            //convert the JSON to raw NSData
            do {
                let rawData = try json.rawData()
                try rawData.write(to: fileUrl, options: .atomic)
            } catch {
                dLog(message: error.localizedDescription)
            }
            
        } else {
            // if exist -> insert new data
            do {
                let jsonData = NSData(contentsOfFile: fileUrl.path)
                let json = JSON(data: jsonData! as Data).arrayObject
                
                // check if not exist -> insert new data
                let newTemplateList: NSMutableArray = NSMutableArray.init(array: json!)
                var isExist = false
                for dict in (newTemplateList as? [NSDictionary])! {
                    let tmp = TemplateSlide(dictionary: dict as NSDictionary)
                    if tmp.presentationId == insertObject.presentationId {
                        isExist = true
                        break
                    }
                }
                
                if !isExist {
                    newTemplateList.add(insertObject.toDictionary())
                    
                    // save new templateSlide.json
                    let newJson = JSON(newTemplateList)
                    let rawData = try newJson.rawData()
                    try rawData.write(to: fileUrl, options: .atomic)
                }
            
            } catch {
                dLog(message: error.localizedDescription)
            }
        }
        
    }
    
    static func processSaveNewPresentation(presentationId: String, completion: @escaping (Bool) -> Void) {
        let insertObject = TemplateSlide()
        insertObject.id = presentationId
        insertObject.presentationId = presentationId
        insertObject.userId = (UserDefaults.standard.value(forKey: Network.paramUsername) as? String)!
        insertObject.isTemplate = false
        
        // templateSlider.json file URL
        let fileUrl = Utility.getUrlFromDocumentWithAppend(url: Dir.templateSlideFile)
        if !FileManager.default.fileExists(atPath: fileUrl.path) { // if not exist -> create new
            let json: JSON = [insertObject.toDictionary()]
            //convert the JSON to raw NSData
            do {
                let rawData = try json.rawData()
                try rawData.write(to: fileUrl, options: .atomic)
            } catch {
                dLog(message: error.localizedDescription)
                completion(false)
                return
            }
        } else {
            // insert new presentation
            do {
                let jsonData = NSData(contentsOfFile: fileUrl.path)
                let json = JSON(data: jsonData! as Data).arrayObject
                
                // insert new presentation
                let newTemplateList: NSMutableArray = NSMutableArray.init(array: json!)
                newTemplateList.add(insertObject.toDictionary())
                
                // generate & save new templateSlide.json
                let newJson = JSON(newTemplateList)
                let rawData = try newJson.rawData()
                try rawData.write(to: fileUrl, options: .atomic)
                
            } catch {
                dLog(message: error.localizedDescription)
                completion(false)
                return
            }
        }
        
        completion(true)
    }
    
    static func getTemplateDownloadedListForCurerntUser() -> [String] {
        let fileUrl = Utility.getUrlFromDocumentWithAppend(url: Dir.templateSlideFile)
        if FileManager.default.fileExists(atPath: fileUrl.path) {
            let jsonData = NSData(contentsOfFile: fileUrl.path)
            let json = JSON(data: jsonData! as Data).arrayObject
            
            let templateList: NSMutableArray = NSMutableArray()
            
            for dict in json as! [NSDictionary] {
                let templateSlide = TemplateSlide(dictionary: dict)
                if templateSlide.userId == Utility.getUsername() && templateSlide.isTemplate {
                    templateList.add(templateSlide.presentationId)
                }
            }
            
            return templateList as! [String]
            
        } else {
            dLog(message: "templateSlide.json not exist")
            return []
        }
    }
    
    static func getPresentationListForCurerntUser() -> [TemplateSlide] {
        let fileUrl = Utility.getUrlFromDocumentWithAppend(url: Dir.templateSlideFile)
        if FileManager.default.fileExists(atPath: fileUrl.path) {
            let jsonData = NSData(contentsOfFile: fileUrl.path)
            let json = JSON(data: jsonData! as Data).arrayObject
            
            let templateList: NSMutableArray = NSMutableArray()
            
            for dict in json as! [NSDictionary] {
                let templateSlide = TemplateSlide(dictionary: dict)
                if templateSlide.userId == Utility.getUsername() && templateSlide.isTemplate == false {
                    templateList.add(templateSlide)
                }
            }
            
            return templateList as! [TemplateSlide]
            
        } else {
            dLog(message: "templateSlide.json not exist")
            return []
        }
    }
    
    static func getTemplateList() -> [TemplateSlide]? {
        let fileUrl = Utility.getUrlFromDocumentWithAppend(url: Dir.templateSlideFile)
        if FileManager.default.fileExists(atPath: fileUrl.path) {
            let jsonData = NSData(contentsOfFile: fileUrl.path)
            let json = JSON(data: jsonData! as Data).arrayObject
            
            let templateList = json?.flatMap({ (dict) -> TemplateSlide? in
                return TemplateSlide(dictionary: (dict as? NSDictionary)!)
            })
            
            return templateList!
        } else {
            dLog(message: "templateSlide.json not exist")
            return nil
        }
    }
    
    static func deleteTemplateForCurrentUser(presentationId: String) {
        let fileUrl = Utility.getUrlFromDocumentWithAppend(url: Dir.templateSlideFile)

        let jsonData = NSData(contentsOfFile: fileUrl.path)
        let json = JSON(data: jsonData! as Data).arrayObject
        
        // check if exist -> delete template
        let newTemplateList: NSMutableArray = NSMutableArray.init(array: json!)
        for dict in (newTemplateList as? [NSDictionary])! {
            let tmp = TemplateSlide(dictionary: dict as NSDictionary)
            if tmp.presentationId == presentationId && tmp.isTemplate == true {
                newTemplateList.remove(dict)
                break
            }
        }
        
        // save new templateSlide.json
        saveNewTemplateSlide(templateSlide: newTemplateList as! [NSDictionary])
    }
    
    static func deletePresentationForCurrentUser(presentationId: String) {
        let fileUrl = Utility.getUrlFromDocumentWithAppend(url: Dir.templateSlideFile)
        
        let jsonData = NSData(contentsOfFile: fileUrl.path)
        let json = JSON(data: jsonData! as Data).arrayObject
        
        // check if exist -> delete template
        let newTemplateList: NSMutableArray = NSMutableArray.init(array: json!)
        for dict in (newTemplateList as? [NSDictionary])! {
            let tmp = TemplateSlide(dictionary: dict as NSDictionary)
            if tmp.presentationId == presentationId && tmp.isTemplate == false {
                newTemplateList.remove(dict)
                break
            }
        }
        
        // save new templateSlide.json
        saveNewTemplateSlide(templateSlide: newTemplateList as! [NSDictionary])
    }
    
    // check presentation (Template + Presentation) exist in local
    // if exist && isTemplate -> return ""
    // if exist && isPresentaion -> return folderName
    // if no -> return nil
    static func checkPresentationExist(presentationId: String) -> String? {
//        guard let templateSlideList = gettem else {
//            <#statements#>
//        }
        
        return nil
    }
    
    static func saveNewTemplateSlide(templateSlide: [NSDictionary]) {
        let newJson = JSON(templateSlide)
        let fileUrl = Utility.getUrlFromDocumentWithAppend(url: Dir.templateSlideFile)
        do {
            let rawData = try newJson.rawData()
            try rawData.write(to: fileUrl, options: .atomic)
        } catch  {
            dLog(message: error.localizedDescription)
        }
    }
    
    static func updateNewPresentationId(_ newPresentationId: String, fromOldPresentationId oldPresentationId: String) {
        guard let templateSlideList = getTemplateList() else {
            dLog(message: "can't load templateSlide.json")
            return
        }
        
        // update with new id
        if templateSlideList.count > 0 {
            for templateSlide in templateSlideList {
                if templateSlide.id == oldPresentationId {
                    templateSlide.id = newPresentationId
                    templateSlide.presentationId = newPresentationId
                }
            }
        }
        
        // save to document
        let templateSlideDictList = templateSlideList.flatMap({ (templateSlide) -> NSDictionary? in
            return templateSlide.toDictionary()
        })
        
        // save new templateSlide.json
        saveNewTemplateSlide(templateSlide: templateSlideDictList)
    }
    
    static func isExistPresentation(presentationId: String) -> Bool {
        let templateSlideList = getPresentationListForCurerntUser()
        for templateSlide in templateSlideList {
            if templateSlide.presentationId == presentationId {
                return true
            }
        }
        return false
    }
    
    static func getFirstPresentationForCurerntUser() -> TemplateSlide? {
        let fileUrl = Utility.getUrlFromDocumentWithAppend(url: Dir.templateSlideFile)
        if FileManager.default.fileExists(atPath: fileUrl.path) {
            let jsonData = NSData(contentsOfFile: fileUrl.path)
            let json = JSON(data: jsonData! as Data).arrayObject
                        
            for dict in json as! [NSDictionary] {
                let templateSlide = TemplateSlide(dictionary: dict)
                if templateSlide.userId == Utility.getUsername() && templateSlide.isTemplate == false {
                    return templateSlide
                }
            }
            
            return nil
            
        } else {
            dLog(message: "templateSlide.json not exist")
            return nil
        }
    }

}
