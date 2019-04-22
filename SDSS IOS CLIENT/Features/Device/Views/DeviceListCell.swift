//
//  DeviceListCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 26/04/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

protocol DeviceListCellDelegate {
    func handleEditButton(device: Device)
    func handlePlayButton(device: Device)
    func handleDeleteButton(device: Device)
    func handleControlButton(device: Device)
    func handleContentListButton(device: Device)
}

class DeviceListCell: UITableViewCell {
    
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var osLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var cloudStatusView: UIView!
    @IBOutlet weak var localStatusView: UIView!
    @IBOutlet weak var seperateView: UIView!
    
    @IBOutlet weak var cloudTitleLabel: UILabel!
    @IBOutlet weak var localTitleLabel: UILabel!
    
    @IBOutlet weak var contentListButton: UIButton!
    @IBOutlet weak var controlButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    var delegate: DeviceListCellDelegate?
    
    var currentDevice: Device?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        cloudTitleLabel.text = localizedString(key: "device_cloud_title")
        localTitleLabel.text = localizedString(key: "device_local_title")
        
        self.bgView.layer.borderColor = UIColor.lightGray.cgColor
        self.bgView.layer.borderWidth = 1
        self.bgView.layer.cornerRadius = 8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initViewWithDeviceData(device: Device) {
        currentDevice = device
        
        nameLabel.text = device.name
        osLabel.text = device.os
        
        if device.liveStatus == DeviceStatus.offline.statusString() {
            cloudStatusView.backgroundColor = UIColor.red
            
            contentListButton.isHidden = true
            controlButton.isHidden = true
            playButton.isHidden = true
            seperateView.isHidden = true
        } else if device.liveStatus == DeviceStatus.online.statusString() {
            cloudStatusView.backgroundColor = UIColor.green
            
            contentListButton.isHidden = false
            controlButton.isHidden = false
            playButton.isHidden = false
            seperateView.isHidden = false
        }
        
        if device.isLocalOnline == true {
            localStatusView.backgroundColor = UIColor.green
        } else {
            localStatusView.backgroundColor = UIColor.red
        }
    }
    
    // MARK: - Handling Events
    
    @IBAction func editButtonClicked(_ sender: UIButton) {
        delegate?.handleEditButton(device: currentDevice!)
    }
    
    @IBAction func playButtonClicked(_ sender: UIButton) {
        delegate?.handlePlayButton(device: currentDevice!)
    }
    
    @IBAction func deleteButtonClicked(_ sender: UIButton) {
        delegate?.handleDeleteButton(device: currentDevice!)
    }
    
    @IBAction func controlButtonClicked(_ sender: UIButton) {
        delegate?.handleControlButton(device: currentDevice!)
    }
    
    @IBAction func contentListButtonClicked(_ sender: UIButton) {
        delegate?.handleContentListButton(device: currentDevice!)
    }
}
