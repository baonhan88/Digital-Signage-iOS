//
//  EditTextSizeCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 04/05/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

protocol EditTextSizeCellDelegate {
    func fontSizeChanged(size: Int)
}

class EditTextSizeCell: UITableViewCell {

    @IBOutlet weak var leftLabel: UILabel!
    
    @IBOutlet weak var percentLabel: UILabel!
    
    @IBOutlet weak var progressSlider: UISlider!
    
    var delegate: EditTextSizeCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        leftLabel.text = localizedString(key: "im_cell_size")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initView(fontSize: Float) {
        progressSlider.value = fontSize
        percentLabel.text = "\(Int(fontSize)) px"
    }
    
    func updateLabel(value: Int) {
        delegate?.fontSizeChanged(size: value)
        
        percentLabel.text = "\(value) px"
    }
    
    @IBAction func progressSliderChanged(_ sender: UISlider) {
        updateLabel(value: Int(sender.value))
    }
}
