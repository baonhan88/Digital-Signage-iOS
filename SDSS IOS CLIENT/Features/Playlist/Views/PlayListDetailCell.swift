//
//  PlayListDetailCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 21/06/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

class PlayListDetailCell: UITableViewCell {

    @IBOutlet weak var contentVIew: UIView!
    
    @IBOutlet weak var presentationImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    var playListPresentation: PlayListPresentation?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.contentVIew.layer.borderColor = UIColor.lightGray.cgColor
        self.contentVIew.layer.borderWidth = 1
        self.contentVIew.layer.cornerRadius = 8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initViewWithPlayListPresentation(_ playListPresentation: PlayListPresentation) {
        self.playListPresentation = playListPresentation
        
        nameLabel.text = playListPresentation.name
        durationLabel.text = Utility.generateDaysHoursMinutesSecondsStringWithSeconds(seconds: playListPresentation.duration)
        
        // first get thumbnail from local -> if not exist -> get thumbnail from cloud
        let placeholderImage = UIImage(named: "icon_template_placeholder")!
        
        let presentationLocalThumbnailURL = Utility.getUrlFromDocumentWithAppend(url: Dir.savePresentation + playListPresentation.presentation + "/" + playListPresentation.presentation + Dir.presentationThumbnailExtension)
        if FileManager.default.fileExists(atPath: presentationLocalThumbnailURL.path) {
            if let thumbnailImage = UIImage.init(contentsOfFile: presentationLocalThumbnailURL.path) {
                presentationImageView.image = thumbnailImage
            } else {
                presentationImageView.image = placeholderImage
            }
        } else { // get thumbnail from cloud
            var thumbnailURL = ""
            
            if playListPresentation.type == "PRESENTATION" {
                thumbnailURL = Network.presentationThumbnailUrl
            } else {
                thumbnailURL = Network.assetThumbnailUrl
            }
            
            if let presentationThumbnailURL = URL.init(string: Network.baseURL + String(format:thumbnailURL, playListPresentation.id, Utility.getToken())) {
                // remove cache
                Utility.clearImageFromCache(withURL: presentationThumbnailURL)
                presentationImageView.af_setImage(withURL: presentationThumbnailURL, placeholderImage: placeholderImage)
            } else {
                presentationImageView.image = placeholderImage
            }
        }
    }
}
