//
//  PhotoLibraryManager.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 07/01/2019.
//  Copyright © 2019 SLab. All rights reserved.
//

import Foundation
import UIKit

class PhotoLibraryManager: NSObject {
    
    static let shared = PhotoLibraryManager()
    
    fileprivate var currentVC: UIViewController!
    
    //MARK: Internal Properties
    var imagePickedBlock: ((UIImage) -> Void)?
    
    func camera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = .camera
            currentVC.present(myPickerController, animated: true, completion: nil)
        }
    }
    
    func photoLibrary() {
        AppUtility.lockOrientation(.all)

        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = .photoLibrary
            currentVC.present(myPickerController, animated: true, completion: nil)
        }
    }
    
    func showActionSheet(vc: UIViewController) {
        self.currentVC = vc
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: localizedString(key: "presentation_editor_update_image_take_photo_option"), style: .default, handler: { (alert:UIAlertAction!) -> Void in
            self.camera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: localizedString(key: "presentation_editor_update_image_camera_roll_option"), style: .default, handler: { (alert:UIAlertAction!) -> Void in
            self.photoLibrary()
        }))
        
        actionSheet.addAction(UIAlertAction(title: localizedString(key: "common_cancel"), style: .cancel, handler: nil))
        
        currentVC.present(actionSheet, animated: true, completion: nil)
    }
}

// MARK: - AssetEditViewControllerDelegate

extension PhotoLibraryManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        AppUtility.lockOrientation(.landscapeLeft, andRotateTo: .landscapeLeft)

        currentVC.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imagePickedBlock?(image)
        } else {
            dLog(message: localizedString(key: "common_error_message"))
        }
        
        AppUtility.lockOrientation(.landscapeLeft, andRotateTo: .landscapeLeft)

        currentVC.dismiss(animated: true, completion: nil)
    }
}
