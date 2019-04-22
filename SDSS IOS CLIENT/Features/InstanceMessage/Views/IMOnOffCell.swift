//
//  IMOnOffCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 04/05/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

protocol IMOnOffCellDelegate {
    func switcherChanged(isOn: Bool, onOffType: OnOffType)
}

class IMOnOffCell: UITableViewCell {

    @IBOutlet weak var leftLabel: UILabel!
    
    @IBOutlet weak var onOffSwitch: UISwitch!
    
    var currentOnOffType: OnOffType?
    
    var delegate: IMOnOffCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onOffSwitchChanged(_ sender: UISwitch) {
        delegate?.switcherChanged(isOn: sender.isOn, onOffType: currentOnOffType!)
    }
    
}
