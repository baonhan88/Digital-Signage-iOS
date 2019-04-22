//
//  TemplateMinePublicLockCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 22/10/2018.
//  Copyright © 2018 SLab. All rights reserved.
//

import UIKit

protocol TemplateMinePublicLockCellDelegate {
    func handleMineSwitchChanged()
}

class TemplateMinePublicLockCell: UITableViewCell {
    
    @IBOutlet weak var mineView: UIView!
    @IBOutlet weak var publicView: UIView!
    @IBOutlet weak var lockView: UIView!
    
    @IBOutlet weak var mineLabel: UILabel!
    @IBOutlet weak var publicLabel: UILabel!
    @IBOutlet weak var lockLabel: UILabel!
    
    @IBOutlet weak var mineSwitch: UISwitch!
    @IBOutlet weak var publicSwitch: UISwitch!
    @IBOutlet weak var lockSwitch: UISwitch!
    
    var templateFilter: TemplateFilter?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        mineLabel.text = localizedString(key: "filter_mine_title")
        publicLabel.text = localizedString(key: "filter_public_title")
        lockLabel.text = localizedString(key: "filter_lock_title")
    }
    
    func initViewWithTemplateFilter(_ templateFilter: TemplateFilter) {
        self.templateFilter = templateFilter
        
        mineSwitch.isOn = templateFilter.isMine
        publicSwitch.isOn = templateFilter.isPublic
        lockSwitch.isOn = templateFilter.isLock
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func mineSwitchChanged(_ sender: UISwitch) {
        self.templateFilter?.isMine = sender.isOn
    }
    
    @IBAction func publicSwitchChanged(_ sender: UISwitch) {
        self.templateFilter?.isPublic = sender.isOn
    }
    
    @IBAction func lockSwitchChanged(_ sender: UISwitch) {
        self.templateFilter?.isLock = sender.isOn
    }
    
}
