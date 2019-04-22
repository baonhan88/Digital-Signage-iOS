//
//  IMListCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 21/06/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

protocol IMListCellDelegate {
    func handleTapOnEditButton(displayEvent: DisplayEvent)
    func handleTapOnDeleteButton(displayEvent: DisplayEvent)
}

class IMListCell: UITableViewCell {

    @IBOutlet weak var contentVIew: UIView!
    @IBOutlet weak var infoLevelView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    var displayEvent: DisplayEvent?
    
    var delegate: IMListCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.contentVIew.layer.borderColor = UIColor.lightGray.cgColor
        self.contentVIew.layer.borderWidth = 1
        self.contentVIew.layer.cornerRadius = 8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initView(_ displayEvent: DisplayEvent) {
        self.displayEvent = displayEvent
        
        nameLabel.text = displayEvent.name
        descLabel.text = String.init(format: localizedString(key: "im_list_duration"), displayEvent.duration)
        
        if displayEvent.infoLevel == "INFO" {
            infoLevelView.backgroundColor = UIColor.green
        } else if displayEvent.infoLevel == "WARN" {
            infoLevelView.backgroundColor = UIColor.yellow
        } else if displayEvent.infoLevel == "SENSITIVE" {
            infoLevelView.backgroundColor = UIColor.orange
        } else {
            infoLevelView.backgroundColor = UIColor.red
        }
    }
    
    @IBAction func editButtonClicked(_ sender: UIButton) {
        delegate?.handleTapOnEditButton(displayEvent: self.displayEvent!)
    }
    
    @IBAction func deleteButtonClicked(_ sender: UIButton) {
        delegate?.handleTapOnDeleteButton(displayEvent: self.displayEvent!)
    }
}
