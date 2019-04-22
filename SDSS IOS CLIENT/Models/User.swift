//
//  User.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 24/04/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import EVReflection

class User: EVObject {
    var token: String = ""
    var id: String = ""
    var username: String = ""
    var displayName: String = ""
    var email: String = ""
    var userRight: String = ""
    var avatarUrl: String = ""
    
    override func setValue(_ value: Any!, forUndefinedKey key: String) {
        if key == "id" {
            return
        }
    }
    
    func saveUserDataToUserDefault() {
        let userDefault = UserDefaults.standard
        userDefault.setValue(self.token, forKey: Network.paramToken)
        userDefault.setValue(self.id, forKey: Network.paramId)
        userDefault.setValue(self.username, forKey: Network.paramUsername)
        userDefault.setValue(self.displayName, forKey: Network.paramDisplayName)
        userDefault.setValue(self.email, forKey: Network.paramEmail)
        userDefault.setValue(self.avatarUrl, forKey: Network.paramAvatarUrl)
    }
    
    func removeUserData() {
        let userDefault = UserDefaults.standard
        userDefault.removeObject(forKey: Network.paramToken)
    }
    
    /*init() {
        self.token = ""
        self.userId = ""
        self.username = ""
        self.displayName = ""
        self.email = ""
        self.avatarUrl = ""
    }
    
    init(data: [String: Any]) {
        self.token = data[Constants.Network.paramToken] as? String
        self.userId = data[Constants.Network.paramId] as? String
        self.username = data[Constants.Network.paramUsername] as? String
        self.displayName = data[Constants.Network.paramDisplayName] as? String
        self.email = data[Constants.Network.paramEmail] as? String
        self.avatarUrl = data[Constants.Network.paramAvatarUrl] as? String
    }*/
}
