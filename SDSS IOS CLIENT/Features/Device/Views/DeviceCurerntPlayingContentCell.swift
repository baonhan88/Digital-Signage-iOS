//
//  DeviceCurerntPlayingContentCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 17/01/2019.
//  Copyright © 2019 SLab. All rights reserved.
//

import UIKit

class DeviceCurerntPlayingContentCell: UITableViewCell {

    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initView(contentName: String) {
        contentLabel.text = contentName
    }
}
