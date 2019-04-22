//
//  DevicePlayingContentViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 10/05/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import SVProgressHUD

class DevicePlayingContentViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var device: Device = Device()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = localizedString(key: "device_playing_content_title")
        
        SVProgressHUD.show()
        
//        processCallAPItoTakeSnapshot()
        downloadSnapshot()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func generateSelectedDeviceJson() -> String {
        let selectedDeviceArray: NSMutableArray = NSMutableArray()
        selectedDeviceArray.add(device.pinCode)
        
        let jsonData: NSData
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: selectedDeviceArray, options: JSONSerialization.WritingOptions()) as NSData
            let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue)! as String
            
            return jsonString
            
        } catch _ {
            dLog(message: "JSON Failure")
        }
        
        return ""
    }
    
    fileprivate func processCallAPItoTakeSnapshot() {
        NetworkManager.shared.controlToSnapshot(pinCodeList: generateSelectedDeviceJson(), token: Utility.getToken()) {
            [weak self] (success, message) in
            
            if success {
                // wait for 5 seconds, after that call API to download snapshot
                let when = DispatchTime.now() + 5
                DispatchQueue.main.asyncAfter(deadline: when) {
                    self?.downloadSnapshot()
                }
            } else {
                SVProgressHUD.dismiss()
                Utility.showAlertWithErrorMessage(message: message, controller: self!)
            }
        }
    }
    
    fileprivate func downloadSnapshot() {
        NetworkManager.shared.downloadSnapshot(id: device.id, token: Utility.getToken(), downloadProgress: { (progress) in
            
//            SVProgressHUD.showProgress(progress, status: localizedString(key: "common_downloading"))
            
        }, completion: {
            [weak self] (success, message, image) in
            
            SVProgressHUD.dismiss()
            
            if success {
                self?.imageView.image = image
            } else {
                Utility.showAlertWithErrorMessage(message: message, controller: self!, completion: nil)
            }
        })
    }
    
    @IBAction func cancelButtonClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true) {
            
        }
    }
}
