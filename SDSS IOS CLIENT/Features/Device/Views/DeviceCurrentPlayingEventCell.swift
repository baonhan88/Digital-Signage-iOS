//
//  DeviceCurrentPlayingEventCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 17/01/2019.
//  Copyright © 2019 SLab. All rights reserved.
//

import UIKit

class DeviceCurrentPlayingEventCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initView(name: String, time: String) {
        nameLabel.text = name
        
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        guard let date = dateFormatter.date(from: time) else {
            timeLabel.text = time
            return
        }
        
        dateFormatter.dateFormat = "hh:mm a"
        timeLabel.text = dateFormatter.string(from: date)
    }
}
