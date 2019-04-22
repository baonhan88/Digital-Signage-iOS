//
//  LoginViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 21/04/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        usernameTextField.placeholder = localizedString(key: "login_username_placeholder")
        passwordTextField.placeholder = localizedString(key: "login_password_placeholder")
        
        loginButton.setTitle(localizedString(key: "login_button_title"), for: .normal)
        signUpButton.setTitle(localizedString(key: "login_register_button_title"), for: .normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - Handling Events

extension LoginViewController {
    
    @IBAction func loginButtonClicked(_ sender: UIButton) {
        // show loading
        SVProgressHUD.show()
        
        // call login API
        NetworkManager.shared.login(username: usernameTextField.text!,
                                    password: passwordTextField.text!) {
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
    
    @IBAction func signUpButtonClicked(_ sender: UIButton) {
        dLog(message: "clicked")
    }
}
