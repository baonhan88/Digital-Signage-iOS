//
//  SelectColorCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 04/07/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

class SelectColorCell: UITableViewCell {

    @IBOutlet weak var leftLabel: UILabel!
    
    @IBOutlet weak var colorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        leftLabel.text = localizedString(key: "im_cell_color")
        
        colorView.layer.borderWidth = 1
        colorView.layer.borderColor = UIColor.lightGray.cgColor
        colorView.layer.cornerRadius = colorView.frame.size.width/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initViewWithColor(hexString: String) {
        guard let currentColor = UIColor.init(hexString: hexString) else {
            dLog(message: "can't convert from hext to UIColor with hex = \(hexString)")
            return
        }
        colorView.backgroundColor = currentColor
    }
    
    func initViewWithColor(color: UIColor) {
        colorView.backgroundColor = color
    }
}
