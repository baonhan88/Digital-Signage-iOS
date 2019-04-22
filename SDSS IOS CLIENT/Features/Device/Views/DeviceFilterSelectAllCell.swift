//
//  DeviceFilterSelectAllCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 22/10/2018.
//  Copyright © 2018 SLab. All rights reserved.
//

import UIKit

protocol DeviceFilterSelectAllCellDelegate {
    func handleMineSwitchChanged()
}

class DeviceFilterSelectAllCell: UITableViewCell {
    
    @IBOutlet weak var selectAllLabel: UILabel!

    @IBOutlet weak var selectAllSwitch: UISwitch!
    
    var deviceFilter: DeviceFilter?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectAllLabel.text = localizedString(key: "device_filter_select_all_title")
    }
    
    func initView(_ deviceFilter: DeviceFilter) {
        self.deviceFilter = deviceFilter
        
        selectAllSwitch.isOn = deviceFilter.isSelectAll
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func selectAllSwitchChanged(_ sender: UISwitch) {
        self.deviceFilter?.isSelectAll = sender.isOn
    }
}
