//
//  ScheduleWeeklyDetailViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 03/07/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

import UIKit
import WRCalendarView
import SVProgressHUD

class ScheduleWeeklyDetailViewController: UIViewController {
    @IBOutlet weak var weekView: WRWeekView!
    
    // input values
    var weeklySchedule: WeeklySchedule?
    
    fileprivate let dateFormatter = DateFormatter()
    
    fileprivate var needUpdatePresentationList: NSMutableArray = NSMutableArray.init()
    fileprivate var currentUploadPresentationIndex = 0
    fileprivate var pinCodeJsonString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCalendarData()
        
        // init navigation bar
        initNavigationBar()
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        reloadEvents()
    }
    
    fileprivate func initNavigationBar() {
        // init all icons
        let addButton = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(addButtonClicked(barButton:)))
        let saveButton = UIBarButtonItem(image: UIImage(named: "icon_save.png"),  style: .plain, target: self, action: #selector(saveButtonClicked(barButton:)))
        let sendButton = UIBarButtonItem(image: UIImage(named: "icon_send.png"),  style: .plain, target: self, action: #selector(sendButtonClicked(barButton:)))
        
        navigationItem.rightBarButtonItems = [sendButton, saveButton, addButton]
    }
    
    fileprivate func reloadEvents() {
        if weeklySchedule?.displaySchedule != nil && (weeklySchedule?.displaySchedule.count)! > 0 {
            let eventList: [WREvent] = (weeklySchedule?.displaySchedule.flatMap({ (weeklyEvent) -> WREvent? in
                return createWREventByWeeklyEvent(weeklyEvent)
            }))!
            
            // set events and reload view
            weekView.setEvents(events: eventList)
        }
    }
    
    fileprivate func createWREventByWeeklyEvent(_ weeklyEvent: WeeklySchedulePresentation) -> WREvent? {
        return WREvent.make(id: weeklyEvent.id,
                            startDay: weeklyEvent.startDay,
                            duration: weeklyEvent.duration,
                            startTime: weeklyEvent.startTime,
                            title: weeklyEvent.name,
                            color: weeklyEvent.colorLabel)
    }
    
    fileprivate func setupCalendarData() {
        weekView.setCalendarDate(Date())
        weekView.delegate = self
        weekView.calendarType = .weekly
    }
    
    fileprivate func getWeeklyEventFrom(event: WREvent) -> WeeklySchedulePresentation? {
        for weeklyEvent in (self.weeklySchedule?.displaySchedule)! {
            if weeklyEvent.id == event.id {
                return weeklyEvent
            }
        }
        return nil
    }
    
    fileprivate func processDelete(weeklyEvent: WeeklySchedulePresentation, wrevent: WREvent) {
        // delete weeklyEvent
        var count = 0
        var didDeleteWeeklyEvent = false
        for tmp in (self.weeklySchedule?.displaySchedule)! {
            if tmp.id == weeklyEvent.id {
                self.weeklySchedule?.displaySchedule.remove(at: count)
                didDeleteWeeklyEvent = true
                break
            }
            count += 1
        }
        
        // delete WREvent
        let didDeleteEvent = weekView.deleteEvent(event: wrevent)
        if didDeleteWeeklyEvent && didDeleteEvent {
            // show message delete successful
            SVProgressHUD.showSuccess(withStatus: localizedString(key: "common_deleted"))
        } else {
            // show message delete failed
            SVProgressHUD.showError(withStatus: localizedString(key: "common_delete_failed"))
        }
    }
    
    fileprivate func validateEventData(weeklyEvent: WeeklySchedulePresentation) -> (Bool, String) {
        // check overlap time
        for tmp in (self.weeklySchedule?.displaySchedule)! {
            if tmp.id == weeklyEvent.id { // itself
                continue
            }
            
            if (weeklyEvent.startDay == tmp.startDay) {
                // current event's startTime between tmp's playTime
                if (weeklyEvent.startTime >= tmp.startTime) && (weeklyEvent.startTime < (tmp.startTime + tmp.duration)) {
                    return (false, localizedString(key: "schedule_weekly_error_message_overlap"))
                }
                
                // current event's startTime before tmp's startTime && tmp's startTime between current event's playtime
                if (weeklyEvent.startTime <= tmp.startTime) && (tmp.startTime < (weeklyEvent.startTime + weeklyEvent.duration)) {
                    return (false, localizedString(key: "schedule_weekly_error_message_overlap"))
                }
            }
        }
        
        return (true, "")
    }
    
    fileprivate func hasEventWithDate(_ date: Date) -> Bool {
        for event in (self.weeklySchedule?.displaySchedule)! {
            let components = Calendar.current.dateComponents([.weekday, .hour, .minute], from: date)
            let weekString = Utility.getWeekdayString(by: components.weekday!)
            let minuteInterval = components.hour!*60 + components.minute!
            
            if event.startDay == weekString && minuteInterval >= event.startTime && minuteInterval < (event.startTime + event.duration)  {
                return true
            }
        }
        
        return false
    }
}

// MARK: - Handle Events

extension ScheduleWeeklyDetailViewController {
    
    func addButtonClicked(barButton: UIBarButtonItem) {
        ControllerManager.showWeeklyEventScreen(controller: self)
    }
    
    func saveButtonClicked(barButton: UIBarButtonItem) {
        // get all presentations exist in local
        for weeklyEvent in (self.weeklySchedule?.displaySchedule)! {
            if TemplateSlide.isExistPresentation(presentationId: weeklyEvent.presentation) {
                self.needUpdatePresentationList.add(weeklyEvent)
            }
        }
        
        // process upload all presentaion in local to cloud
        SVProgressHUD.show(withStatus: localizedString(key: "common_saving"))
        
        self.currentUploadPresentationIndex = 0
        self.processSaveNewWeeklySchedule { (success, message) in
            weak var weakSelf = self
            
            SVProgressHUD.dismiss()
            
            if success {
                SVProgressHUD.showSuccess(withStatus: localizedString(key: "common_saved"))
                weakSelf?.reloadEvents()
            } else {
                Utility.showAlertWithErrorMessage(message: message, controller: weakSelf!)
            }
        }
    }
    
    func sendButtonClicked(barButton: UIBarButtonItem) {
        // show actionsheet to choose video type
        let actionSheetController = UIAlertController(title: localizedString(key: "common_send_alert_title"),
                                                      message: localizedString(key: "common_send_alert_message"),
                                                      preferredStyle: .actionSheet)
        
        // Create and add the Cancel action
        let cancelAction = UIAlertAction(title: localizedString(key: "common_cancel"), style: .cancel) { action -> Void in
            // Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        
        // Create and add send to cloud option action
        let sendToCloudAction = UIAlertAction(title: localizedString(key: "common_send_to_cloud"), style: .default) {
            [weak self] action -> Void in
            
            ControllerManager.goToCloudDeviceListScreen(currentDeviceListType: .weeklySchedule, controller: self!)
        }
        actionSheetController.addAction(sendToCloudAction)
        
        // Create and add send to local option action
        let sendToLocalAction = UIAlertAction(title: localizedString(key: "common_send_to_local"), style: .default) {
            [weak self] action -> Void in
            
            ControllerManager.goToLocalDeviceListScreen(weeklySchedule: (self?.weeklySchedule!)!, controller: self!)
        }
        actionSheetController.addAction(sendToLocalAction)
        
        // Present the actionsheet
        self.present(actionSheetController, animated: true, completion: nil)
    }
}

// MARK: - Handle upload presentation

extension ScheduleWeeklyDetailViewController {
    
    func processSaveNewWeeklySchedule(completion: @escaping (Bool, String) -> Void) {
        // no need upload any presentation, just update new Weekly Schedule
        if needUpdatePresentationList.count == 0 {
            // process upload Weekly Schedule
            self.processUpdateWeeklySchedule(completion: { (success, message) in
                completion(success, message)
            })
            return
        }
        
        if currentUploadPresentationIndex < needUpdatePresentationList.count {
            // process upload presentation
            let weeklySchedulePresentation = self.needUpdatePresentationList[self.currentUploadPresentationIndex] as! WeeklySchedulePresentation
            
            let uploadHelper = UploadPresentationHelper.init(presentationId: weeklySchedulePresentation.presentation)
            uploadHelper.delegate = self
            uploadHelper.completionHandler = {
                (success, message) in
                
                weak var weakSelf = self
                
                if success {
                    // upload next presentation
                    weakSelf?.currentUploadPresentationIndex += 1
                    weakSelf?.processSaveNewWeeklySchedule(completion: completion)
                } else {
                    completion(false, message)
                }
            }
            uploadHelper.processUploadPresentation()
        } else {
            // process update Weekly Schedule
            self.processUpdateWeeklySchedule(completion: { (success, message) in
                completion(success, message)
            })
        }
    }
    
    fileprivate func processUpdateWeeklySchedule(completion: @escaping (Bool, String) -> Void) {
        NetworkManager.shared.updateWeeklySchedule(id: (self.weeklySchedule?.id)!, code: nil, name: nil, shortDescription: nil, displaySchedule: self.weeklySchedule?.displaySchedule.toJsonString(), group: nil, token: Utility.getToken()) {
            (success, message) in
            
            completion(success, message)
        }
    }
}

// Handle send weekly schedule to Cloud

extension ScheduleWeeklyDetailViewController {
    
    func processSendWeeklyScheduleToCloud() {
        // process save weeklySchedule
        // get all presentations exist in local
        for weeklyEvent in (self.weeklySchedule?.displaySchedule)! {
            if TemplateSlide.isExistPresentation(presentationId: weeklyEvent.presentation) {
                self.needUpdatePresentationList.add(weeklyEvent)
            }
        }
        
        // process upload all presentaions in local to cloud
        SVProgressHUD.show(withStatus: localizedString(key: "common_sending"))
        
        self.currentUploadPresentationIndex = 0
        self.processSaveNewWeeklySchedule { (success, message) in
            
            weak var weakSelf = self
            
            if success {
                // call API control to play with type = WEEKLY_SCHEDULE
                weakSelf?.processCallAPItoPlayWeeklySchedule()
            } else {
                Utility.showAlertWithErrorMessage(message: message, controller: weakSelf!)
            }
        }
    }
    
    fileprivate func processCallAPItoPlayWeeklySchedule() {
        NetworkManager.shared.controlDeviceToPlay(pinCodeList: self.pinCodeJsonString, contentId: (self.weeklySchedule?.id)!, contentType: ContentType.weeklySchedule.name(), contentName: (self.weeklySchedule?.name)!, contentData: nil, token: Utility.getToken()) {
            (success, message) in
            
            weak var weakSelf = self
            
            SVProgressHUD.dismiss()
            
            if success {
                SVProgressHUD.showSuccess(withStatus: localizedString(key: "common_sent"))
            } else {
                Utility.showAlertWithErrorMessage(message: message, controller: weakSelf!)
            }
        }
    }
}

// MAKR: - UploadHelperDelegate

extension ScheduleWeeklyDetailViewController: UploadPresentationHelperDelegate {
    
    func handleAfterUpdatePresentationId(witOldPresentationId oldPresentationId: String, andNewPresentationId newPresentationId: String) {
        for weeklyEvent in (self.weeklySchedule?.displaySchedule)! {
            if weeklyEvent.presentation == oldPresentationId {
                weeklyEvent.presentation = newPresentationId
                weeklyEvent.code = newPresentationId
            }
        }
    }
}

// MARK: - WRWeekViewDelegate

extension ScheduleWeeklyDetailViewController: WRWeekViewDelegate {
    
    func view(startDate: Date, interval: Int) {
        dLog(message: "startDate = \(startDate), interval = \(interval)")
    }
    
    func tap(date: Date) {
//        if hasEventWithDate(date) {
//            return
//        }
//        
//        ControllerManager.showWeeklyEventScreen(startTime: date, endTime: date.add(kScheduleHourGripDivisionValue.minutes), controller: self)
    }
    
    func selectEvent(_ event: WREvent) {
//        guard let weeklyEvent = getWeeklyEventFrom(event: event) else {
//            Utility.showAlertWithErrorMessage(message: localizedString(key: "common_error_message"), controller: self)
//            dLog(message: "can't get WeeklyEvent from WREvent with id = \(event.id)")
//            return
//        }
//        
//        // show ActionSheet to choose Delete or Update action
//        let actionSheetController = UIAlertController(title: localizedString(key: "schedule_weekly_actionsheet_title"),
//                                                      message: localizedString(key: "schedule_weekly_actionsheet_message"),
//                                                      preferredStyle: .actionSheet)
//        
//        // Create and add the Cancel action
//        let cancelAction = UIAlertAction(title: localizedString(key: "common_cancel"), style: .cancel) { action -> Void in
//            // Just dismiss the action sheet
//        }
//        actionSheetController.addAction(cancelAction)
//        
//        // Create and add update event action
//        let takePhotoAction = UIAlertAction(title: localizedString(key: "schedule_weekly_actionsheet_update_action"), style: .default) { action -> Void in
//            ControllerManager.showWeeklyEventScreen(weeklyEvent: weeklyEvent, controller: self)
//        }
//        actionSheetController.addAction(takePhotoAction)
//        
//        // Create and add delete event action
//        let cameraRollAction = UIAlertAction(title: localizedString(key: "schedule_weekly_actionsheet_delete_action"), style: .default) { action -> Void in
//            weak var weakSelf = self
//            
//            weakSelf?.processDelete(weeklyEvent: weeklyEvent, wrevent: event)
//        }
//        actionSheetController.addAction(cameraRollAction)
//        
//        // Present the actionsheet
//        self.present(actionSheetController, animated: true, completion: nil)
    }
}

// MARK: - ScheduleWeeklyEventViewControllerDelegate

extension ScheduleWeeklyDetailViewController: ScheduleWeeklyEventViewControllerDelegate {
    
    func handleAddNewEvent(_ weeklyEvent: WeeklySchedulePresentation) {
        // validate data
        let (success, message) = validateEventData(weeklyEvent: weeklyEvent)
        if !success {
            Utility.showAlertWithErrorMessage(message: message, controller: self)
            return
        }
        
        // add new event and reload schedule
        self.weeklySchedule?.displaySchedule.append(weeklyEvent)
        reloadEvents()
    }
    
    func handleEditEvent(_ weeklyEvent: WeeklySchedulePresentation) {
        // validate data
        let (success, message) = validateEventData(weeklyEvent: weeklyEvent)
        if !success {
            Utility.showAlertWithErrorMessage(message: message, controller: self)
            return
        }
        
        // update event and reload schedule
        var count = 0
        for tmp in (self.weeklySchedule?.displaySchedule)! {
            if tmp.id == weeklyEvent.id {
                self.weeklySchedule?.displaySchedule.remove(at: count)
                self.weeklySchedule?.displaySchedule.append(weeklyEvent)
                
                reloadEvents()
                
                return
            }
            count += 1
        }
    }
}

// MARK: - CloudDeviceListViewControllerDelegate

extension ScheduleWeeklyDetailViewController: CloudDeviceListViewControllerDelegate {
    
    func handleSendWeeklySchedule(pinCodeJsonString: String) {
        self.pinCodeJsonString = pinCodeJsonString
        processSendWeeklyScheduleToCloud()
    }
}

