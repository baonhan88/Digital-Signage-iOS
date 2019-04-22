//
//  Dataset.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 12/12/2018.
//  Copyright © 2018 SLab. All rights reserved.
//

import UIKit
import EVReflection

class Dataset: EVObject {
    var id: String = ""
    var name: String = ""
    var columns: [DatasetType] = []
    var dataList: [DatasetData] = []
    var isPrivate: Bool = false
    var isSystem: Bool = false
    var updatedDate: String = ""
    var createdDate: String = ""
    var app: String = ""
    var status: String = ""
    var owner: User = User()
    var updater: User = User()
    
    override func setValue(_ value: Any!, forUndefinedKey key: String) {
        if key == "_id" {
            return
        } else if key == "data" {
            self.dataList = [DatasetData](json: value as? String)
            
            return
        }
    }
    
//    override func skipPropertyValue(_ value: Any, key: String) -> Bool {
//        if key == "data" {
//            self.data = [DatasetData](json: value as? String)
//            
//            return false
//        }
//        
//        return false
//    }
    
    required init() {
        
    }
    
    func initColumns() {
        let column1: DatasetType = DatasetType.init(code: "customer", dataType: "STRING", name: "Customer")
        let column2: DatasetType = DatasetType.init(code: "time", dataType: "SHORT_TIME", name: "Time")
        let column3: DatasetType = DatasetType.init(code: "slot", dataType: "STRING", name: "Slot")
        let column4: DatasetType = DatasetType.init(code: "position", dataType: "STRING", name: "Position")

        columns.append(column1)
        columns.append(column2)
        columns.append(column3)
        columns.append(column4)
    }
}

class DatasetType: EVObject {
    var code: String = ""
    var dataType: String = ""
    var name: String = ""
    
    required init() {
        
    }
    
    required init(code: String, dataType: String, name: String) {
        self.code = code
        self.dataType = dataType
        self.name = name
    }
}

class DatasetData: EVObject {
    var area: String = ""
    var customer: String = ""
    var slot: String = ""
    var time: String = ""
    
    required init() {
        
    }
    
    required init(customer: String, time: String, slot: String, area: String) {
        self.customer = customer
        self.time = time
        self.slot = slot
        self.area = area
    }
}

