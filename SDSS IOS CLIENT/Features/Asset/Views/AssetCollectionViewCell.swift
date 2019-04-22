//
//  AssetCollectionViewCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 12/05/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

class AssetCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var personImageView: UIImageView!
    @IBOutlet weak var bgPersonView: UIView!
    
    @IBOutlet weak var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func initViewWith(assetDetail: AssetDetail) {
        label.text = assetDetail.name
        
        let placeholderImage = UIImage(named: "icon_template_placeholder")!
        
        if let thumbnailUrl = URL.init(string: NetworkManager.shared.baseURL + String.init(format: Network.assetThumbnailUrl, assetDetail.id,  Utility.getToken())) {
            Utility.clearImageFromCache(withURL: thumbnailUrl)
            imageView.af_setImage(withURL: thumbnailUrl, placeholderImage: placeholderImage)
        }
        
        if assetDetail.owner.displayName == Utility.getUsername() {
            personImageView.isHidden = false
        } else {
            personImageView.isHidden = true
        }
    }

}
