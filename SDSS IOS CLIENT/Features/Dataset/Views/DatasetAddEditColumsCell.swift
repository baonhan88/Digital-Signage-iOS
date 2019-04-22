//
//  DatasetAddEditColumsCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 12/12/2018.
//  Copyright © 2018 SLab. All rights reserved.
//

import UIKit

protocol DatasetAddEditColumsCellDelegate {
    func handleColumn1Changed(text: String)
    func handleColumn2Changed(text: String)
    func handleColumn3Changed(text: String)
    func handleColumn4Changed(text: String)
}

class DatasetAddEditColumsCell: UITableViewCell {
    
    var delegate: DatasetAddEditColumsCellDelegate?
    
    @IBOutlet weak var column1TextField: UITextField!
    @IBOutlet weak var column2TextField: UITextField!
    @IBOutlet weak var column3TextField: UITextField!
    @IBOutlet weak var column4TextField: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func initViewWithColumns(columns: [DatasetType]) {
        if columns.count == 0 {
            column1TextField.text = "customer"
            column2TextField.text = "time"
            column3TextField.text = "slot"
            column4TextField.text = "position"
            
            return
        }
        
        for i in 0 ..< columns.count {
            if i == 0 {
                let column1: DatasetType = columns[0]
                column1TextField.text = column1.name
                
            } else if i == 1 {
                let column2: DatasetType = columns[1]
                column2TextField.text = column2.name
                
            } else if i == 2 {
                let column3: DatasetType = columns[2]
                column3TextField.text = column3.name
                
            } else if i == 3 {
                let column4: DatasetType = columns[3]
                column4TextField.text = column4.name
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func column1TextFieldChange(_ sender: UITextField) {
        delegate?.handleColumn1Changed(text: sender.text!)
    }
    
    @IBAction func column2TextFieldChanged(_ sender: UITextField) {
        delegate?.handleColumn2Changed(text: sender.text!)
    }
    
    @IBAction func column3TextFieldChanged(_ sender: UITextField) {
        delegate?.handleColumn3Changed(text: sender.text!)
    }
    
    @IBAction func column4TextFieldChanged(_ sender: UITextField) {
        delegate?.handleColumn4Changed(text: sender.text!)
    }
}
