//
//  ScheduleRealTimeDetailViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 03/07/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import WRCalendarView
import SVProgressHUD

class ScheduleRealTimeDetailViewController: UIViewController {
    @IBOutlet weak var weekView: WRWeekView!
    
    // input values
    var realTimeSchedule: RealTimeSchedule?
    
    fileprivate let dateFormatter = DateFormatter()
    
    fileprivate var needUpdatePresentationList: NSMutableArray = NSMutableArray.init()
    fileprivate var currentUploadPresentationIndex = 0
    fileprivate var pinCodeJsonString = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCalendarData()
        
        // init navigation bar
        initNavigationBar()
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        reloadEvents()
    }
    
    fileprivate func initNavigationBar() {
        // init all icons
        let addButton = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(addButtonClicked(barButton:)))
        let saveButton = UIBarButtonItem(image: UIImage(named: "icon_save.png"),  style: .plain, target: self, action: #selector(saveButtonClicked(barButton:)))
        let sendButton = UIBarButtonItem(image: UIImage(named: "icon_send.png"),  style: .plain, target: self, action: #selector(sendButtonClicked(barButton:)))
        let todayButton = UIBarButtonItem(title: localizedString(key: "common_today"), style: .plain, target: self, action: #selector(todayButtonClicked(barButton:)))

        navigationItem.rightBarButtonItems = [todayButton, sendButton, saveButton, addButton]
    }
    
    fileprivate func reloadEvents() {
        if realTimeSchedule?.displayCalendar != nil && (realTimeSchedule?.displayCalendar.count)! > 0 {
            let eventList: [WREvent] = (realTimeSchedule?.displayCalendar.flatMap({ (realTimeEvent) -> WREvent? in
                return createWREventByRealTimeEvent(realTimeEvent)
            }))!
            
            // set events and reload view
            weekView.setEvents(events: eventList)
        }
    }
    
    fileprivate func createWREventByRealTimeEvent(_ realTimeEvent: RealTimeSchedulePresentation) -> WREvent {
        return WREvent.make(id: realTimeEvent.id,
                            startDate: dateFormatter.date(from: realTimeEvent.startDate)!,
                            endDate: dateFormatter.date(from: realTimeEvent.endDate)!,
                            title: realTimeEvent.name,
                            color: realTimeEvent.colorLabel)
    }
    
    fileprivate func setupCalendarData() {
        weekView.setCalendarDate(Date())
        weekView.delegate = self
    }
    
    fileprivate func getRealTimeEventFrom(event: WREvent) -> RealTimeSchedulePresentation? {
        for realTimeEvent in (self.realTimeSchedule?.displayCalendar)! {
            if realTimeEvent.id == event.id {
                return realTimeEvent
            }
        }
        return nil
    }
    
    fileprivate func processDelete(realTimeEvent: RealTimeSchedulePresentation, wrevent: WREvent) {
        // delete realTimeEvent
        var count = 0
        var didDeleteRealTimeEvent = false
        for tmp in (self.realTimeSchedule?.displayCalendar)! {
            if tmp.id == realTimeEvent.id {
                self.realTimeSchedule?.displayCalendar.remove(at: count)
                didDeleteRealTimeEvent = true
                break
            }
            count += 1
        }
        
        // delete WREvent
        let didDeleteEvent = weekView.deleteEvent(event: wrevent)
        if didDeleteRealTimeEvent && didDeleteEvent {
            // show message delete successful
            SVProgressHUD.showSuccess(withStatus: localizedString(key: "common_deleted"))
        } else {
            // show message delete failed
            SVProgressHUD.showError(withStatus: localizedString(key: "common_delete_failed"))
        }
    }
    
    fileprivate func validateEventData(realTimeEvent: RealTimeSchedulePresentation) -> (Bool, String) {
        guard let startDate = self.dateFormatter.date(from: realTimeEvent.startDate),
            let endDate = self.dateFormatter.date(from: realTimeEvent.endDate) else {
                
                return (false, localizedString(key: "common_error_message"))
        }
        
        // check past time
        if endDate.isEarlierThanOrEqual(to: Date()) {
            return (false, localizedString(key: "schedule_realtime_warning_message_past_time"))
        }
        
        // check overlap time
        for tmp in (self.realTimeSchedule?.displayCalendar)! {
            if tmp.id == realTimeEvent.id { // itself
                continue
            }
            
            guard let tmpStartDate = self.dateFormatter.date(from: tmp.startDate),
                let tmpEndDate = self.dateFormatter.date(from: tmp.endDate) else {
                    
                continue
            }
            
            if startDate.isEarlierThanOrEqual(to: tmpStartDate) && endDate.isLaterThanOrEqual(to: tmpEndDate) {
                return (false, localizedString(key: "schedule_realtime_error_message_overlap"))
            }
            if (startDate.isLaterThanOrEqual(to: tmpStartDate) && startDate.isEarlier(than: tmpEndDate)) ||
                endDate.isLaterThanOrEqual(to: tmpStartDate) && endDate.isEarlierThanOrEqual(to: tmpEndDate) {
                
                return (false, localizedString(key: "schedule_realtime_error_message_overlap"))
            }
        }
        
        return (true, "")
    }
    
    fileprivate func hasEventWithDate(_ date: Date) -> Bool {
        let startDate = date.add(1.minutes)
        let endDate = date.add(59.minutes)
        
        for event in (self.realTimeSchedule?.displayCalendar)! {
            guard let tmpStartDate = self.dateFormatter.date(from:event.startDate),
                let tmpEndDate = self.dateFormatter.date(from:event.endDate) else {
                
                continue
            }
            
            if startDate.isEarlierThanOrEqual(to: tmpStartDate) && endDate.isLaterThanOrEqual(to: tmpEndDate) {
                return true
            }
            if (startDate.isLaterThanOrEqual(to: tmpStartDate) && startDate.isEarlierThanOrEqual(to: tmpEndDate)) ||
                endDate.isLaterThanOrEqual(to: tmpStartDate) && endDate.isEarlierThanOrEqual(to: tmpEndDate) {
                
                return true
            }
        }
        
        return false
    }
}

// MARK: - Handle Events

extension ScheduleRealTimeDetailViewController {
    
    func addButtonClicked(barButton: UIBarButtonItem) {
        ControllerManager.showRealTimeEventScreen(controller: self)
    }
    
    func saveButtonClicked(barButton: UIBarButtonItem) {
        // get all presentations exist in local
        for realTimeEvent in (self.realTimeSchedule?.displayCalendar)! {
            if TemplateSlide.isExistPresentation(presentationId: realTimeEvent.presentation) {
                self.needUpdatePresentationList.add(realTimeEvent)
            }
        }
        
        // process upload all presentaion in local to cloud
        SVProgressHUD.show(withStatus: localizedString(key: "common_saving"))
        
        self.currentUploadPresentationIndex = 0
        self.processSaveNewRealTimeSchedule { (success, message) in
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
            
            ControllerManager.goToCloudDeviceListScreen(currentDeviceListType: .realTimeSchedule, controller: self!)
        }
        actionSheetController.addAction(sendToCloudAction)
        
        // Create and add send to local option action
        let sendToLocalAction = UIAlertAction(title: localizedString(key: "common_send_to_local"), style: .default) {
            [weak self] action -> Void in
            
            ControllerManager.goToLocalDeviceListScreen(realTimeSchedule: (self?.realTimeSchedule!)!, controller: self!)
        }
        actionSheetController.addAction(sendToLocalAction)
        
        // Present the actionsheet
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    func todayButtonClicked(barButton: UIBarButtonItem) {
        weekView.setCalendarDate(Date(), animated: true)
    }
}

// MARK: - Handle upload presentation

extension ScheduleRealTimeDetailViewController {
    
    func processSaveNewRealTimeSchedule(completion: @escaping (Bool, String) -> Void) {
        // no need upload any presentation, just update new RealTime Schedule
        if needUpdatePresentationList.count == 0 {
            // process upload RealTime Schedule
            self.processUpdateRealTimeSchedule(completion: { (success, message) in
                completion(success, message)
            })
            return
        }
        
        if currentUploadPresentationIndex < needUpdatePresentationList.count {
            // process upload presentation
            let realTimeSchedulePresentation = self.needUpdatePresentationList[self.currentUploadPresentationIndex] as! RealTimeSchedulePresentation
            
            let uploadHelper = UploadPresentationHelper.init(presentationId: realTimeSchedulePresentation.presentation)
            uploadHelper.delegate = self
            uploadHelper.completionHandler = {
                (success, message) in
                
                weak var weakSelf = self
                
                if success {
                    // upload next presentation
                    weakSelf?.currentUploadPresentationIndex += 1
                    weakSelf?.processSaveNewRealTimeSchedule(completion: completion)
                } else {
                    completion(false, message)
                }
            }
            uploadHelper.processUploadPresentation()
        } else {
            // process update RealTime Schedule
            self.processUpdateRealTimeSchedule(completion: { (success, message) in
                completion(success, message)
            })
        }
    }
    
    func processUpdateRealTimeSchedule(completion: @escaping (Bool, String) -> Void) {
        NetworkManager.shared.updateRealTimeSchedule(id: (self.realTimeSchedule?.id)!, code: nil, name: nil, shortDescription: nil, displayCalendar: self.realTimeSchedule?.displayCalendar.toJsonString(), group: nil, token: Utility.getToken()) {
            (success, message) in
            
            completion(success, message)
        }
    }
}

// MARK: - Handle send RealTimeSchedule to Cloud

extension ScheduleRealTimeDetailViewController {
    
    func processSendRealTimeScheduleToCloud() {
        // process save realTimeSchedule
        // get all presentations exist in local
        for realTimeEvent in (self.realTimeSchedule?.displayCalendar)! {
            if TemplateSlide.isExistPresentation(presentationId: realTimeEvent.presentation) {
                self.needUpdatePresentationList.add(realTimeEvent)
            }
        }
        
        // process upload all presentaions in local to cloud
        SVProgressHUD.show(withStatus: localizedString(key: "common_sending"))
        
        self.currentUploadPresentationIndex = 0
        self.processSaveNewRealTimeSchedule { (success, message) in
            
            weak var weakSelf = self
            
            if success {
                // call API control to play with type = REALTIME_SCHEDULE
                weakSelf?.processCallAPItoPlayRealTimeSchedule()
            } else {
                Utility.showAlertWithErrorMessage(message: message, controller: weakSelf!)
            }
        }
    }
    

    fileprivate func processCallAPItoPlayRealTimeSchedule() {
        NetworkManager.shared.controlDeviceToPlay(pinCodeList: self.pinCodeJsonString, contentId: (self.realTimeSchedule?.id)!, contentType: ContentType.realtimeSchedule.name(), contentName: (self.realTimeSchedule?.name)!, contentData: nil, token: Utility.getToken()) {
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

extension ScheduleRealTimeDetailViewController: UploadPresentationHelperDelegate {
    
    func handleAfterUpdatePresentationId(witOldPresentationId oldPresentationId: String, andNewPresentationId newPresentationId: String) {
        for realTimeEvent in (self.realTimeSchedule?.displayCalendar)! {
            if realTimeEvent.presentation == oldPresentationId {
                realTimeEvent.presentation = newPresentationId
                realTimeEvent.code = newPresentationId
            }
        }
    }
}

// MARK: - WRWeekViewDelegate

extension ScheduleRealTimeDetailViewController: WRWeekViewDelegate {
    
    func view(startDate: Date, interval: Int) {
        dLog(message: "startDate = \(startDate), interval = \(interval)")
    }
    
    func tap(date: Date) {
        // if has event -> process select on event
//        if hasEventWithDate(date) {
//            return
//        }
//        
//        // if select on past -> show warning message
//        if date.add(kScheduleHourGripDivisionValue.minutes).isEarlier(than: Date()) {
//            Utility.showAlertWithErrorMessage(message: localizedString(key: "schedule_realtime_warning_message_past_time"), controller: self)
//            return
//        }
//        
//        ControllerManager.showRealTimeEventScreen(startTime: date, endTime: date.add(kScheduleHourGripDivisionValue.minutes), controller: self)
    }
    
    func selectEvent(_ event: WREvent) {
//        guard let realTimeEvent = getRealTimeEventFrom(event: event) else {
//            Utility.showAlertWithErrorMessage(message: localizedString(key: "common_error_message"), controller: self)
//            dLog(message: "can't get RealTimeEvent from WREvent with id = \(event.id)")
//            return
//        }
//        
//        // show ActionSheet to choose Delete or Update action
//        let actionSheetController = UIAlertController(title: localizedString(key: "schedule_realtime_actionsheet_title"),
//                                                      message: localizedString(key: "schedule_realtime_actionsheet_message"),
//                                                      preferredStyle: .actionSheet)
//        
//        // Create and add the Cancel action
//        let cancelAction = UIAlertAction(title: localizedString(key: "common_cancel"), style: .cancel) { action -> Void in
//            // Just dismiss the action sheet
//        }
//        actionSheetController.addAction(cancelAction)
//        
//        // Create and add update event action
//        let takePhotoAction = UIAlertAction(title: localizedString(key: "schedule_realtime_actionsheet_update_action"), style: .default) { action -> Void in
//            ControllerManager.showRealTimeEventScreen(realTimeEvent: realTimeEvent, controller: self)
//        }
//        actionSheetController.addAction(takePhotoAction)
//        
//        // Create and add delete event action
//        let cameraRollAction = UIAlertAction(title: localizedString(key: "schedule_realtime_actionsheet_delete_action"), style: .default) { action -> Void in
//            weak var weakSelf = self
//            
//            weakSelf?.processDelete(realTimeEvent: realTimeEvent, wrevent: event)
//        }
//        actionSheetController.addAction(cameraRollAction)
//        
//        // Present the actionsheet
//        self.present(actionSheetController, animated: true, completion: nil)
    }
}

// MARK: - ScheduleRealTimeEventViewControllerDelegate

extension ScheduleRealTimeDetailViewController: ScheduleRealTimeEventViewControllerDelegate {
    
    func handleAddNewEvent(_ realTimeEvent: RealTimeSchedulePresentation) {
        // validate data
        let (success, message) = validateEventData(realTimeEvent: realTimeEvent)
        if !success {
            Utility.showAlertWithErrorMessage(message: message, controller: self)
            return
        }
        
        // add new event and reload schedule
        self.realTimeSchedule?.displayCalendar.append(realTimeEvent)
        reloadEvents()
    }
    
    func handleEditEvent(_ realTimeEvent: RealTimeSchedulePresentation) {
        // validate data
        let (success, message) = validateEventData(realTimeEvent: realTimeEvent)
        if !success {
            Utility.showAlertWithErrorMessage(message: message, controller: self)
            return
        }
        
        // update event and reload schedule
        var count = 0
        for tmp in (self.realTimeSchedule?.displayCalendar)! {
            if tmp.id == realTimeEvent.id {
                self.realTimeSchedule?.displayCalendar.remove(at: count)
                self.realTimeSchedule?.displayCalendar.append(realTimeEvent)
                
                reloadEvents()
                
                return
            }
            count += 1
        }
    }
}

// MARK: - CloudDeviceListViewControllerDelegate

extension ScheduleRealTimeDetailViewController: CloudDeviceListViewControllerDelegate {
    
    func handleSendRealTimeSchedule(pinCodeJsonString: String) {
        self.pinCodeJsonString = pinCodeJsonString
        processSendRealTimeScheduleToCloud()
    }
}

