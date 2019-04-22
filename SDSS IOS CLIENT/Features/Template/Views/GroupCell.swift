//
//  GroupCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 21/06/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

protocol GroupCellDelegate {
    func handleTapOnEditButton(group: Group)
    func handleTapOnDeleteButton(group: Group)
}

class GroupCell: UITableViewCell {

    @IBOutlet weak var contentVIew: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    var group: Group?
    
    var delegate: GroupCellDelegate?
    
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
    
    func initViewWithGroup(_ group: Group) {
        self.group = group
        
        nameLabel.text = group.name
    }
    
    @IBAction func editButtonClicked(_ sender: UIButton) {
        delegate?.handleTapOnEditButton(group: self.group!)
    }
    
    @IBAction func deleteButtonClicked(_ sender: UIButton) {
        delegate?.handleTapOnDeleteButton(group: self.group!)
    }
}
