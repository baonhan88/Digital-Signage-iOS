//
//  IMEventNameCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 14/01/2019.
//  Copyright © 2019 SLab. All rights reserved.
//

import UIKit

protocol IMEventNameCellDelegate {
    func handleNameTextFieldChanged(name: String)
}

class IMEventNameCell: UITableViewCell {
    
    @IBOutlet weak var nameTextField: UITextField!
    
    var delegate: IMEventNameCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initView(name: String) {
        nameTextField.text = name
    }
    
    @IBAction func nameTextFieldChanged(_ sender: UITextField) {
        delegate?.handleNameTextFieldChanged(name: sender.text!)
    }
    
}
