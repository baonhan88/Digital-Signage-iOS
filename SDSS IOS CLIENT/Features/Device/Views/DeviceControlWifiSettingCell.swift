//
//  DeviceControlWifiSettingCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 17/01/2019.
//  Copyright © 2019 SLab. All rights reserved.
//

import UIKit

protocol DeviceControlWifiSettingCellDelegate {
    func handleWifiSettingAction(device: Device)
}

class DeviceControlWifiSettingCell: UITableViewCell {

    @IBOutlet weak var wifiSettingLabel: UILabel!

    var device: Device = Device()
    
    var delegate: DeviceControlWifiSettingCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        wifiSettingLabel.text = localizedString(key: "device_control_wifi_setting")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initView(device: Device) {
        self.device = device
    }

    @IBAction func wifiSettingButtonClicked(_ sender: UIButton) {
        delegate?.handleWifiSettingAction(device: device)
    }
}
