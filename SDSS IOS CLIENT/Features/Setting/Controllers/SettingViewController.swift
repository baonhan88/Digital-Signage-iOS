//
//  SettingViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 21/04/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

class SettingViewController: BaseTableViewController {

    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var logoutLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = localizedString(key: "setting_title")
        versionLabel.text = localizedString(key: "setting_version_title")
        logoutLabel.text = localizedString(key: "setting_logout_title")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func handleLogout() {
        dLog(message: "logout")
        let alert = UIAlertController(title: localizedString(key: "common_warning"),
                                      message: localizedString(key: "setting_alert_message_confirm"),
                                      preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: localizedString(key: "common_cancel"),
                                      style: UIAlertActionStyle.default,
                                      handler:nil))
        alert.addAction(UIAlertAction(title: localizedString(key: "common_ok"),
                                      style: UIAlertActionStyle.default,
                                      handler:{ _ in
                                        // remove token
                                        UserDefaults.standard.removeObject(forKey: Network.paramToken)
                                        
                                        // go to Login screen
                                        ControllerManager.goToLoginScreen(controller: self)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension SettingViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return 1
            
        case 1:
            return 1
            
        default:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return localizedString(key: "setting_about_header_title")
        case 1:
            return localizedString(key: "setting_cloud_header_title")
        default:
            return localizedString(key: "setting_cloud_header_title")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 && indexPath.row == 0 {
            // handle logout
            handleLogout()
        }
    }
}
