//
//  RegisterViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 24/04/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import SVProgressHUD

enum RegisterCellType: Int {
    case registerCellTypeUsername = 0
    case registerCellTypeEmail = 1
    case registerCellTypePassword = 2
    case registerCellTypeRegisterButton = 3
}

class RegisterViewController: BaseTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = localizedString(key: "register_title")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - Handleing events

extension RegisterViewController {
    
    @IBAction func handleCancelButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension RegisterViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RegisterCellType.registerCellTypeRegisterButton.rawValue + 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == RegisterCellType.registerCellTypeRegisterButton.rawValue {
            return 60
        }
        return 44
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
            
        case RegisterCellType.registerCellTypeUsername.rawValue:
            var cell = tableView.dequeueReusableCell(withIdentifier: "RegisterInputCell") as? RegisterInputCell
            if cell == nil {
                cell = (Bundle.main.loadNibNamed("RegisterInputCell", owner: self, options: nil)?.first as? RegisterInputCell)!
            }
            cell?.inputLabel.text = localizedString(key: "register_username_title")
            cell?.inputTextField.placeholder = localizedString(key: "register_username_placeholder")
            return cell!
            
        case RegisterCellType.registerCellTypeEmail.rawValue:
            var cell = tableView.dequeueReusableCell(withIdentifier: "RegisterInputCell") as? RegisterInputCell
            if cell == nil {
                cell = (Bundle.main.loadNibNamed("RegisterInputCell", owner: self, options: nil)?.first as? RegisterInputCell)!
            }
            cell?.inputLabel.text = localizedString(key: "register_email_title")
            cell?.inputTextField.placeholder = localizedString(key: "register_email_placeholder")
            return cell!
            
        case RegisterCellType.registerCellTypePassword.rawValue:
            var cell = tableView.dequeueReusableCell(withIdentifier: "RegisterInputCell") as? RegisterInputCell
            if cell == nil {
                cell = (Bundle.main.loadNibNamed("RegisterInputCell", owner: self, options: nil)?.first as? RegisterInputCell)!
            }
            cell?.inputLabel.text = localizedString(key: "register_password_title")
            cell?.inputTextField.placeholder = localizedString(key: "register_password_placeholder")
            cell?.inputTextField.isSecureTextEntry = true
            return cell!
            
        case RegisterCellType.registerCellTypeRegisterButton.rawValue:
            var cell = tableView.dequeueReusableCell(withIdentifier: "RegisterButtonCell") as? RegisterButtonCell
            if cell == nil {
                cell = (Bundle.main.loadNibNamed("RegisterButtonCell", owner: self, options: nil)?.first as? RegisterButtonCell)!
            }
            cell?.delegate = self
            return cell!
            
        default:
            let cell = (Bundle.main.loadNibNamed("RegisterInputCell", owner: self, options: nil)?.first as? RegisterInputCell)!
            return cell
        }
    }
}

// MARK: - RegisterButtonCellDelegate

extension RegisterViewController: RegisterButtonCellDelegate {
    
    func handleRegisterButtonClicked() {
        let usernameCell = tableView.cellForRow(at: IndexPath(row: RegisterCellType.registerCellTypeUsername.rawValue, section: 0)) as? RegisterInputCell
        let emailCell = tableView.cellForRow(at: IndexPath(row: RegisterCellType.registerCellTypeEmail.rawValue, section: 0)) as? RegisterInputCell
        let passwordCell = tableView.cellForRow(at: IndexPath(row: RegisterCellType.registerCellTypePassword.rawValue, section: 0)) as? RegisterInputCell
        
        // show loading
        SVProgressHUD.show()
        
        NetworkManager.shared.register(username: (usernameCell?.inputTextField.text)!,
                                       email: (emailCell?.inputTextField.text)!,
                                       password: (passwordCell?.inputTextField.text)!) {
                                        (success, user, message) in
                                        
                                        // remove loading
                                        SVProgressHUD.dismiss()
                                        
                                        if (success) {
                                            // save user data to userdefault
                                            user?.saveUserDataToUserDefault()
                                            
                                            // go to Dashboard screen
                                            ControllerManager.goToDashboardScreen(controller: self)
                                        } else {
                                            // show error message
                                            Utility.showAlertWithErrorMessage(message: message, controller: self, completion: nil)
                                        }
        }
    }
}
