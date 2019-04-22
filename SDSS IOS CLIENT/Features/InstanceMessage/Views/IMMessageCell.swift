//
//  IMMessageCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 04/05/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

protocol IMMessageCellDelegate {
    func handleTTSSwitchChanged(isOn: Bool)
    func handleTTSRepeatSwitchChanged(isOn: Bool)
    func handleMessageChanged(message: String)
    func handleTTSMessageChanged(ttsMessage: String)
}

class IMMessageCell: UITableViewCell {
    
    @IBOutlet weak var enterIMTextField: UITextField!
    @IBOutlet weak var enterTTSTextField: UITextField!
    
    @IBOutlet weak var enableTTSLabel: UILabel!
    @IBOutlet weak var ttsRepeatLabel: UILabel!
    
    @IBOutlet weak var enableTTSSwitch: UISwitch!
    @IBOutlet weak var ttsRepeatSwitch: UISwitch!
    
    var delegate: IMMessageCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        enterIMTextField.placeholder = localizedString(key: "im_cell_enter_im_place_holder")
        enterTTSTextField.placeholder = localizedString(key: "im_cell_enter_tts_place_holder")
        
        enableTTSLabel.text = localizedString(key: "img_cell_enable_tts")
        
        // default disable enter TTS
        enterTTSTextField.isEnabled = false
    }
    
    func initView(displayEvent: DisplayEvent) {
        enterIMTextField.text = displayEvent.contentData.message
        enterTTSTextField.text = displayEvent.contentData.ttsMsg
        
        enableTTSSwitch.isOn = displayEvent.contentData.isTTS
        ttsRepeatSwitch.isOn = displayEvent.contentData.TTSRepeat
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func enableTTSSwitchChanged(_ sender: UISwitch) {
        enterTTSTextField.isEnabled = sender.isOn ? true : false
        
        delegate?.handleTTSSwitchChanged(isOn: sender.isOn)
    }
    
    @IBAction func ttsRepeatSwitchChanged(_ sender: UISwitch) {
        delegate?.handleTTSRepeatSwitchChanged(isOn: sender.isOn)
    }
    
    @IBAction func messageTextFieldChanged(_ sender: UITextField) {
        delegate?.handleMessageChanged(message: sender.text!)
    }
    
    @IBAction func ttsMessageChanged(_ sender: UITextField) {
        delegate?.handleTTSMessageChanged(ttsMessage: sender.text!)
    }
}
