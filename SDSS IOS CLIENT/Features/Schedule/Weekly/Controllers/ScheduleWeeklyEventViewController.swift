//
//  ScheduleWeeklyEventViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 04/07/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

fileprivate enum EventSection: Int {
    case presentation = 0
    case time = 1
    case color = 2
}

fileprivate enum PresentationRow: Int {
    case selectPresentation = 0
}

fileprivate enum TimeRow: Int {
    case week = 0
    case startTime = 1
    case endTime = 2
}

fileprivate enum ColorRow: Int {
    case selectColor = 0
}

protocol ScheduleWeeklyEventViewControllerDelegate {
    func handleAddNewEvent(_ weeklyEvent: WeeklySchedulePresentation)
    func handleEditEvent(_ weeklyEvent: WeeklySchedulePresentation)
}

class ScheduleWeeklyEventViewController: BaseTableViewController {
    
    // input values
    var weeklyEvent: WeeklySchedulePresentation = WeeklySchedulePresentation()

    fileprivate let dateFormatter = DateFormatter()
    
    fileprivate var isEditMode = false
    
    fileprivate var isShowStartTimeDatePicker = false
    fileprivate var isShowEndTimeDatePicker = false
    
    var delegate: ScheduleWeeklyEventViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        initNavigationBar()
        
        self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        // register all cells
        self.tableView.register(UINib(nibName: "EventSelectPresentationCell", bundle: nil), forCellReuseIdentifier: "EventSelectPresentationCell")
        self.tableView.register(UINib(nibName: "EventSelectTimeCell", bundle: nil), forCellReuseIdentifier: "EventSelectTimeCell")
        self.tableView.register(UINib(nibName: "SelectColorCell", bundle: nil), forCellReuseIdentifier: "SelectColorCell")
        self.tableView.register(UINib(nibName: "TimePickerCell", bundle: nil), forCellReuseIdentifier: "TimePickerCell")
        self.tableView.register(UINib(nibName: "WeeklySelectionCell", bundle: nil), forCellReuseIdentifier: "WeeklySelectionCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func initController() {
        // set default values
        loadFirstPresentation()
        
        let component = Calendar.current.dateComponents([.weekday, .hour, .minute], from: Date())
        self.weeklyEvent.startDay = Utility.getWeekdayString(by: component.weekday!)
        self.weeklyEvent.startTime = component.hour!*60 + component.minute!
        self.weeklyEvent.duration = kScheduleHourGripDivisionValue // 1h = 60 minutes
        self.weeklyEvent.colorLabel = "#35B1F1"
        
        updateTitle()

        self.tableView.reloadData()
    }
    
    public func initControllerWithStartDate(_ startDate: Date, endDate: Date) {
        let startDateComponent = Calendar.current.dateComponents([.weekday, .hour, .minute], from: startDate)
        let endDateComponent = Calendar.current.dateComponents([.hour, .minute], from: endDate)

        self.weeklyEvent.startDay = Utility.getWeekdayString(by: startDateComponent.weekday!)
        self.weeklyEvent.startTime = startDateComponent.hour!*60 + startDateComponent.minute!
        self.weeklyEvent.duration = (endDateComponent.hour!*60 + endDateComponent.minute!) - self.weeklyEvent.startTime

        // set default values
        loadFirstPresentation()
        self.weeklyEvent.colorLabel = "#35B1F1"

        updateTitle()

        self.tableView.reloadData()
    }
    
    public func initControllerWithWeeklyEvent(_ weeklyEvent: WeeklySchedulePresentation) {
        // init weeklyEvent
        self.weeklyEvent.id = weeklyEvent.id
        self.weeklyEvent.presentation = weeklyEvent.presentation
        self.weeklyEvent.code = weeklyEvent.code
        self.weeklyEvent.name = weeklyEvent.name
        self.weeklyEvent.zOrder = weeklyEvent.zOrder
        self.weeklyEvent.startTime = weeklyEvent.startTime
        self.weeklyEvent.startDay = weeklyEvent.startDay
        self.weeklyEvent.duration = weeklyEvent.duration
        self.weeklyEvent.colorLabel = weeklyEvent.colorLabel
        self.weeklyEvent.eventName = weeklyEvent.eventName
        
        self.isEditMode = true
        
        updateTitle()
        
        self.tableView.reloadData()
    }
    
    fileprivate func updateTitle() {
        if isEditMode {
            self.title = localizedString(key: "schedule_realtime_event_edit_title")
        } else {
            self.title = localizedString(key: "schedule_realtime_event_add_new_title")
        }
    }

    fileprivate func initNavigationBar() {
        let cancelButton = UIBarButtonItem.init(title: localizedString(key: "common_cancel"), style: .plain, target: self, action: #selector(cancelButtonClicked(barButton:)))
        let doneButton = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(doneButtonClicked(barButton:)))
        
        navigationItem.rightBarButtonItem = doneButton
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    fileprivate func loadFirstPresentation() {
        if self.weeklyEvent.presentation == "" {
            // load the first presentation on local
            if let templateSlide = TemplateSlide.getFirstPresentationForCurerntUser() {
                self.weeklyEvent.presentation = templateSlide.presentationId
                self.weeklyEvent.name = getPresentationNameById(templateSlide.presentationId)
            }
        }
    }
    
    fileprivate func getPresentationNameById(_ id: String) -> String {
        if let presentationInfo = DesignFileHelper.getPresentationByPresentationId(id) {
            return presentationInfo.name
        }
        
        return ""
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension ScheduleWeeklyEventViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return EventSection.color.rawValue + 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case EventSection.presentation.rawValue:
            return PresentationRow.selectPresentation.rawValue + 1
        case EventSection.time.rawValue:
            if isShowStartTimeDatePicker || isShowEndTimeDatePicker {
                return TimeRow.endTime.rawValue + 2
            }
            return TimeRow.endTime.rawValue + 1
        case EventSection.color.rawValue:
            return ColorRow.selectColor.rawValue + 1
        default:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == EventSection.presentation.rawValue {
            return 60
        } else if indexPath.section == EventSection.time.rawValue {
            if (isShowStartTimeDatePicker && indexPath.row == 2) || (isShowEndTimeDatePicker && indexPath.row == 3) {
                return 216
            }
        }
        
        return 44
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
            
        case EventSection.presentation.rawValue:
            if indexPath.row == PresentationRow.selectPresentation.rawValue {
                let cell = tableView.dequeueReusableCell(withIdentifier: "EventSelectPresentationCell") as? EventSelectPresentationCell
                cell?.initViewWithPresentationId(weeklyEvent.presentation)
                return cell!
            }
            
        case EventSection.time.rawValue:
            if indexPath.row == TimeRow.week.rawValue { // init week cell
                let cell = tableView.dequeueReusableCell(withIdentifier: "WeeklySelectionCell") as? WeeklySelectionCell
                cell?.initView(with: self.weeklyEvent.startDay)
                cell?.delegate = self
                return cell!
            }
            
            if indexPath.row == TimeRow.startTime.rawValue { // init startTime cell
                let cell = tableView.dequeueReusableCell(withIdentifier: "EventSelectTimeCell") as? EventSelectTimeCell
                cell?.initView(withStartTime: self.weeklyEvent.startTime, andTitle: localizedString(key: "schedule_realtime_start_time_title"))
                return cell!
            }
            
            if isShowStartTimeDatePicker {
                if indexPath.row == 2 { // init TimePickerCell
                    let cell = tableView.dequeueReusableCell(withIdentifier: "TimePickerCell") as? TimePickerCell
                    cell?.initView(withStartTime: self.weeklyEvent.startTime)
                    cell?.delegate = self
                    return cell!
                } else { // init endTime cell
                    let cell = tableView.dequeueReusableCell(withIdentifier: "EventSelectTimeCell") as? EventSelectTimeCell
                    cell?.initView(withStartTime: self.weeklyEvent.startTime + self.weeklyEvent.duration, andTitle: localizedString(key: "schedule_realtime_end_time_title"))
                    return cell!
                }
            } else if isShowEndTimeDatePicker {
                if indexPath.row == 2 { // init endTime cell
                    let cell = tableView.dequeueReusableCell(withIdentifier: "EventSelectTimeCell") as? EventSelectTimeCell
                    cell?.initView(withStartTime: self.weeklyEvent.startTime + self.weeklyEvent.duration, andTitle: localizedString(key: "schedule_realtime_end_time_title"))
                    return cell!
                } else { // init TimePickerCell
                    let cell = tableView.dequeueReusableCell(withIdentifier: "TimePickerCell") as? TimePickerCell
                    cell?.initView(withStartTime: self.weeklyEvent.startTime + self.weeklyEvent.duration)
                    cell?.delegate = self
                    return cell!
                }
            } else {
                if indexPath.row == TimeRow.endTime.rawValue { // init endTime cell
                    let cell = tableView.dequeueReusableCell(withIdentifier: "EventSelectTimeCell") as? EventSelectTimeCell
                    cell?.initView(withStartTime: self.weeklyEvent.startTime + self.weeklyEvent.duration, andTitle: localizedString(key: "schedule_realtime_end_time_title"))
                    return cell!
                }
            }
            
        case EventSection.color.rawValue:
            if indexPath.row == ColorRow.selectColor.rawValue {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SelectColorCell") as? SelectColorCell
                cell?.initViewWithColor(hexString: self.weeklyEvent.colorLabel)
                return cell!
            }
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventSelectPresentationCell") as? EventSelectPresentationCell
            
            return cell!
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventSelectPresentationCell") as? EventSelectPresentationCell
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            
        case EventSection.presentation.rawValue:
            return localizedString(key: "schedule_realtime_section_presenation")
            
        case EventSection.time.rawValue:
            return localizedString(key: "schedule_realtime_section_time")
            
        case EventSection.color.rawValue:
            return localizedString(key: "schedule_realtime_section_color")
            
        default:
            return localizedString(key: "schedule_realtime_section_presenation")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case EventSection.presentation.rawValue:
            if indexPath.row == PresentationRow.selectPresentation.rawValue {
                // go to presentation list screen
                ControllerManager.goToPresentationListScreen(controller: self)
            }
            
        case EventSection.time.rawValue:
            if isShowStartTimeDatePicker {
                if indexPath.row == 1 {
                    // hide datePicker to choose start time
                    self.isShowStartTimeDatePicker = false
                    self.tableView.deleteRows(at: [IndexPath.init(row: 2, section: EventSection.time.rawValue)], with: .fade)
                    
                } else if indexPath.row == 3 {
                    // hide startTime dataPickerCell
                    self.isShowStartTimeDatePicker = false
                    self.tableView.deleteRows(at: [IndexPath.init(row: 2, section: EventSection.time.rawValue)], with: .fade)
                    
                    // show datePicker to choose end time
                    self.isShowEndTimeDatePicker = true
                    self.tableView.insertRows(at: [IndexPath.init(row: 3, section: EventSection.time.rawValue)], with: .top)
                }
            } else if isShowEndTimeDatePicker {
                if indexPath.row == 1 {
                    // hide endTime dataPickerCell
                    self.isShowEndTimeDatePicker = false
                    self.tableView.deleteRows(at: [IndexPath.init(row: 3, section: EventSection.time.rawValue)], with: .fade)
                    
                    // show datePicker to choose start time
                    self.isShowStartTimeDatePicker = true
                    self.tableView.insertRows(at: [IndexPath.init(row: 2, section: EventSection.time.rawValue)], with: .middle)
                    
                } else if indexPath.row == 2 {
                    // show datePicker to choose end time
                    self.isShowEndTimeDatePicker = false
                    self.tableView.deleteRows(at: [IndexPath.init(row: 3, section: EventSection.time.rawValue)], with: .fade)
                }
            } else {
                if indexPath.row == TimeRow.startTime.rawValue {
                    // show datePicker to choose start time
                    self.isShowStartTimeDatePicker = true
                    self.tableView.insertRows(at: [IndexPath.init(row: 2, section: EventSection.time.rawValue)], with: .middle)
                    
                } else if indexPath.row == TimeRow.endTime.rawValue {
                    // show datePicker to choose end time
                    self.isShowEndTimeDatePicker = true
                    self.tableView.insertRows(at: [IndexPath.init(row: 3, section: EventSection.time.rawValue)], with: .top)
                }
            }
            
        case EventSection.color.rawValue:
            if indexPath.row == ColorRow.selectColor.rawValue {
                // go to choose color screen
                guard let currentColor = UIColor.init(hexString: self.weeklyEvent.colorLabel) else {
                    dLog(message: "can't convert from hext to UIColor with hex = \(self.weeklyEvent.colorLabel)")
                    return
                }
                ControllerManager.goToColorPickerScreen(currentColor: currentColor, type: .none, controller: self)
            }
            
        default:
            dLog(message: "do something")
        }
    }
}

// MARK: - Validation

extension ScheduleWeeklyEventViewController {
    
    func isValidEventData() -> Bool {
        // check presentation info
        if self.weeklyEvent.presentation == "" || self.weeklyEvent.name == "" {
            Utility.showAlertWithErrorMessage(message: localizedString(key: "schedule_event_presentation_empty"), controller: self)
            return false
        }
        
        // check end time before start time
        if self.weeklyEvent.duration < 0 {
            Utility.showAlertWithErrorMessage(message: localizedString(key: "schedule_event_end_time_before_start_time"), controller: self)
            return false
        }
        
        // check playtime must be >= 30 mins
        if self.weeklyEvent.duration < kScheduleMinDuration {
            Utility.showAlertWithErrorMessage(message: localizedString(key: "schedule_event_duration_too_short"), controller: self)
            return false
        }
        
        // check color
        if self.weeklyEvent.colorLabel == "" {
            Utility.showAlertWithErrorMessage(message: localizedString(key: "schedule_event_color_empty"), controller: self)
            return false
        }
        
        return true
    }
}

// MARK: - Handle Events

extension ScheduleWeeklyEventViewController {
    
    func cancelButtonClicked(barButton: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func doneButtonClicked(barButton: UIBarButtonItem) {
        if !isValidEventData() {
            return
        }
        
        self.navigationController?.dismiss(animated: true, completion: {
            if self.isEditMode {
                self.delegate?.handleEditEvent(self.weeklyEvent)
            } else {
                self.delegate?.handleAddNewEvent(self.weeklyEvent)
            }
        })
    }
}

// MARK: - PresentationListViewControllerDelegate

extension ScheduleWeeklyEventViewController: PresentationListViewControllerDelegate {
    
    func handleAddPresentation(presentation: Presentation) {
        // update with new presentation id
        self.weeklyEvent.presentation = presentation.id
        self.weeklyEvent.name = getPresentationNameById(presentation.id)
        
        self.tableView.reloadRows(at: [IndexPath.init(row: PresentationRow.selectPresentation.rawValue, section: EventSection.presentation.rawValue)],
                                  with: .fade)
    }
}

// MARK: - TimePickerCellDelegate

extension ScheduleWeeklyEventViewController: TimePickerCellDelegate {
    
    func handleDatePickerValueChanged(date: Date) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let minuteInterval = components.hour!*60 + components.minute!
        
        if self.isShowStartTimeDatePicker {
            // check end time more than 23:59
            var endTime = minuteInterval + self.weeklyEvent.duration
            if endTime > (24*60 - 1) { // 23:59
                endTime = (24*60 - 1)
                self.weeklyEvent.duration = endTime - minuteInterval
            }
            
            self.weeklyEvent.startTime = minuteInterval
            self.tableView.reloadRows(at: [IndexPath.init(row: TimeRow.startTime.rawValue, section: EventSection.time.rawValue),
                                           IndexPath.init(row: TimeRow.endTime.rawValue + 1, section: EventSection.time.rawValue)],
                                      with: .fade)
        } else if self.isShowEndTimeDatePicker {
            if (minuteInterval - self.weeklyEvent.startTime) < 0 { // end time before start time
                Utility.showAlertWithErrorMessage(message: localizedString(key: "schedule_event_end_time_before_start_time"), controller: self)
                return
            }
            
            self.weeklyEvent.duration = (minuteInterval - self.weeklyEvent.startTime)
            self.tableView.reloadRows(at: [IndexPath.init(row: TimeRow.endTime.rawValue, section: EventSection.time.rawValue)],
                                      with: .fade)
        }
    }
}

// MARK: - CommonColorPickerViewControllerDelegate

extension ScheduleWeeklyEventViewController: CommonColorPickerViewControllerDelegate {
    
    func handleChangeColor(color: UIColor, type: SelectColorType) {
        self.weeklyEvent.colorLabel = color.toHexString()
        self.tableView.reloadRows(at: [IndexPath.init(row: ColorRow.selectColor.rawValue, section: EventSection.color.rawValue)],
                                  with: .fade)
    }
}

// MARK: - EventSelectPresentationCellDelegate

extension ScheduleWeeklyEventViewController: EventSelectPresentationCellDelegate {
    
    func handleLoadPresentationError(message: String) {
        Utility.showAlertWithErrorMessage(message: message, controller: self)
        
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - WeeklySelectionCellDelegate

extension ScheduleWeeklyEventViewController: WeeklySelectionCellDelegate {
    
    func handleChangeWeek(with weekString: String) {
        dLog(message: "changed weekString = \(weekString)")
        self.weeklyEvent.startDay = weekString
    }
}
