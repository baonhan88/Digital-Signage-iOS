//
//  Asset.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 12/05/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import EVReflection

class Asset: EVObject {
    var id: String = ""
    var md5: String = ""
    var ext: String = ""
    var name: String = ""
    
    /*init() {
        self.id = ""
        self.md5 = ""
        self.ext = ""
    }
    
    init(data: [String: Any]) {
        self.id = data[Constants.Network.paramId] as? String
        self.md5 = data[Constants.Network.paramMd5] as? String
        self.ext = data[Constants.Network.paramExt] as? String
    }*/
    
    func processUpdateAssetWithNewAsset(_ newAsset: Asset, andPresentationId presentationId: String) {
        // update asset file name in presentation folder
        let oldAssetFileURL = Utility.getUrlFromDocumentWithAppend(url: Dir.savePresentation + presentationId + "/" + self.id + self.ext)
        let newAssetFileURL = Utility.getUrlFromDocumentWithAppend(url: Dir.savePresentation + presentationId + "/" + newAsset.id + newAsset.ext)
        DesignFileHelper.replaceFileAt(origionalUrl: oldAssetFileURL, withItemAt: newAssetFileURL)
        
        // update asset id in presentation & regionList of designFile
        DesignFileHelper.updateOldAssetId(self.id, withNewAssetId: newAsset.id, andPresentationId: presentationId)
    }
}
