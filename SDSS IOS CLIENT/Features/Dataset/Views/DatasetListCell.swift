//
//  DatasetListCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 21/06/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

protocol DatasetListCellDelegate {
    func handleTapOnEditButton(dataset: Dataset)
    func handleTapOnDeleteButton(dataset: Dataset)
}

class DatasetListCell: UITableViewCell {

    @IBOutlet weak var contentVIew: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    var dataset: Dataset?
    
    var delegate: DatasetListCellDelegate?
    
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
    
    func initViewWithDataset(_ dataset: Dataset) {
        self.dataset = dataset
        
        nameLabel.text = dataset.name
        descLabel.text = dataset.app
    }
    
    @IBAction func editButtonClicked(_ sender: UIButton) {
        delegate?.handleTapOnEditButton(dataset: self.dataset!)
    }
    
    @IBAction func deleteButtonClicked(_ sender: UIButton) {
        delegate?.handleTapOnDeleteButton(dataset: self.dataset!)
    }
}
