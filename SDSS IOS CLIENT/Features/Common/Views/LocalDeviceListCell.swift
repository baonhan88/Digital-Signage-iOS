//
//  LocalDeviceListCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 26/04/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

class LocalDeviceListCell: UITableViewCell {
    
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var activatedLabel: UILabel!
    @IBOutlet weak var localStatusLabel: UILabel!
    
    @IBOutlet weak var checkmarkImageView: UIImageView!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.bgView.layer.borderColor = UIColor.lightGray.cgColor
        self.bgView.layer.borderWidth = 1
        self.bgView.layer.cornerRadius = 8
        
        checkmarkImageView.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initViewWithDeviceData(device: Device) {
        nameLabel.text = device.name
        activatedLabel.text = device.operationSystem
        
        if device.isLocalOnline == true {
            localStatusLabel.text = localizedString(key: "device_online")
            localStatusLabel.textColor = UIColor.green
        } else {
            localStatusLabel.text = localizedString(key: "device_offline")
            localStatusLabel.textColor = UIColor.red
        }
        
        checkmarkImageView.isHidden = !device.isChoose
    }
}
