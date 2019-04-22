//
//  IMInfoLevelCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 04/05/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

protocol IMInfoLevelCellDelegate {
    func handleInfoLevelChanged(infoLevel: String)
}

class IMInfoLevelCell: UITableViewCell {

    @IBOutlet weak var leftLabel: UILabel!
    
    @IBOutlet weak var progressSlider: UISlider!
    
    var delegate: IMInfoLevelCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        leftLabel.text = "INFO"
        leftLabel.textColor = UIColor.green
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    fileprivate func getInfoLevelStringByInfoLevel(infoLevel: Int) -> String {
        if infoLevel == 1 {
            return "INFO"
        } else if (infoLevel == 4) {
            return "WARN"
        } else if (infoLevel == 7) {
            return "SENSITIVE"
        } else {
            return "EMERGENCY"
        }
    }
    
    func initView(infoLevelString: String) {
        var infoLevel: Int = 1
        if infoLevelString == "INFO" {
            infoLevel = 1
        } else if (infoLevelString == "WARN") {
            infoLevel = 4
        } else if (infoLevelString == "SENSITIVE") {
            infoLevel = 7
        } else {
            infoLevel = 10
        }
        
        updateInfoLevel(infoLevel: infoLevel)
    }
    
    func updateInfoLevel(infoLevel: Int) {
        var newInfoLevel: Int = 1
        
        if infoLevel <= 2 {
            newInfoLevel = 1
            leftLabel.text = "INFO"
            leftLabel.textColor = UIColor.green
        } else if (infoLevel > 2 && infoLevel <= 5) {
            newInfoLevel = 4
            leftLabel.text = "WARN"
            leftLabel.textColor = UIColor.yellow
        } else if (infoLevel > 5 && infoLevel <= 8) {
            newInfoLevel = 7
            leftLabel.text = "SENSITIVE"
            leftLabel.textColor = UIColor.orange
        } else {
            newInfoLevel = 10
            leftLabel.text = "EMERGENCY"
            leftLabel.textColor = UIColor.red
        }
        
        progressSlider.value = Float(newInfoLevel)
        
        delegate?.handleInfoLevelChanged(infoLevel: getInfoLevelStringByInfoLevel(infoLevel: newInfoLevel))
    }
    
    @IBAction func progressSliderChanged(_ sender: UISlider) {
        updateInfoLevel(infoLevel: Int(sender.value))
    }
    
    @IBAction func progressSliderEditingDidEnd(_ sender: UISlider) {
        dLog(message: "aaaaaaaa")
    }
}
