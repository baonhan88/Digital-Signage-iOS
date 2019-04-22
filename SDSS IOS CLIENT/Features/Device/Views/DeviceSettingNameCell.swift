//
//  DeviceSettingNameCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 30/01/2019.
//  Copyright © 2019 SLab. All rights reserved.
//

import UIKit

class DeviceSettingNameCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    var device: Device?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        nameLabel.text = localizedString(key: "device_setting_name_title")
        nameTextField.placeholder = localizedString(key: "device_setting_name_text_field_placeholder")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initView(_ device: Device) {
        self.device = device
        
        self.nameTextField.text = device.name
    }
    
    @IBAction func nameTextFieldChanged(_ sender: UITextField) {
        self.device?.name = sender.text!
    }
}
