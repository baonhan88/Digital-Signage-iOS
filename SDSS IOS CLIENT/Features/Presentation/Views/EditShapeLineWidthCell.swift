//
//  EditShapeLineWidthCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 04/05/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

protocol EditShapeLineWidthCellDelegate {
    func lineWidthChanged(width: Int)
}

class EditShapeLineWidthCell: UITableViewCell {

    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    @IBOutlet weak var progressSlider: UISlider!
    
    var currentLineWidth: Int = 1
    
    var delegate: EditShapeLineWidthCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        leftLabel.text = localizedString(key: "presentation_editor_update_shape_line_width_title")
    }
    
    func initView(lineWidth: Int) {
        currentLineWidth = lineWidth
        
        valueLabel.text = String(currentLineWidth)
        progressSlider.value = Float(currentLineWidth)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func progressSliderChanged(_ sender: UISlider) {
        valueLabel.text = String(Int(sender.value))
        delegate?.lineWidthChanged(width: Int(sender.value))
    }
}
