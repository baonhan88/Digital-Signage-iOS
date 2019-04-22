//
//  IMAlignmentCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 04/05/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

class IMAlignmentCell: UITableViewCell {

    @IBOutlet weak var alignmentLabel: UILabel!
    
    @IBOutlet weak var alignmentImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        alignmentLabel.text = localizedString(key: "im_aligment_cell_title")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateAlignmentImageWithCurrentTag(tag: Int) {
        switch tag {
        case Alignment.topLeft.tag():
            alignmentImageView.image = UIImage.init(named: Alignment.topLeft.selectedImageName())
        case Alignment.topCenter.tag():
            alignmentImageView.image = UIImage.init(named: Alignment.topCenter.selectedImageName())
        case Alignment.topRight.tag():
            alignmentImageView.image = UIImage.init(named: Alignment.topRight.selectedImageName())
        case Alignment.middleLeft.tag():
            alignmentImageView.image = UIImage.init(named: Alignment.middleLeft.selectedImageName())
        case Alignment.middleCenter.tag():
            alignmentImageView.image = UIImage.init(named: Alignment.middleCenter.selectedImageName())
        case Alignment.middleRight.tag():
            alignmentImageView.image = UIImage.init(named: Alignment.middleRight.selectedImageName())
        case Alignment.bottomLeft.tag():
            alignmentImageView.image = UIImage.init(named: Alignment.bottomLeft.selectedImageName())
        case Alignment.bottomCenter.tag():
            alignmentImageView.image = UIImage.init(named: Alignment.bottomCenter.selectedImageName())
        case Alignment.bottomRight.tag():
            alignmentImageView.image = UIImage.init(named: Alignment.bottomRight.selectedImageName())
        default:
            alignmentImageView.image = UIImage.init(named: Alignment.topLeft.selectedImageName())
        }
    }
    
    func initView(tag: Int) {
        alignmentLabel.text = localizedString(key: "im_cell_alignment")
        updateAlignmentImageWithCurrentTag(tag: tag)
    }
    
}
