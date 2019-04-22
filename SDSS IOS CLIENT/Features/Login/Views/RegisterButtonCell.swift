//
//  RegisterButtonCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 24/04/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

protocol RegisterButtonCellDelegate {
    func handleRegisterButtonClicked()
}

class RegisterButtonCell: UITableViewCell {
    
    var delegate: RegisterButtonCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func registerButtonClicked(_ sender: UIButton) {
        delegate?.handleRegisterButtonClicked()
    }
}
