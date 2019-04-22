//
//  EditTextOnOffCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 04/05/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

protocol EditTextOnOffCellDelegate {
    func handleOnOffChanged(currentOnOffType: FontStyle, isOn: Bool)
}

class EditTextOnOffCell: UITableViewCell {

    @IBOutlet weak var leftLabel: UILabel!
    
    @IBOutlet weak var onOffSwitch: UISwitch!
    
    var currentOnOffType: FontStyle?
    
    var delegate: EditTextOnOffCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onOffSwitchChanged(_ sender: UISwitch) {
        delegate?.handleOnOffChanged(currentOnOffType: currentOnOffType!, isOn: sender.isOn)
    }
    
}
