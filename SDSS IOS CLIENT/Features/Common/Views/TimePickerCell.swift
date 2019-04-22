//
//  TimePickerCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 04/07/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

protocol TimePickerCellDelegate {
    func handleDatePickerValueChanged(date: Date)
}

class TimePickerCell: UITableViewCell {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var delegate: TimePickerCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initView(withStartTime startTime: Int) {
        let hours = startTime / 60
        let minutes = startTime % 60
        guard let date = Calendar.current.date(bySettingHour: hours, minute: minutes, second: 0, of: Date()) else {
            return
        }
        self.datePicker.date = date
    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        delegate?.handleDatePickerValueChanged(date: sender.date)
    }

}
