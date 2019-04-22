//
//  EditImageViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 31/05/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

protocol EditImageViewControllerDelegate {
    func handleUpdateLocalImage(newImage: UIImage, region: Region?, editImageType: EditImageType)
    func handleUpdateImageFromCloud(assetImage: AssetDetail, region: Region?)
}

class EditImageViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    // input value
    var region: Region?
    var image: UIImage?
    var currentEditImageType: EditImageType = .normal
    
    var delegate: EditImageViewControllerDelegate?
    
    var isFromCloud = false
    var assetDetail: AssetDetail = AssetDetail()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        
        initNavigationBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func initNavigationBar() {
        self.title = localizedString(key: "presentation_editor_update_image_title")
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(handleDoneButtonClicked(barButton:)))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    private func initView() {
//        guard let image = Utility.getFirstImageFromRegion(region: region!) else {
//            return
//        }
//        
//        // get image url
//        let imageURL = Utility.getUrlFromDocumentWithAppend(url: Dir.assets + image.assetId + image.assetExt)
//        
//        guard let tmpImage = UIImage(contentsOfFile: imageURL.path) else {
//            dLog(message: "can't load image from url: \(String(describing: imageURL.path))")
//            return
//        }
        
        imageView.image = image
    }

    fileprivate func showImagePickerWithType(type: UIImagePickerControllerSourceType) {
        AppUtility.lockOrientation(.all)
        
        let picker = UIImagePickerController()
//        picker.allowsEditing = true
        picker.delegate = self
        picker.sourceType = type
        self.present(picker, animated: true)
    }
}

// MARK: - Handle Events 

extension EditImageViewController {
    
    func handleDoneButtonClicked(barButton: UIBarButtonItem) {
        if isFromCloud {
            delegate?.handleUpdateImageFromCloud(assetImage: assetDetail, region: region)
        } else {
            delegate?.handleUpdateLocalImage(newImage: imageView.image!, region: region, editImageType: self.currentEditImageType)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func editImageButtonClicked(_ sender: UIButton) {
        // show actionsheet to choose video type
        let actionSheetController = UIAlertController(title: localizedString(key: "presentation_editor_update_image_actionsheet_title"),
                                                      message: localizedString(key: "presentation_editor_update_image_actionsheet_message"),
                                                      preferredStyle: .actionSheet)
        
        // Create and add the Cancel action
        let cancelAction = UIAlertAction(title: localizedString(key: "common_cancel"), style: .cancel) { action -> Void in
            // Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        
        // Create and add take photo option action
        let takePhotoAction = UIAlertAction(title: localizedString(key: "presentation_editor_update_image_take_photo_option"), style: .default) { action -> Void in
            weak var weakSelf = self
            
            weakSelf?.showImagePickerWithType(type: .camera)
        }
        actionSheetController.addAction(takePhotoAction)
        
        // Create and add choose from camera roll option action
        let cameraRollAction = UIAlertAction(title: localizedString(key: "presentation_editor_update_image_camera_roll_option"), style: .default) { action -> Void in
            weak var weakSelf = self
            
            weakSelf?.showImagePickerWithType(type: .photoLibrary)
        }
        actionSheetController.addAction(cameraRollAction)
        
        // Create and add choose from asset list option action
        let assetListAction = UIAlertAction(title: localizedString(key: "presentation_editor_update_image_asset_list_option"), style: .default) { action -> Void in
            weak var weakSelf = self
            
            ControllerManager.goToAssetListScreen(controller: weakSelf!, assetType: AssetType.image)
        }
        actionSheetController.addAction(assetListAction)
        
        // Present the actionsheet
        self.present(actionSheetController, animated: true, completion: nil)
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate

extension EditImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
        AppUtility.lockOrientation(.landscapeLeft, andRotateTo: .landscapeLeft)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        isFromCloud = false

        var newImage: UIImage
        
        if let possibleImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            newImage = possibleImage
        } else if let possibleImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            newImage = possibleImage
        } else {
            return
        }
        
        imageView.image = newImage
        
        dismiss(animated: true)
        AppUtility.lockOrientation(.landscapeLeft, andRotateTo: .landscapeLeft)
    }
}

// MARK: - AssetSelectionCollectionViewControllerDelegate

extension EditImageViewController: AssetSelectionCollectionViewControllerDelegate {
    
    func handleUpdateAssetFromCloud(assetDetail: AssetDetail) {
        isFromCloud = true
        self.assetDetail = assetDetail
        
        let placeholderImage = UIImage(named: "icon_template_placeholder")!
        
        if let thumbnailUrl = URL.init(string: NetworkManager.shared.baseURL + String.init(format: Network.assetThumbnailUrl, self.assetDetail.id,  Utility.getToken())) {
            Utility.clearImageFromCache(withURL: thumbnailUrl)
            self.imageView.af_setImage(withURL: thumbnailUrl, placeholderImage: placeholderImage)
        }
    }
}
