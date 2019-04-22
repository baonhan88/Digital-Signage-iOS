//
//  AssetFilterTypeCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 04/05/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

class AssetFilterTypeCell: UITableViewCell {
    
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.leftLabel.text = localizedString(key: "asset_filter_type_title")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initView(_ filter: AssetFilter) {
        var typeListString = ""
        
        var count = 0
        for type in filter.typeList {
            for selectedType in filter.selectedTypeList {
                if selectedType == type {
                    if count == 0 {
                        typeListString.append(type)
                    } else {
                        typeListString.append(", " + type)
                    }
                    
                    count += 1
                    
                    break
                }
                
            }
            
        }
        
        if filter.typeList.count == 0 {
            self.rightLabel.text = localizedString(key: "asset_filter_choose_type")
        } else {
            self.rightLabel.text = typeListString
        }
    }
    
}
