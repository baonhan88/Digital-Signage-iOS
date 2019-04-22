//
//  DeviceSettingAutoFitCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 22/10/2018.
//  Copyright © 2018 SLab. All rights reserved.
//

import UIKit

protocol DeviceSettingAutoFitCellDelegate {
    func handleMineSwitchChanged()
}

class DeviceSettingAutoFitCell: UITableViewCell {
    
    @IBOutlet weak var autoFitView: UIView!
    @IBOutlet weak var aspectRatioView: UIView!

    @IBOutlet weak var autoFitLabel: UILabel!
    @IBOutlet weak var aspectRatioLabel: UILabel!
    
    @IBOutlet weak var autoFitSwitch: UISwitch!
    @IBOutlet weak var aspectRatioSwitch: UISwitch!
    
    var device: Device?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        autoFitLabel.text = localizedString(key: "device_setting_auto_fit_title")
        aspectRatioLabel.text = localizedString(key: "device_setting_aspect_ratio_title")
    }
    
    func initView(_ device: Device) {
        self.device = device
        
        aspectRatioSwitch.isOn = false
        autoFitSwitch.isOn = false
        
        if device.autoScale == "ASPECT_RATIO" {
            autoFitSwitch.isOn = true
            aspectRatioSwitch.isOn = true
        } else if device.autoScale == "FULL_STRETCH" {
            autoFitSwitch.isOn = true
            aspectRatioSwitch.isOn = false
        } else {
            autoFitSwitch.isOn = false
            aspectRatioSwitch.isOn = false
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    fileprivate func handleUpdateAutoScale() {
        if aspectRatioSwitch.isOn == false && autoFitSwitch.isOn == false {
            self.device?.autoScale = "NONE"
        } else if autoFitSwitch.isOn == true && aspectRatioSwitch.isOn == true {
            self.device?.autoScale = "ASPECT_RATIO"
        } else if autoFitSwitch.isOn == true && aspectRatioSwitch.isOn == false {
            self.device?.autoScale = "FULL_STRETCH"
        }
    }
    
    @IBAction func autoFitSwitchChanged(_ sender: UISwitch) {
        if sender.isOn == false {
            aspectRatioSwitch.isOn = false
        }
        
        handleUpdateAutoScale()
    }
    
    @IBAction func aspectRatioSwitchChanged(_ sender: UISwitch) {
        handleUpdateAutoScale()
    }

}
