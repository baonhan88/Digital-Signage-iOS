//
//  AssetFilterTagCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 04/05/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

class AssetFilterTagCell: UITableViewCell {
    
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.leftLabel.text = localizedString(key: "filter_tag_list_title")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initView(_ filter: AssetFilter) {
        var tagListString = ""
        
        var count = 0
        for tag in filter.tagList {
            for selectedTagId in filter.selectedTagIdList {
                if selectedTagId == tag.id {
                    if count == 0 {
                        tagListString.append(tag.value)
                    } else {
                        tagListString.append(", " + tag.value)
                    }
                    
                    count += 1
                    
                    break
                }
               
            }
            
        }
        
        if tagListString ==  "" {
            self.rightLabel.text = localizedString(key: "filter_choose_tag")
        } else {
            self.rightLabel.text = tagListString
        }
    }
    
}
