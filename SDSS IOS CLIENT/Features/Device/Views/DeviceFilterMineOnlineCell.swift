//
//  DeviceFilterMineOnlineCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 22/10/2018.
//  Copyright © 2018 SLab. All rights reserved.
//

import UIKit

protocol DeviceFilterMineOnlineCellDelegate {
    func handleMineSwitchChanged()
}

class DeviceFilterMineOnlineCell: UITableViewCell {
    
    @IBOutlet weak var mineView: UIView!
    @IBOutlet weak var onlineView: UIView!

    @IBOutlet weak var mineLabel: UILabel!
    @IBOutlet weak var onlineLabel: UILabel!

    @IBOutlet weak var mineSwitch: UISwitch!
    @IBOutlet weak var onlineSwitch: UISwitch!
    
    var deviceFilter: DeviceFilter?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        mineLabel.text = localizedString(key: "filter_mine_title")
        onlineLabel.text = localizedString(key: "device_filter_online_title")
    }
    
    func initView(_ deviceFilter: DeviceFilter) {
        self.deviceFilter = deviceFilter
        
        mineSwitch.isOn = deviceFilter.isMine
        onlineSwitch.isOn = deviceFilter.isOnline
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func mineSwitchChanged(_ sender: UISwitch) {
        self.deviceFilter?.isMine = sender.isOn
    }
    
    @IBAction func onlineSwitchChanged(_ sender: UISwitch) {
        self.deviceFilter?.isOnline = sender.isOn
    }

}
