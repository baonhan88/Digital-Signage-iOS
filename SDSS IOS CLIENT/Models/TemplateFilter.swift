//
//  TemplateFilter.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 22/10/2018.
//  Copyright © 2018 SLab. All rights reserved.
//

import UIKit
import EVReflection
import SwiftyJSON

class TemplateFilter: EVObject {
    var isMine: Bool = true
    var isPublic: Bool = false
    var isLock: Bool = false
    var group: Group = Group()
    var tagList: [Tag] = []
    
    var selectedTagIdList: [String] = []
    
//    func generateSelectedFilterJson() -> String {
//        let selectedFilterArray: NSMutableArray = NSMutableArray()
//        
//        // init filter for isMine
//        if self.isMine == true {
//            let mineFilter = Filter.init()
//            mineFilter.key = "owner"
//            mineFilter.operator = "="
//            mineFilter.value = "mine"
//        }
//        
//        // init filter for isPublic
//        let publicFilter = Filter.init()
//        publicFilter.key = "public"
//        publicFilter.operator = "="
//        if self.isPublic == true {
//            publicFilter.value = "true"
//        } else {
//            publicFilter.value = "false"
//        }
//        selectedFilterArray.add(publicFilter)
//        
//        // init filter for isLock
//        let lockFilter = Filter.init()
//        lockFilter.key = "lock"
//        lockFilter.operator = "="
//        if self.isLock == true {
//            lockFilter.value = "true"
//        } else {
//            lockFilter.value = "false"
//        }
//        selectedFilterArray.add(lockFilter)
//        
//        // init filter for Group
//        if group.name != "" {
//            let groupFilter = Filter.init()
//            groupFilter.key = "group"
//            groupFilter.operator = "="
//            groupFilter.value = group.id
//            
//            selectedFilterArray.add(groupFilter)
//        }
//        
//        // init filter for Tags
//        if selectedTagIdList.count > 0 {
//            var tagIdListString = ""
//            
//            var count = 0
//            for tagIdString in self.selectedTagIdList as! [String] {
//                if count == 0 {
//                    tagIdListString.append(tagIdString)
//                } else {
//                    tagIdListString.append(",")
//                    tagIdListString.append(tagIdString)
//                }
//                
//                count += 1
//            }
//            
//            let tagFilter = Filter.init()
//            tagFilter.key = "tags"
//            tagFilter.operator = "in"
//            tagFilter.value = "[" + tagIdListString + "]"
//            
//            selectedFilterArray.add(tagFilter)
//        }
//        
//        guard let jsonString = Utility.convertToJson(from: selectedFilterArray) else {
//            return ""
//        }
//        
//        return jsonString
//    }
    
    func generateSelectedFilterJson() -> String {
        let selectedFilterArray: NSMutableArray = NSMutableArray()
        
        // init filter for isMine
        if self.isMine == true {
            let mineFilter = NSMutableDictionary.init()
            mineFilter.setObject("owner", forKey: "key" as NSCopying)
            mineFilter.setObject("=", forKey: "operator" as NSCopying)
            mineFilter.setObject("mine", forKey: "value" as NSCopying)
            
            selectedFilterArray.add(mineFilter)
        }
        
        // init filter for isPublic
        let publicFilter = NSMutableDictionary.init()
        publicFilter.setObject("public", forKey: "key" as NSCopying)
        publicFilter.setObject("=", forKey: "operator" as NSCopying)
        if self.isPublic == true {
            publicFilter.setObject("true", forKey: "value" as NSCopying)
        } else {
            publicFilter.setObject("false", forKey: "value" as NSCopying)
        }
        selectedFilterArray.add(publicFilter)
        
        // init filter for isLock
        let lockFilter = NSMutableDictionary.init()
        lockFilter.setObject("lock", forKey: "key" as NSCopying)
        lockFilter.setObject("=", forKey: "operator" as NSCopying)
        if self.isLock == true {
            lockFilter.setObject("true", forKey: "value" as NSCopying)
        } else {
            lockFilter.setObject("false", forKey: "value" as NSCopying)
        }
        selectedFilterArray.add(lockFilter)
        
        // init filter for Group
        if group.name != "" {
            let groupFilter = NSMutableDictionary.init()
            groupFilter.setObject("group", forKey: "key" as NSCopying)
            groupFilter.setObject("=", forKey: "operator" as NSCopying)
            groupFilter.setObject(group.id, forKey: "value" as NSCopying)
            selectedFilterArray.add(groupFilter)
        }
        
        // init filter for Tags
        if selectedTagIdList.count > 0 {
            let tagFilter = NSMutableDictionary.init()
            tagFilter.setObject("tags", forKey: "key" as NSCopying)
            tagFilter.setObject("in", forKey: "operator" as NSCopying)
            tagFilter.setObject(self.selectedTagIdList, forKey: "value" as NSCopying)
            
            selectedFilterArray.add(tagFilter)
        }
        
        guard let jsonString = Utility.convertToJson(from: selectedFilterArray) else {
            return ""
        }
        
        return jsonString
    }
}

class Filter: EVObject {
    var key: String = ""
    var `operator`: String = ""
    var value: String = ""
}
