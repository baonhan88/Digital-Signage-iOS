//
//  Device.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 26/04/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import EVReflection

class Device: EVObject {
    var id: String = ""
    var pinCode: String = ""
    var socketId: String = ""
    var updatedDate: String = ""
    var activatedDate: String = ""
    var lastAccessDate: String = ""
    var registeredDate: String = ""
    var producedDate: String = ""
    var overlayingEvent: Event = Event()
    var displayingContent: Presentation = Presentation()
    var holdingPresentationId: String = ""
    var holdingContentId: String = ""
    var holdingContentType: String = ""
    var playingPresentationId: String = ""
    var playingContentId: String = ""
    var playingContentType: String = ""
    var isRealTime: Bool = false
    var softwareVersion: String = ""
    var osVersion: String = ""
    var operationSystem: String = ""
    var liveStatus: String = ""
    var status: String = ""
    var location: Location = Location()
    var snapshotPath: String = ""
    var displayHeight: Int = 0
    var displayWidth: Int = 0
    var macAddress: String = ""
    var ipAddress: String = ""
    var owner: User = User()
    var name: String = ""
    var isLocalOnline: Bool = false
    
    // new properties 2019/01/16
    var scheduleContent: [Content] = []
    var shortDescription: String = ""
    var events: [Event] = []
    var content: Content = Content()
    var playingContent: Content = Content()
    var playingWidget: [String] = []
    var swVersion: String = ""
    var defLanguage: String = ""
    var os: String = ""
    var alignDisplay: String = ""
    var autoScale: String = ""
    // extraFuncsEnable???
    var playStatus: String = ""
    var isDim: Bool = false
    var isAutoLocate: Bool = false
    var totalStorage: Double = 0
    var freeStorage: Double = 0
    var accessToken: String = ""
    var bluetoothMAC: String = ""
    // sharedList???
    var desc: String = ""
    var group: Group = Group()
    
    // use only for business logic purpose, not come from Cloud
    var isChoose: Bool = false
    
    override func setValue(_ value: Any!, forUndefinedKey key: String) {
        if key == "_id" {
            return
        }
    }
    
    required init() {
//        fatalError("init() has not been implemented")
    }
    
    required init(id: String, pinCode: String) {
        
    }
    
    required init(coder decoder: NSCoder) {
        self.id = decoder.decodeObject(forKey: "id") as? String ?? ""
        self.pinCode = decoder.decodeObject(forKey: "pinCode") as? String ?? ""
        self.socketId = decoder.decodeObject(forKey: "socketId") as? String ?? ""
        self.status = decoder.decodeObject(forKey: "status") as? String ?? ""
        self.liveStatus = decoder.decodeObject(forKey: "liveStatus") as? String ?? ""
        self.isLocalOnline = decoder.decodeBool(forKey: "isLocalOnline")
        self.name = decoder.decodeObject(forKey: "name") as? String ?? ""
    }
    
    override func encode(with coder: NSCoder) {
        coder.encode(id, forKey: "id")
        coder.encode(pinCode, forKey: "pinCode")
        coder.encode(socketId, forKey: "socketId")
        coder.encode(status, forKey: "status")
        coder.encode(liveStatus, forKey: "liveStatus")
        coder.encode(isLocalOnline, forKey: "isLocalOnline")
        coder.encode(name, forKey: "name")
    }
}
