//
//  RealTimeScheduleCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 21/06/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

protocol RealTimeScheduleCellDelegate {
    func handleTapOnEditButton(realTimeSchedule: RealTimeSchedule)
    func handleTapOnDeleteButton(realTimeSchedule: RealTimeSchedule)
}

class RealTimeScheduleCell: UITableViewCell {

    @IBOutlet weak var contentVIew: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    var realTimeSchedule: RealTimeSchedule?
    
    var delegate: RealTimeScheduleCellDelegate?
    
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
    
    func initViewWithRealTimeSchedule(_ realTimeSchedule: RealTimeSchedule) {
        self.realTimeSchedule = realTimeSchedule
        
        nameLabel.text = realTimeSchedule.name
        descLabel.text = realTimeSchedule.shortDescription
    }
    
    @IBAction func editButtonClicked(_ sender: UIButton) {
        delegate?.handleTapOnEditButton(realTimeSchedule: self.realTimeSchedule!)
    }
    
    @IBAction func deleteButtonClicked(_ sender: UIButton) {
        delegate?.handleTapOnDeleteButton(realTimeSchedule: self.realTimeSchedule!)
    }
}
