//
//  PlayListCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 21/06/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

protocol PlayListCellDelegate {
    func handleTapOnEditButton(playList: PlayList)
    func handleTapOnDeleteButton(playList: PlayList)
}

class PlayListCell: UITableViewCell {

    @IBOutlet weak var contentVIew: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    var playList: PlayList?
    
    var delegate: PlayListCellDelegate?
    
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
    
    func initViewWithPlayList(_ playList: PlayList) {
        self.playList = playList
        
        nameLabel.text = playList.name
        descLabel.text = playList.shortDescription
    }
    
    @IBAction func editButtonClicked(_ sender: UIButton) {
        delegate?.handleTapOnEditButton(playList: self.playList!)
    }
    
    @IBAction func deleteButtonClicked(_ sender: UIButton) {
        delegate?.handleTapOnDeleteButton(playList: self.playList!)
    }
}
