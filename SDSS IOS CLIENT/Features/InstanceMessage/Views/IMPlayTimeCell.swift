//
//  IMPlayTimeCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 14/01/2019.
//  Copyright © 2019 SLab. All rights reserved.
//

import UIKit

class IMPlayTimeCell: UITableViewCell {
    
    @IBOutlet weak var playTimeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        playTimeLabel.text = localizedString(key: "im_cell_play_time")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initView(playTime: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        guard let date = dateFormatter.date(from: playTime) else {
            timeLabel.text = ""
            return
        }
        
        dateFormatter.dateFormat = "MMM dd, yyyy HH:mm"
        
        timeLabel.text = dateFormatter.string(from: date)
    }
    
}
