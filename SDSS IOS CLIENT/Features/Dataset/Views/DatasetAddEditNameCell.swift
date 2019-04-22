//
//  DatasetAddEditNameCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 12/12/2018.
//  Copyright © 2018 SLab. All rights reserved.
//

import UIKit

protocol DatasetAddEditNameCellDelegate {
    func handleNameChanged(name: String)
}

class DatasetAddEditNameCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    var delegate: DatasetAddEditNameCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        nameLabel.text = localizedString(key: "dataset_add_edit_name")
        nameTextField.placeholder = localizedString(key: "dataset_add_edit_name_place_holder")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initViewWithName(name: String) {
        nameTextField.text = name
    }
    
    @IBAction func nameTextFieldChanged(_ sender: UITextField) {
        delegate?.handleNameChanged(name: sender.text!)
    }
}
