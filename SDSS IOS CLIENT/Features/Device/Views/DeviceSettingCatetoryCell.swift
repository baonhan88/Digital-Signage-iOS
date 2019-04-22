//
//  DeviceSettingCatetoryCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 04/05/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

class DeviceSettingCatetoryCell: UITableViewCell {
    
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.leftLabel.text = localizedString(key: "device_setting_category_title")
        self.rightLabel.text = localizedString(key: "device_setting_choose_category")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initView(_ device: Device) {
        if device.group.name == "" {
            self.rightLabel.text = localizedString(key: "device_setting_choose_category")
        } else {
            self.rightLabel.text = device.group.name
        }
    }
    
}
