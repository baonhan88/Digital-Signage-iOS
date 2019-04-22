//
//  EditTextMessageCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 04/05/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

protocol EditTextMessageCellDelegate {
    func handleUpdateText(newText: String)
}

class EditTextMessageCell: UITableViewCell {
    
    @IBOutlet weak var enterIMTextField: UITextField!
    
    var delegate: EditTextMessageCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code  
        
        enterIMTextField.placeholder = localizedString(key: "presentation_editor_update_text_message_placeholder")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func textFieldDidChange(_ sender: UITextField) {
        delegate?.handleUpdateText(newText: sender.text!)
    }
}
