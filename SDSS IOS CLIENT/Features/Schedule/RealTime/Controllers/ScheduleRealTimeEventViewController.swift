//
//  ScheduleRealTimeEventViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 04/07/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

private enum EventSection: Int {
    case presentation = 0
    case time = 1
    case color = 2
}

private enum PresentationRow: Int {
    case selectPresentation = 0
}

private enum TimeRow: Int {
    case startTime = 0
    case endTime = 1
}

private enum ColorRow: Int {
    case selectColor = 0
}

protocol ScheduleRealTimeEventViewControllerDelegate {
    func handleAddNewEvent(_ realTimeEvent: RealTimeSchedulePresentation)
    func handleEditEvent(_ realTimeEvent: RealTimeSchedulePresentation)
}

class ScheduleRealTimeEventViewController: BaseTableViewController {
    
    // input values
    var realTimeEvent: RealTimeSchedulePresentation = RealTimeSchedulePresentation()

    fileprivate let dateFormatter = DateFormatter()
    
    fileprivate var isEditMode = false
    
    fileprivate var isShowStartTimeDatePicker = false
    fileprivate var isShowEndTimeDatePicker = false
    
    var delegate: ScheduleRealTimeEventViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        initNavigationBar()
        
        self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        // register all cells
        self.tableView.register(UINib(nibName: "EventSelectPresentationCell", bundle: nil), forCellReuseIdentifier: "EventSelectPresentationCell")
        self.tableView.register(UINib(nibName: "EventSelectTimeCell", bundle: nil), forCellReuseIdentifier: "EventSelectTimeCell")
        self.tableView.register(UINib(nibName: "SelectColorCell", bundle: nil), forCellReuseIdentifier: "SelectColorCell")
        self.tableView.register(UINib(nibName: "DatePickerCell", bundle: nil), forCellReuseIdentifier: "DatePickerCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func initController() {
        // set default values
        loadFirstPresentation()
        self.realTimeEvent.startDate = self.dateFormatter.string(from: Date())
        self.realTimeEvent.endDate = self.dateFormatter.string(from: Date().add(kScheduleHourGripDivisionValue.minutes))
        self.realTimeEvent.colorLabel = "#35B1F1"
        
        updateTitle()
        
        self.tableView.reloadData()
    }
    
    public func initControllerWithStartDate(_ startDate: Date, endDate: Date) {
        self.realTimeEvent.startDate = self.dateFormatter.string(from: startDate)
        self.realTimeEvent.endDate = self.dateFormatter.string(from: endDate)
        
        // set default values
        loadFirstPresentation()
        self.realTimeEvent.colorLabel = "#35B1F1"
        
        updateTitle()

        self.tableView.reloadData()
    }
    
    public func initControllerWithRealTimeEvent(_ realTimeEvent: RealTimeSchedulePresentation) {
        // init realTimeEvent
        self.realTimeEvent.id = realTimeEvent.id
        self.realTimeEvent.presentation = realTimeEvent.presentation
        self.realTimeEvent.code = realTimeEvent.code
        self.realTimeEvent.zOrder = realTimeEvent.zOrder
        self.realTimeEvent.startDate = realTimeEvent.startDate
        self.realTimeEvent.endDate = realTimeEvent.endDate
        self.realTimeEvent.repeat = realTimeEvent.repeat
        self.realTimeEvent.colorLabel = realTimeEvent.colorLabel
        self.realTimeEvent.eventName = realTimeEvent.eventName
        self.realTimeEvent.name = realTimeEvent.name
        
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
        if self.realTimeEvent.presentation == "" {
            // load the first presentation on local
            if let templateSlide = TemplateSlide.getFirstPresentationForCurerntUser() {
                self.realTimeEvent.presentation = templateSlide.presentationId
                self.realTimeEvent.name = getPresentationNameById(templateSlide.presentationId)
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

extension ScheduleRealTimeEventViewController {
    
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
            if (isShowStartTimeDatePicker && indexPath.row == 1) || (isShowEndTimeDatePicker && indexPath.row == 2) {
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
                cell?.initViewWithPresentationId(realTimeEvent.presentation)
                return cell!
            }
            
        case EventSection.time.rawValue:
            if isShowStartTimeDatePicker {
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "EventSelectTimeCell") as? EventSelectTimeCell
                    cell?.initViewWithDate(self.realTimeEvent.startDate, title: localizedString(key: "schedule_realtime_start_time_title"))
                    return cell!
                } else if indexPath.row == 1 { // show DatePickerCell
                    let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell") as? DatePickerCell
                    cell?.initViewWithDate(self.dateFormatter.date(from: self.realTimeEvent.startDate)!)
                    cell?.delegate = self
                    return cell!
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "EventSelectTimeCell") as? EventSelectTimeCell
                    cell?.initViewWithDate(self.realTimeEvent.endDate, title: localizedString(key: "schedule_realtime_end_time_title"))
                    return cell!
                }
            } else if isShowEndTimeDatePicker {
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "EventSelectTimeCell") as? EventSelectTimeCell
                    cell?.initViewWithDate(self.realTimeEvent.startDate, title: localizedString(key: "schedule_realtime_start_time_title"))
                    return cell!
                } else if indexPath.row == 1 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "EventSelectTimeCell") as? EventSelectTimeCell
                    cell?.initViewWithDate(self.realTimeEvent.endDate, title: localizedString(key: "schedule_realtime_end_time_title"))
                    return cell!
                } else { // show DatePickerCell
                    let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell") as? DatePickerCell
                    cell?.initViewWithDate(self.dateFormatter.date(from: self.realTimeEvent.endDate)!)
                    cell?.delegate = self
                    return cell!
                }
            } else {
                if indexPath.row == TimeRow.startTime.rawValue {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "EventSelectTimeCell") as? EventSelectTimeCell
                    cell?.initViewWithDate(self.realTimeEvent.startDate, title: localizedString(key: "schedule_realtime_start_time_title"))
                    return cell!
                } else if indexPath.row == TimeRow.endTime.rawValue {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "EventSelectTimeCell") as? EventSelectTimeCell
                    cell?.initViewWithDate(self.realTimeEvent.endDate, title: localizedString(key: "schedule_realtime_end_time_title"))
                    return cell!
                }
            }
            
        case EventSection.color.rawValue:
            if indexPath.row == ColorRow.selectColor.rawValue {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SelectColorCell") as? SelectColorCell
                cell?.initViewWithColor(hexString: self.realTimeEvent.colorLabel)
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
                if indexPath.row == 0 {
                    // hide datePicker to choose start time
                    self.isShowStartTimeDatePicker = false
                    self.tableView.deleteRows(at: [IndexPath.init(row: 1, section: EventSection.time.rawValue)], with: .fade)
                    
                } else if indexPath.row == 2 {
                    // hide startTime dataPickerCell
                    self.isShowStartTimeDatePicker = false
                    self.tableView.deleteRows(at: [IndexPath.init(row: 1, section: EventSection.time.rawValue)], with: .fade)
                    
                    // show datePicker to choose end time
                    self.isShowEndTimeDatePicker = true
                    self.tableView.insertRows(at: [IndexPath.init(row: 2, section: EventSection.time.rawValue)], with: .top)
                }
            } else if isShowEndTimeDatePicker {
                if indexPath.row == 0 {
                    // hide endTime dataPickerCell
                    self.isShowEndTimeDatePicker = false
                    self.tableView.deleteRows(at: [IndexPath.init(row: 2, section: EventSection.time.rawValue)], with: .fade)
                    
                    // show datePicker to choose start time
                    self.isShowStartTimeDatePicker = true
                    self.tableView.insertRows(at: [IndexPath.init(row: 1, section: EventSection.time.rawValue)], with: .middle)
                    
                } else if indexPath.row == 1 {
                    // show datePicker to choose end time
                    self.isShowEndTimeDatePicker = false
                    self.tableView.deleteRows(at: [IndexPath.init(row: 2, section: EventSection.time.rawValue)], with: .fade)
                }
            } else {
                if indexPath.row == TimeRow.startTime.rawValue {
                    // show datePicker to choose start time
                    self.isShowStartTimeDatePicker = true
                    self.tableView.insertRows(at: [IndexPath.init(row: 1, section: EventSection.time.rawValue)], with: .middle)
                    
                } else if indexPath.row == TimeRow.endTime.rawValue {
                    // show datePicker to choose end time
                    self.isShowEndTimeDatePicker = true
                    self.tableView.insertRows(at: [IndexPath.init(row: 2, section: EventSection.time.rawValue)], with: .top)
                }
            }
            
        case EventSection.color.rawValue:
            if indexPath.row == ColorRow.selectColor.rawValue {
                // go to choose color screen
                guard let currentColor = UIColor.init(hexString: self.realTimeEvent.colorLabel) else {
                    dLog(message: "can't convert from hext to UIColor with hex = \(self.realTimeEvent.colorLabel)")
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

extension ScheduleRealTimeEventViewController {
    
    fileprivate func isValidEventData() -> Bool {
        // check presentation info
        if self.realTimeEvent.presentation == "" || self.realTimeEvent.name == "" {
            Utility.showAlertWithErrorMessage(message: localizedString(key: "schedule_event_presentation_empty"), controller: self)
            return false
        }
        
        // check start/end time not empty
        if self.realTimeEvent.startDate == "" {
            Utility.showAlertWithErrorMessage(message: localizedString(key: "schedule_event_start_time_empty"), controller: self)
            return false
        }
        
        if self.realTimeEvent.endDate == "" {
            Utility.showAlertWithErrorMessage(message: localizedString(key: "schedule_event_end_time_empty"), controller: self)
            return false
        }
        
        guard let startDate = self.dateFormatter.date(from: self.realTimeEvent.startDate),
            let endDate = self.dateFormatter.date(from: self.realTimeEvent.endDate) else {
            
            dLog(message: "wrong date format with startDate = \(self.realTimeEvent.startDate) & endDate = \(self.realTimeEvent.endDate)")
            Utility.showAlertWithErrorMessage(message: localizedString(key: "common_error_message"), controller: self)
            return false
        }
        
        // check end time before start time
        if endDate.isEarlier(than: startDate) {
            Utility.showAlertWithErrorMessage(message: localizedString(key: "schedule_event_end_time_before_start_time"), controller: self)
            return false
        }
        
        // check playtime must be >= 30 mins
        let chunk = startDate.chunkBetween(date: endDate)
        if chunk.hours == 0 && chunk.days == 0 && chunk.weeks == 0 && chunk.months == 0 && chunk.years == 0 && chunk.minutes < kScheduleMinDuration {
            Utility.showAlertWithErrorMessage(message: localizedString(key: "schedule_event_duration_too_short"), controller: self)
            return false
        }
        
        // check color
        if self.realTimeEvent.colorLabel == "" {
            Utility.showAlertWithErrorMessage(message: localizedString(key: "schedule_event_color_empty"), controller: self)
            return false
        }
        
        return true
    }
}

// MARK: - Handle Events

extension ScheduleRealTimeEventViewController {
    
    func cancelButtonClicked(barButton: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func doneButtonClicked(barButton: UIBarButtonItem) {
        if !isValidEventData() {
            return
        }
        
        self.navigationController?.dismiss(animated: true, completion: {
            if self.isEditMode {
                self.delegate?.handleEditEvent(self.realTimeEvent)
            } else {
                self.delegate?.handleAddNewEvent(self.realTimeEvent)
            }
        })
    }
}

// MARK: - PresentationListViewControllerDelegate

extension ScheduleRealTimeEventViewController: PresentationListViewControllerDelegate {
    
    func handleAddPresentation(presentation: Presentation) {
        // update with new presentation id
        self.realTimeEvent.presentation = presentation.id
        self.realTimeEvent.name = getPresentationNameById(presentation.id)
        
        self.tableView.reloadRows(at: [IndexPath.init(row: PresentationRow.selectPresentation.rawValue, section: EventSection.presentation.rawValue)],
                                  with: .fade)
    }
}

// MARK: - DatePickerCellDelegate

extension ScheduleRealTimeEventViewController: DatePickerCellDelegate {
    
    func handleDatePickerValueChanged(date: Date) {
        if self.isShowStartTimeDatePicker {
            self.realTimeEvent.startDate = self.dateFormatter.string(from: date)
            self.tableView.reloadRows(at: [IndexPath.init(row: TimeRow.startTime.rawValue, section: EventSection.time.rawValue)],
                                      with: .fade)
        } else if self.isShowEndTimeDatePicker {
            self.realTimeEvent.endDate = self.dateFormatter.string(from: date)
            self.tableView.reloadRows(at: [IndexPath.init(row: TimeRow.endTime.rawValue, section: EventSection.time.rawValue)],
                                      with: .fade)
        }
    }
}

// MARK: - CommonColorPickerViewControllerDelegate

extension ScheduleRealTimeEventViewController: CommonColorPickerViewControllerDelegate {
    
    func handleChangeColor(color: UIColor, type: SelectColorType) {
        self.realTimeEvent.colorLabel = color.toHexString()
        self.tableView.reloadRows(at: [IndexPath.init(row: ColorRow.selectColor.rawValue, section: EventSection.color.rawValue)],
                                  with: .fade)
    }
}

// MARK: - EventSelectPresentationCellDelegate

extension ScheduleRealTimeEventViewController: EventSelectPresentationCellDelegate {
    
    func handleLoadPresentationError(message: String) {
        Utility.showAlertWithErrorMessage(message: message, controller: self)
        
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}
