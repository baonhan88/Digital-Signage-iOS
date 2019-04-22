//
//  DashboardViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 20/04/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit


class DashboardViewController: UIViewController {
    
    @IBOutlet weak var templateView: UIView!
    @IBOutlet weak var templateLabel: UILabel!
    
    @IBOutlet weak var assetView: UIView!
    @IBOutlet weak var assetLabel: UILabel!

    @IBOutlet weak var deviceView: UIView!
    @IBOutlet weak var deviceLabel: UILabel!
    
    @IBOutlet weak var playlistView: UIView!
    @IBOutlet weak var playlistLabel: UILabel!
    
    @IBOutlet weak var scheduleView: UIView!
    @IBOutlet weak var scheduleLabel: UILabel!
    
    @IBOutlet weak var imView: UIView!
    @IBOutlet weak var imLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        templateLabel.text = localizedString(key: "dashboard_template_title")
        assetLabel.text = localizedString(key: "asset_tile")
        deviceLabel.text = localizedString(key: "dashboard_device_title")
        playlistLabel.text = localizedString(key: "dashboard_playlist_title")
        scheduleLabel.text = localizedString(key: "dashboard_schedule_title")
        imLabel.text = localizedString(key: "dashboard_instant_message_title")
        
        initNavigationBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    fileprivate func initNavigationBar() {
        // set title as username
        self.navigationItem.title = UserDefaults.standard.value(forKey: Network.paramDisplayName) as? String
        
        // init setting icon
        let settingImage   = UIImage(named: "icon_setting.png")!
        let settingButton   = UIBarButtonItem(image: settingImage,  style: .plain, target: self, action: #selector(settingButtonClicked(_sender:)))
        
        navigationItem.rightBarButtonItem = settingButton
        
        let sdssIcon = UIBarButtonItem.init(image: UIImage.init(named: "icon_sdss_small"), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = sdssIcon
    }
}

// MARK: - handle rotate
extension DashboardViewController {
    
    override open var shouldAutorotate: Bool {
        return true
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeLeft
    }
}

// MARK: - handle events
extension DashboardViewController {
    
    @IBAction func scheduleButtonClicked(_ sender: UIButton) {
        dLog(message: "clicked")
        
    }
    
    @IBAction func playlistButtonClicked(_ sender: UIButton) {
        dLog(message: "clicked")
        
    }
    
    @IBAction func libraryButtonClicked(_ sender: UIButton) {
        dLog(message: "clicked")
        
    }
    
    @IBAction func imButtonClicked(_ sender: UIButton) {
        dLog(message: "clicked")
        
    }
    
    func settingButtonClicked(_sender: UIBarButtonItem) {
        dLog(message: "clicked")
        self.performSegue(withIdentifier: "settingSegue", sender: nil)
    }

}

