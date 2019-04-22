//
//  DeviceControlDimCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 17/01/2019.
//  Copyright © 2019 SLab. All rights reserved.
//

import UIKit

protocol DeviceControlDimCellDelegate {
    func handleDimAction(device: Device, isDim: Bool)
    func handleResetAction(device: Device)
}

class DeviceControlDimCell: UITableViewCell {

    @IBOutlet weak var dimLabel: UILabel!
    @IBOutlet weak var resetLabel: UILabel!
    
    @IBOutlet weak var dimSwitch: UISwitch!
    
    var delegate: DeviceControlDimCellDelegate?
    
    var device: Device = Device()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        dimLabel.text = localizedString(key: "device_control_dim")
        resetLabel.text = localizedString(key: "device_control_reset")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initView(device: Device) {
        self.device = device
        
        dimSwitch.isOn = device.isDim
    }
    
    @IBAction func dimSwitchChanged(_ sender: UISwitch) {
        delegate?.handleDimAction(device: device, isDim: sender.isOn)
    }
    
    @IBAction func resetButtonClicked(_ sender: UIButton) {
        delegate?.handleResetAction(device: device)
    }
}
