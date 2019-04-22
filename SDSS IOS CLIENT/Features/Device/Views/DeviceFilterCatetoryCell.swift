//
//  DeviceFilterCatetoryCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 04/05/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

class DeviceFilterCatetoryCell: UITableViewCell {
    
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.leftLabel.text = localizedString(key: "filter_category_title")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initView(_ deviceFilter: DeviceFilter) {
        if deviceFilter.group.name == "" {
            self.rightLabel.text = localizedString(key: "filter_choose_category")
        } else {
            self.rightLabel.text = deviceFilter.group.name
        }
    }
    
}
