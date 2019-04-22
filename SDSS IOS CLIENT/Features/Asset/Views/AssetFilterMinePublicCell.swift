//
//  AssetFilterMinePublicCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 22/10/2018.
//  Copyright © 2018 SLab. All rights reserved.
//

import UIKit

protocol AssetFilterMinePublicCellDelegate {
    func handleMineSwitchChanged()
}

class AssetFilterMinePublicCell: UITableViewCell {
    
    @IBOutlet weak var mineView: UIView!
    @IBOutlet weak var publicView: UIView!
    
    @IBOutlet weak var mineLabel: UILabel!
    @IBOutlet weak var publicLabel: UILabel!
    
    @IBOutlet weak var mineSwitch: UISwitch!
    @IBOutlet weak var publicSwitch: UISwitch!
    
    var assetFilter: AssetFilter?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        mineLabel.text = localizedString(key: "filter_mine_title")
        publicLabel.text = localizedString(key: "filter_public_title")
    }
    
    func initView(_ filter: AssetFilter) {
        self.assetFilter = filter
        
        mineSwitch.isOn = filter.isMine
        publicSwitch.isOn = filter.isPublic
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func mineSwitchChanged(_ sender: UISwitch) {
        self.assetFilter?.isMine = sender.isOn
    }
    
    @IBAction func publicSwitchChanged(_ sender: UISwitch) {
        self.assetFilter?.isPublic = sender.isOn
    }
    
}
