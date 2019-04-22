//
//  PresentationEditorRightMenuCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 30/05/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

class PresentationEditorRightMenuCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var label: UILabel!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initViewWithRegion(region: Region) {
        switch region.type {
            
        case MediaType.image.name():
            iconImageView.image = UIImage.init(named: MediaType.image.imageName())
            label.text = localizedString(key: "presentation_editor_right_menu_image")
            
        case MediaType.video.name():
            iconImageView.image = UIImage.init(named: MediaType.video.imageName())
            label.text = localizedString(key: "presentation_editor_right_menu_video")
            
        case MediaType.webpage.name():
            iconImageView.image = UIImage.init(named: MediaType.webpage.imageName())
            
            guard let objects = region.objects else {
                return
            }
            
            if objects.count > 0 {
                let webpage = objects[0] as! Webpage
                label.text = webpage.sourcePath
            }
            
        case MediaType.text.name():
            iconImageView.image = UIImage.init(named: MediaType.text.imageName())
            
            guard let objects = region.objects else {
                return
            }
            
            if objects.count > 0 {
                let text = objects[0] as! Text
                label.text = text.text
            }
            
        case MediaType.frame.name():
            iconImageView.image = UIImage.init(named: MediaType.frame.imageName())
            label.text = localizedString(key: "presentation_editor_right_menu_shape")
            
        case MediaType.widget.name():
            iconImageView.image = UIImage.init(named: MediaType.widget.imageName())
            label.text = localizedString(key: "presentation_editor_right_menu_widget")
            
        default:
            dLog(message: "can't load region with type \(region.type)")
        }
    }
    
}
