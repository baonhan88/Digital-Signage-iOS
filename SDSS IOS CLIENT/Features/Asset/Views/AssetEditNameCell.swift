//
//  AssetEditNameCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 22/10/2018.
//  Copyright © 2018 SLab. All rights reserved.
//

import UIKit

protocol AssetEditNameCellDelegate {
    func handleAssetNameChanged(assetName: String)
}

class AssetEditNameCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var editNameTextField: UITextField!
    
    var delegate: AssetEditNameCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    func initView(_ assetName: String) {
        self.editNameTextField.text = assetName
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func editNameTextFieldChanged(_ sender: UITextField) {
        delegate?.handleAssetNameChanged(assetName: sender.text!)
    }
}
