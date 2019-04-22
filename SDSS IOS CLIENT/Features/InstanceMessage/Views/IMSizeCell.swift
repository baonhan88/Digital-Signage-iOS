//
//  IMSizeCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 04/05/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

protocol IMSizeCellDelegate {
    func fontSizeChanged(size: Int)
}

class IMSizeCell: UITableViewCell {

    @IBOutlet weak var leftLabel: UILabel!
    
    @IBOutlet weak var percentLabel: UILabel!
    
    @IBOutlet weak var progressSlider: UISlider!
    
    var currentSize: Int = 9
    
    var delegate: IMSizeCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        leftLabel.text = localizedString(key: "im_cell_size")
        
        progressSlider.value = 9
        updateLabel(value: 9)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateLabel(value: Int) {
        currentSize = value
        
        delegate?.fontSizeChanged(size: currentSize)
        
        percentLabel.text = "\(currentSize) px"
    }
    
    @IBAction func progressSliderChanged(_ sender: UISlider) {
        updateLabel(value: Int(sender.value))
    }
}
