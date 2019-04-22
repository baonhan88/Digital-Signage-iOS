//
//  WeeklyScheduleCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 21/06/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

protocol WeeklyScheduleCellDelegate {
    func handleTapOnEditButton(weeklySchedule: WeeklySchedule)
    func handleTapOnDeleteButton(weeklySchedule: WeeklySchedule)
}

class WeeklyScheduleCell: UITableViewCell {

    @IBOutlet weak var contentVIew: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    var weeklySchedule: WeeklySchedule?
    
    var delegate: WeeklyScheduleCellDelegate?
    
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
    
    func initViewWithWeeklySchedule(_ weeklySchedule: WeeklySchedule) {
        self.weeklySchedule = weeklySchedule
        
        nameLabel.text = weeklySchedule.name
        descLabel.text = weeklySchedule.shortDescription
    }
    
    @IBAction func editButtonClicked(_ sender: UIButton) {
        delegate?.handleTapOnEditButton(weeklySchedule: self.weeklySchedule!)
    }
    
    @IBAction func deleteButtonClicked(_ sender: UIButton) {
        delegate?.handleTapOnDeleteButton(weeklySchedule: self.weeklySchedule!)
    }
}
