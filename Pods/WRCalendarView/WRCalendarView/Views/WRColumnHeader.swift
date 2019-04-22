//
//  ScheduleWeekColumnHeader.swift
//  Argos
//
//  Created by wayfinder on 2017. 4. 2..
//  Copyright © 2017년 Tong. All rights reserved.
//

import UIKit
import DateToolsSwift

class WRColumnHeader: UICollectionReusableView {
    @IBOutlet weak var dayLbl: UILabel!
    @IBOutlet weak var monthAndYearLbl: UILabel!
    
    let calendar = Calendar.current
    let dateFormatter = DateFormatter()
    
    var calendarType: CalendarType?
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        dateFormatter.locale = Locale(identifier: "en_US")
    }
    
    var date: Date? {
        didSet {
            if let date = date {
                let weekday = calendar.component(.weekday, from: date) - 1
                let weekdayString = dateFormatter.shortWeekdaySymbols[weekday].uppercased()

                if self.calendarType == CalendarType.weekly {
                    dayLbl.text = weekdayString
                    monthAndYearLbl.text = ""
                } else {
                    dayLbl.text = String(calendar.component(.day, from: date))
                    
                    let month = String(calendar.component(.month, from: date))
                    let year = String(calendar.component(.year, from: date))
                    monthAndYearLbl.text = weekdayString + " " + year + "/" + month
                    monthAndYearLbl.textColor = UIColor.init(r: 51, g: 51, b: 51)
                }
                
                if date.isSameDay(date: Date()) {
                    dayLbl.textColor = UIColor.init(r: 19, g: 152, b: 242)
                    backgroundColor = UIColor.init(r: 245, g: 248, b: 253)
                } else {
                    switch weekday {
                    case 0: // sunday
                        dayLbl.textColor = UIColor.init(r: 254, g: 70, b: 70)
                    case 6:
                        dayLbl.textColor = UIColor.init(r: 53, g: 115, b: 255)
                    default:
                        dayLbl.textColor = UIColor.init(r: 170, g: 170, b: 170)
                    }
                    backgroundColor = UIColor.white
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dayLbl.text = ""
        monthAndYearLbl.text = ""
    }
}
