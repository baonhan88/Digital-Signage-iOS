//
//  DatasetRowUpdateCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 18/12/2018.
//  Copyright © 2018 SLab. All rights reserved.
//

import UIKit

class DatasetRowUpdateCell: UITableViewCell {
    
    @IBOutlet weak var containView: UIView!
    
    @IBOutlet weak var customerLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var slotLabel: UILabel!
    @IBOutlet weak var areaLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        containView.layer.borderWidth = 1.0
        containView.layer.borderColor = UIColor.lightGray.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initViewWithData(datasetData: DatasetData) {
        customerLabel.text = datasetData.customer
        timeLabel.text = datasetData.time
        slotLabel.text = datasetData.slot
        areaLabel.text = datasetData.area
    }
    
}
