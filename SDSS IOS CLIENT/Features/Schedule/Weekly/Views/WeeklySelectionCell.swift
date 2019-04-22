//
//  WeeklySelectionCell.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 08/07/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

protocol WeeklySelectionCellDelegate {
    func handleChangeWeek(with weekString: String)
}

class WeeklySelectionCell: UITableViewCell {

    @IBOutlet weak var sunButton: UIButton!
    @IBOutlet weak var monButton: UIButton!
    @IBOutlet weak var tueButton: UIButton!
    @IBOutlet weak var wedButton: UIButton!
    @IBOutlet weak var thuButton: UIButton!
    @IBOutlet weak var friButton: UIButton!
    @IBOutlet weak var satButton: UIButton!
    
    fileprivate let kNormalStyleTitleColor = UIColor.blue
    fileprivate let kNormalStyleBgColor = UIColor.white
    fileprivate let kSelectedStyleTitleColor = UIColor.white
    fileprivate let kSelectedStyleBgColor = UIColor.blue
    
    var currentWeekSelected: String = WeekType.mon.weekString()
    
    var delegate: WeeklySelectionCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        sunButton.setTitle(localizedString(key: "schedule_weekly_select_week_sun"), for: .normal)
        monButton.setTitle(localizedString(key: "schedule_weekly_select_week_mon"), for: .normal)
        tueButton.setTitle(localizedString(key: "schedule_weekly_select_week_tue"), for: .normal)
        wedButton.setTitle(localizedString(key: "schedule_weekly_select_week_wed"), for: .normal)
        thuButton.setTitle(localizedString(key: "schedule_weekly_select_week_thu"), for: .normal)
        friButton.setTitle(localizedString(key: "schedule_weekly_select_week_fri"), for: .normal)
        satButton.setTitle(localizedString(key: "schedule_weekly_select_week_sat"), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func initView(with weekSelected: String) {
        deselectAllButton()

        switch weekSelected {
        case WeekType.sun.weekString():
            makeSelectedStyle(for: sunButton)
            break
        case WeekType.mon.weekString():
            makeSelectedStyle(for: monButton)
            break
        case WeekType.tue.weekString():
            makeSelectedStyle(for: tueButton)
            break
        case WeekType.wed.weekString():
            makeSelectedStyle(for: wedButton)
            break
        case WeekType.thu.weekString():
            makeSelectedStyle(for: thuButton)
            break
        case WeekType.fri.weekString():
            makeSelectedStyle(for: friButton)
            break
        case WeekType.sat.weekString():
            makeSelectedStyle(for: satButton)
            break
        default:
            makeSelectedStyle(for: monButton)
        }
    }
    
    fileprivate func getWeekString(by tag: Int) -> String {
        switch tag {
        case WeekType.sun.tag():
            return WeekType.sun.weekString()
        case WeekType.mon.tag():
            return WeekType.mon.weekString()
        case WeekType.tue.tag():
            return WeekType.tue.weekString()
        case WeekType.wed.tag():
            return WeekType.wed.weekString()
        case WeekType.thu.tag():
            return WeekType.thu.weekString()
        case WeekType.fri.tag():
            return WeekType.fri.weekString()
        case WeekType.sat.tag():
            return WeekType.sat.weekString()
        default:
            return WeekType.mon.weekString()
        }
    }
    
    fileprivate func deselectAllButton() {
        makeNormalStyle(for: sunButton)
        makeNormalStyle(for: monButton)
        makeNormalStyle(for: tueButton)
        makeNormalStyle(for: wedButton)
        makeNormalStyle(for: thuButton)
        makeNormalStyle(for: friButton)
        makeNormalStyle(for: satButton)
    }
    
    fileprivate func makeNormalStyle(for button: UIButton) {
        button.setTitleColor(kNormalStyleTitleColor, for: UIControlState.normal)
        button.backgroundColor = kNormalStyleBgColor
    }
    
    fileprivate func makeSelectedStyle(for button: UIButton) {
        button.setTitleColor(kSelectedStyleTitleColor, for: UIControlState.normal)
        button.backgroundColor = kSelectedStyleBgColor
    }
    
    @IBAction func weekButtonClicked(_ sender: UIButton) {
        deselectAllButton()
        
        makeSelectedStyle(for: sender)
        
        delegate?.handleChangeWeek(with: getWeekString(by: sender.tag))
    }
}
