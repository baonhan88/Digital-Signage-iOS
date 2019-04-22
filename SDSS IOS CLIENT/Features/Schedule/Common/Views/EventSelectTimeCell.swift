//
//  EventSelectTimeCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 04/07/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

class EventSelectTimeCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var currentScheduleType: ScheduleType?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initViewWithDate(_ dateString: String, title: String) {
        self.currentScheduleType = ScheduleType.realTime
        
        self.titleLabel.text = title
        
        if dateString != "" {
            // init date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            let date = dateFormatter.date(from: dateString)
            dateFormatter.dateFormat = "yyyy/MM/dd - HH:mm"
            timeLabel.text = dateFormatter.string(from: date!)
        }
    }
    
    func initView(withStartTime minutes: Int, andTitle title: String) {
        self.currentScheduleType = ScheduleType.weekly
        
        self.titleLabel.text = title
        
        // calculate time from minutes
        let hours = minutes / 60
        let mins = minutes % 60
        self.timeLabel.text = String.init(format: "%02d : %02d", hours, mins)
    }
}
