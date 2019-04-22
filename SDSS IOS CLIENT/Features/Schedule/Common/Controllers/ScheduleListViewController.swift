//
//  ScheduleListViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 21/04/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import SVProgressHUD

class ScheduleListViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var containerView: UIView!
    
    fileprivate lazy var scheduleWeeklyViewController: ScheduleWeeklyViewController = {
        [unowned self] in
        
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "ScheduleWeeklyViewController") as! ScheduleWeeklyViewController
        viewController.delegate = self
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        
        return viewController
        }()
    
    fileprivate lazy var scheduleRealTimeViewController: ScheduleRealTimeViewController = {
        [unowned self] in
        
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "ScheduleRealTimeViewController") as! ScheduleRealTimeViewController
        viewController.delegate = self
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        
        return viewController
        }()
    
    var currentTag: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.segmentedControl.setTitle(localizedString(key: "schedule_segment_weekly_title"), forSegmentAt: 0)
        self.segmentedControl.setTitle(localizedString(key: "schedule_segment_calendar_title"), forSegmentAt: 1)
        
        // init navigation bar
        initNavigationBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func initNavigationBar() {
        self.title = localizedString(key: "schedule_title")
        
//        let addButton = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(handleAddButtonClicked(button:)))
//        navigationItem.rightBarButtonItem = addButton
    }
    
    fileprivate func processAddWeeklySchedule() {
        let alert = UIAlertController(title: localizedString(key: "schedule_weekly_add_alert_title"),
                                      message: localizedString(key: "schedule_weekly_add_alert_message"),
                                      preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            
        }
        
        alert.addAction(UIAlertAction(title: localizedString(key: "common_cancel"),
                                      style: .default,
                                      handler: nil))
        
        alert.addAction(UIAlertAction(title: localizedString(key: "common_ok"),
                                      style: .default,
                                      handler: { [weak alert] (_) in
                                        
                                        weak var weakSelf = self

                                        guard let textField = alert?.textFields![0] else {
                                            return
                                        }
                                        
                                        if !Utility.isValidName(name: textField.text!) {
                                            Utility.showAlertWithErrorMessage(message: localizedString(key: "schedule_weekly_edit_name_invalid"),
                                                                              controller: weakSelf!,
                                                                              completion: nil)
                                            return
                                        }
                                        
                                        // show loading
                                        SVProgressHUD.show()
                                        
                                        NetworkManager.shared.addWeeklySchedule(name: textField.text!, token: Utility.getToken(), completion: {
                                            (success, id, message) in
                                            
                                            weak var weakSelf = self
                                            
                                            // remove loading
                                            SVProgressHUD.dismiss()
                                            
                                            if (success) {
                                                // refresh weekly schedule list
                                                weakSelf?.scheduleWeeklyViewController.handleRefresh()
                                                
                                            } else {
                                                // show error message
                                                Utility.showAlertWithErrorMessage(message: message, controller: self, completion: nil)
                                            }
                                        })
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func processAddRealTimeSchedule() {
        let alert = UIAlertController(title: localizedString(key: "schedule_realtime_add_alert_title"),
                                      message: localizedString(key: "schedule_realtime_add_alert_message"),
                                      preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            
        }
        
        alert.addAction(UIAlertAction(title: localizedString(key: "common_cancel"),
                                      style: .default,
                                      handler: nil))
        
        alert.addAction(UIAlertAction(title: localizedString(key: "common_ok"),
                                      style: .default,
                                      handler: { [weak alert] (_) in
                                        
                                        weak var weakSelf = self
                                        
                                        guard let textField = alert?.textFields![0] else {
                                            return
                                        }
                                        
                                        if !Utility.isValidName(name: textField.text!) {
                                            Utility.showAlertWithErrorMessage(message: localizedString(key: "schedule_realtime_edit_name_invalid"),
                                                                              controller: weakSelf!,
                                                                              completion: nil)
                                            return
                                        }
                                        
                                        // show loading
                                        SVProgressHUD.show()
                                        
                                        NetworkManager.shared.addRealTimeSchedule(name: textField.text!, token: Utility.getToken(), completion: {
                                            (success, id, message) in
                                            
                                            weak var weakSelf = self
                                            
                                            // remove loading
                                            SVProgressHUD.dismiss()
                                            
                                            if (success) {
                                                // refresh realtime schedule list
                                                weakSelf?.scheduleRealTimeViewController.handleRefresh()
                                                
                                            } else {
                                                // show error message
                                                Utility.showAlertWithErrorMessage(message: message, controller: self, completion: nil)
                                            }
                                        })
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func updateView() {
        if segmentedControl.selectedSegmentIndex == 0 { // weekly
            remove(asChildViewController: scheduleRealTimeViewController)
            add(asChildViewController: scheduleWeeklyViewController)
        } else { // realtime
            remove(asChildViewController: scheduleWeeklyViewController)
            add(asChildViewController: scheduleRealTimeViewController)
        }
    }
    
    fileprivate func createPresentationViewController() -> TemplateCollectionViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "TemplateCollectionViewController") as! TemplateCollectionViewController
        viewController.currentTag = self.currentTag
        
        return viewController
    }
    
    fileprivate func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
        addChildViewController(viewController)
        
        // Add Child View as Subview
        containerView.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = containerView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParentViewController: self)
    }
    
    fileprivate func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParentViewController: nil)
        
        // Remove Child View From Superview
        viewController.view.removeFromSuperview()
        
        // Notify Child View Controller
        viewController.removeFromParentViewController()
    }
}

// MARK: - Handle Events

extension ScheduleListViewController {
    
    func handleAddButtonClicked(button: UIBarButtonItem) {
        if segmentedControl.selectedSegmentIndex == 0 { // weekly
            // add weekly schedule
            processAddWeeklySchedule()
        } else { // realtime
            // add realtime schedule
            processAddRealTimeSchedule()
        }
    }
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        updateView()
    }
}

// MARK: - ScheduleRealTimeViewControllerDelegate

extension ScheduleListViewController: ScheduleRealTimeViewControllerDelegate {
    
    func handleGoToRealTimeEditor(realTimeSchedule: RealTimeSchedule) {
        ControllerManager.goToRealTimeDetailScreen(realTimeSchedule: realTimeSchedule, controller: self)
    }
}

// MARK: - ScheduleWeeklyViewControllerDelegate

extension ScheduleListViewController: ScheduleWeeklyViewControllerDelegate {
    
    func handleGoToWeeklyEditor(weeklySchedule: WeeklySchedule) {
        ControllerManager.goToWeeklyDetailScreen(weeklySchedule: weeklySchedule, controller: self)
    }
}
