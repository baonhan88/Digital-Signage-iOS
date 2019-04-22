//
//  TemplatePresentationCollectionViewCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 12/05/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

class TemplateCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var personImageView: UIImageView!
    
    @IBOutlet weak var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func initView(with presentation: Presentation) {
        self.label.text = presentation.name
        
        let url = URL(string: Network.baseURL + String.init(format: Network.presentationThumbnailUrl, presentation.id, Utility.getToken()))!
        let placeholderImage = UIImage(named: "icon_template_placeholder")!
        // remove cache
        Utility.clearImageFromCache(withURL: url)
        self.imageView.af_setImage(withURL: url, placeholderImage: placeholderImage)
        
        if presentation.owner.displayName == Utility.getUsername() {
            personImageView.isHidden = false
        } else {
            personImageView.isHidden = true
        }
    }

}
