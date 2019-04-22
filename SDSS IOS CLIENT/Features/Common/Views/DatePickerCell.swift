//
//  DatePickerCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 04/07/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

protocol DatePickerCellDelegate {
    func handleDatePickerValueChanged(date: Date)
}

class DatePickerCell: UITableViewCell {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var delegate: DatePickerCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initViewWithDate(_ date: Date) {
        self.datePicker.date = date
    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        delegate?.handleDatePickerValueChanged(date: sender.date)
    }

}
