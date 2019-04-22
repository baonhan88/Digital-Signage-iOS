//
//  EditVideoViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 02/06/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

protocol EditVideoViewControllerDelegate {
    func handleUpdateLocalVideo(newLocalVideoURL: URL, newLocalVideoThumbnail: UIImage, region: Region)
    func handleUpdateYoutube(newYoutubeUrl: String, newYoutubeThumbnail: UIImage, region: Region)
    func handleUpdateVideoFromCloud(assetDetail: AssetDetail, region: Region)
}

class EditVideoViewController: UIViewController {

    @IBOutlet weak var videoThumbnailImageView: UIImageView!
    @IBOutlet weak var videoIconImageView: UIImageView!
    
    // input value
    var region: Region?
    var image: UIImage?
    
    var delegate: EditVideoViewControllerDelegate?
    
    fileprivate var newYoutubeURL: String = ""
    fileprivate var videoTypeName: String = ""
    fileprivate var newLocalVideoURL: URL?
    
    var isFromCloud = false
    var assetDetail: AssetDetail = AssetDetail()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initView()
        
        initNavigationBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func initNavigationBar() {
        self.title = localizedString(key: "presentation_editor_update_video_title")
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(handleDoneButtonClicked(barButton:)))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    fileprivate func initView() {
        guard let video = Utility.getFirstVideoFromRegion(region: region!) else {
            return
        }
        
        switch video.sourceType {
            
        case VideoAssetType.localVideo.name():
            // create video icon add overlay on center of thumbnail video with size 70x70
            videoIconImageView.image = UIImage.init(named: "icon_video")
            break
            
        case VideoAssetType.youtubeVideo.name():
            // create youtube icon add overlay on center of thumbnail video with size 70x70
            videoIconImageView.image = UIImage.init(named: "icon_youtube")
            break
            
        default:
            dLog(message: "video asset type = \(video.sourceType) hadn't handled yet")
            return
        }
        
        videoThumbnailImageView.image = image
    }
    
    fileprivate func processChooseYoutube() {
        videoTypeName = VideoAssetType.youtubeVideo.name()
        
        // Create the alert controller.
        let alert = UIAlertController(title: "",
                                      message: localizedString(key: "presentation_editor_update_video_youtube_message"),
                                      preferredStyle: .alert)
        
        // Add the text field
        alert.addTextField { (textField) in
            textField.placeholder = localizedString(key: "presentation_editor_update_video_youtube_placeholder")
        }
        
        // add cancel action
        alert.addAction(UIAlertAction(title: localizedString(key: "common_cancel"), style: .cancel, handler: { (_) in
            // just dismiss alert
        }))
        
        // add OK action
        alert.addAction(UIAlertAction(title: localizedString(key: "common_ok"), style: .default, handler: { [weak alert] (_) in
            weak var weakSelf = self
            
            // process change youtube url
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            weakSelf?.newYoutubeURL = (textField?.text)!
            
            // update new youtube thumbnail
            if let image = Utility.getYoutubeThumbnail(youtubeUrl: (textField?.text)!) {
                weakSelf?.videoThumbnailImageView.image = image
                weakSelf?.videoIconImageView.image = UIImage.init(named: "icon_youtube")
            } else {
                Utility.showAlertWithErrorMessage(message: localizedString(key: "presentation_editor_get_youtube_token_fail"), controller: self)
            }
        }))
        
        // Present the alert.
        self.present(alert, animated: true, completion: nil)
    }

    fileprivate func processChooseLocalVideo() {
        videoTypeName = VideoAssetType.localVideo.name()
        
        AppUtility.lockOrientation(.all)
        
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.mediaTypes = ["public.movie"]
        self.present(picker, animated: true)
    }
}

// MARK: - Handle Events

extension EditVideoViewController {
    
    func handleDoneButtonClicked(barButton: UIBarButtonItem) {
        if isFromCloud {
            delegate?.handleUpdateVideoFromCloud(assetDetail: self.assetDetail, region: self.region!)
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        if videoTypeName != "" {
            switch videoTypeName {
                
            case VideoAssetType.localVideo.name():
                if newLocalVideoURL != nil {
                    self.delegate?.handleUpdateLocalVideo(newLocalVideoURL: newLocalVideoURL!, newLocalVideoThumbnail: videoThumbnailImageView.image!, region: region!)
                    self.navigationController?.popViewController(animated: true)
                } else {
                    dLog(message: "newLocalVideoURL is empty!!!")
                }
                break
                
            case VideoAssetType.youtubeVideo.name():
                if newYoutubeURL != "" {
                    self.delegate?.handleUpdateYoutube(newYoutubeUrl: newYoutubeURL, newYoutubeThumbnail: videoThumbnailImageView.image!, region: region!)
                    self.navigationController?.popViewController(animated: true)
                } else {
                    dLog(message: "newYoutubeUrl is empty!!!")
                }
                break
                
            default:
                break
            }
        } else {
            dLog(message: "videoTypeName is empty!!!")
        }
        
    }
    
    @IBAction func buttonEditVideoClicked(_ sender: UIButton) {
        // show actionsheet to choose video type
        let actionSheetController = UIAlertController(title: localizedString(key: "presentation_editor_update_video_actionsheet_title"),
                                                      message: localizedString(key: "presentation_editor_update_video_actionsheet_message"),
                                                      preferredStyle: .actionSheet)
        
        // Create and add the Cancel action
        let cancelAction = UIAlertAction(title: localizedString(key: "common_cancel"), style: .cancel) { action -> Void in
            // Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        
        // Create and add choose local video option action
        let chooseLocalVideoAction = UIAlertAction(title: localizedString(key: "presentation_editor_update_video_local_video_option"), style: .default) { action -> Void in
            self.processChooseLocalVideo()
        }
        actionSheetController.addAction(chooseLocalVideoAction)
        
        // Create and add choose youtube option action
        let chooseYoutubeAction = UIAlertAction(title: localizedString(key: "presentation_editor_update_video_youtube_video_option"), style: .default) { action -> Void in
            self.processChooseYoutube()
        }
        actionSheetController.addAction(chooseYoutubeAction)
        
        // Create and add choose video from Cloud option action
        let chooseVideoFromCloudAction = UIAlertAction(title: localizedString(key: "presentation_editor_update_video_youtube_asset_list_option"), style: .default) {
            action -> Void in
            
            ControllerManager.goToAssetListScreen(controller: self, assetType: .video)
        }
        actionSheetController.addAction(chooseVideoFromCloudAction)
        
        // Present the actionsheet
        self.present(actionSheetController, animated: true, completion: nil)
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate

extension EditVideoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
        AppUtility.lockOrientation(.landscapeLeft, andRotateTo: .landscapeLeft)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var videoURL: URL?
        
        if let possibleVideoURL = info["UIImagePickerControllerReferenceURL"] as? URL {
            videoURL = possibleVideoURL
            if let image = DesignFileHelper.thumbnailForLocalVideoAtURL(url: videoURL!) {
                // change with new video thumbnail
                videoThumbnailImageView.image = image
                videoIconImageView.image = UIImage.init(named: "icon_video")

                // save new video url
                newLocalVideoURL = videoURL
            } else {
                dLog(message: "can't load video thumbnail with url: " + (videoURL?.path)!)
                return
            }
        } else {
            return
        }
        
        dismiss(animated: true)
        AppUtility.lockOrientation(.landscapeLeft, andRotateTo: .landscapeLeft)
    }
}

// MARK: - AssetSelectionCollectionViewControllerDelegate

extension EditVideoViewController: AssetSelectionCollectionViewControllerDelegate {
    
    func handleUpdateAssetFromCloud(assetDetail: AssetDetail) {
        isFromCloud = true
        self.assetDetail = assetDetail
        
        let placeholderImage = UIImage(named: "icon_template_placeholder")!
        
        if let thumbnailUrl = URL.init(string: NetworkManager.shared.baseURL + String.init(format: Network.assetThumbnailUrl, self.assetDetail.id,  Utility.getToken())) {
            Utility.clearImageFromCache(withURL: thumbnailUrl)
            self.videoThumbnailImageView.af_setImage(withURL: thumbnailUrl, placeholderImage: placeholderImage)
            self.videoIconImageView.image = UIImage.init(named: "icon_video")
        }
    }
}
