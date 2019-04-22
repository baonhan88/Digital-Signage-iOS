//
//  IMDurationCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 04/05/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

protocol IMDurationCellDelegate {
    func handleDurationChanged(duration: Int)
}

class IMDurationCell: UITableViewCell {

    @IBOutlet weak var leftLabel: UILabel!
    
    @IBOutlet weak var percentLabel: UILabel!
    
    @IBOutlet weak var progressSlider: UISlider!
    
    var currentDuration: Int = 10
    
    var delegate: IMDurationCellDelegate?
    
    let kStepOverDuration = 5 // seconds
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        leftLabel.text = localizedString(key: "im_cell_duration")
        
        progressSlider.value = Float(currentDuration/kStepOverDuration)
        updateLabel(progressValue: progressSlider.value)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initView(duration: Int) {
        progressSlider.value = Float(duration)
    }
    
    func updateLabel(progressValue: Float) {
        currentDuration = Int(progressValue)*kStepOverDuration
        
        delegate?.handleDurationChanged(duration: Int(currentDuration))
        
        percentLabel.text = String.init(format: localizedString(key: "im_cell_show_duration"), currentDuration)
    }
    
    @IBAction func progressSliderChanged(_ sender: UISlider) {
        updateLabel(progressValue: sender.value)
    }
}
