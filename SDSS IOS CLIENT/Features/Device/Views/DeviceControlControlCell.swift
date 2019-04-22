//
//  DeviceControlControlCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 17/01/2019.
//  Copyright © 2019 SLab. All rights reserved.
//

import UIKit

protocol DeviceControlControlCellDelegate {
    func handleTogglePlayStopAction(device: Device, isPlay: Bool)
}

class DeviceControlControlCell: UITableViewCell {

    @IBOutlet weak var controlLabel: UILabel!

    @IBOutlet weak var playStopButton: UIButton!
    
    var device: Device = Device()
    
    var delegate: DeviceControlControlCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        controlLabel.text = localizedString(key: "device_control_control")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initView(device: Device) {
        self.device = device
        
        if device.playStatus == "PLAY" {
            playStopButton.setImage(UIImage.init(named: "icon_stop"), for: UIControlState.normal)
        } else {
            playStopButton.setImage(UIImage.init(named: "icon_play"), for: UIControlState.normal)
        }
    }
    
    @IBAction func playStopButtonClicked(_ sender: UIButton) {
        var isPlay = true
        if device.playStatus == "PLAY" {
            isPlay = false
        }
        
        delegate?.handleTogglePlayStopAction(device: device, isPlay: isPlay)
    }

}
