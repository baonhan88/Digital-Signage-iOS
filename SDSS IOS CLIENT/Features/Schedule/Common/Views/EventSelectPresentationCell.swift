//
//  RealTimeEventSelectPresentationCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 04/07/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol EventSelectPresentationCellDelegate {
    func handleLoadPresentationError(message: String)
}

class EventSelectPresentationCell: UITableViewCell {

    @IBOutlet weak var presentationImageView: UIImageView!
    
    @IBOutlet weak var presentationNameLabel: UILabel!
    
    var delegate: EventSelectPresentationCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initViewWithPresentationId(_ presentationId: String) {
        if presentationId != "" {
            // init presentation thumbnail
            // first get thumbnail from local, if not exist -> get thumbnail from cloud
            let placeholderImage = UIImage(named: "icon_template_placeholder")!
            let presentationLocalThumbnailURL = Utility.getUrlFromDocumentWithAppend(url: Dir.savePresentation + presentationId + "/" + presentationId + Dir.presentationThumbnailExtension)
            if FileManager.default.fileExists(atPath: presentationLocalThumbnailURL.path) {
                if let thumbnailImage = UIImage.init(contentsOfFile: presentationLocalThumbnailURL.path) {
                    presentationImageView.image = thumbnailImage
                } else {
                    presentationImageView.image = placeholderImage
                }
                
                // init presentation name
                guard let presentationInfo = DesignFileHelper.getPresentationByPresentationId(presentationId) else {
                    dLog(message: "can't get presentation with id = \(presentationId)")
                    return
                }
                presentationNameLabel.text = presentationInfo.name
            } else { // get from cloud
                if let presentationThumbnailURL = URL.init(string: Network.baseURL + String(format:Network.presentationThumbnailUrl, presentationId, Utility.getToken())) {
                    // remove cache
                    Utility.clearImageFromCache(withURL: presentationThumbnailURL)
                    presentationImageView.af_setImage(withURL: presentationThumbnailURL, placeholderImage: placeholderImage)
                } else {
                    presentationImageView.image = placeholderImage
                }
                
                // get presentation info from cloud
                SVProgressHUD.show()
                
                NetworkManager.shared.getPresentation(presentationId: presentationId, token: Utility.getToken(), completion: {
                    [weak self] (success, presentation, message) in
                    
                    SVProgressHUD.dismiss()
                    
                    if success && presentation != nil {
                        self?.presentationNameLabel.text = presentation?.name
                    } else {
                        self?.delegate?.handleLoadPresentationError(message: message)
                    }
                })
            }
        }
    }
}
