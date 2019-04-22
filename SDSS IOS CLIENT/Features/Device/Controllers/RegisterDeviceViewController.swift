//
//  RegisterDeviceViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 04/05/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import SVProgressHUD

class RegisterDeviceViewController: UIViewController {
    
    @IBOutlet weak var inputPinCodeLabel: UILabel!
    
    @IBOutlet weak var inputTextField1: UITextField!
    @IBOutlet weak var inputTextField2: UITextField!
    @IBOutlet weak var inputTextField3: UITextField!
    @IBOutlet weak var inputTextField4: UITextField!
    @IBOutlet weak var inputTextField5: UITextField!
    @IBOutlet weak var inputTextField6: UITextField!
    @IBOutlet weak var inputTextField7: UITextField!
    @IBOutlet weak var inputTextField8: UITextField!
    
    fileprivate let maxTextFieldMaxLength = 4
    fileprivate let defaultPinCodeString = "[A-Z0-9]{4}"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = localizedString(key: "device_register_title")
        
        inputPinCodeLabel.text = localizedString(key: "device_register_input_pin_code")
        
        initView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func initView() {
        // disable all textFields
        inputTextField1.isEnabled = false
        inputTextField2.isEnabled = false
        inputTextField3.isEnabled = false
        inputTextField4.isEnabled = false
        inputTextField5.isEnabled = false
        inputTextField6.isEnabled = false
        inputTextField7.isEnabled = false
        inputTextField8.isEnabled = false

        // random 2 of 8 textField -> enable it -> reset text to ""
        var needFindMore = true
        var firstNumber = 0
        
        while needFindMore {
            let random = Int(arc4random_uniform(8) + 1)
            if firstNumber == 0 {
                firstNumber = random
                
                // enable first textField
                enableTextField(index: firstNumber)
            } else {
                if firstNumber != random {
                    // enable second textField
                    enableTextField(index: random)
                    
                    // stop find more
                    needFindMore = false
                }
            }
        }
    }
    
    fileprivate func enableTextField(index: Int) {
        let textField = getTextField(byIndex: index) 
        textField.isEnabled = true
        textField.text = ""
    }
    
    fileprivate func getTextField(byIndex: Int) -> UITextField {
        switch byIndex {
        case 1:
            return inputTextField1
            
        case 2:
            return inputTextField2
            
        case 3:
            return inputTextField3
            
        case 4:
            return inputTextField4
            
        case 5:
            return inputTextField5
            
        case 6:
            return inputTextField6
            
        case 7:
            return inputTextField7
            
        case 8:
            return inputTextField8
            
        default:
            return inputTextField1
        }
    }
    
    fileprivate func generatePinCode() -> String {
        var pinCode = ""
        
        var count = 1
        while count <= 8 {
            let textField = getTextField(byIndex: count)
            
            var splitString = ""
            if count != 8 {
                splitString = "-"
            }
            
            if textField.isEnabled {
                pinCode.append((textField.text?.uppercased())! + splitString)
            } else {
                pinCode.append(defaultPinCodeString + splitString)
            }
            
            count += 1
        }
        
        return pinCode
    }
    
    @IBAction func cancelButtonClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true) { 
            
        }
    }
    
    @IBAction func doneButtonClicked(_ sender: UIBarButtonItem) {
        let pinCode = generatePinCode()
        dLog(message: "pinCode = " + pinCode)
        guard pinCode != "" else {
            // show error message
            Utility.showAlertWithErrorMessage(message: localizedString(key: "common_error_message"), controller: self, completion: nil)
            return
        }
        
        // show loading
        SVProgressHUD.show()
        
        NetworkManager.shared.activateDevice(pinCode: pinCode,
                                             token: Utility.getToken()) {
            (success, message) in
            
            weak var weakSelf = self
            
            // remove loading
            SVProgressHUD.dismiss()
            
            if (success) {
                weakSelf?.dismiss(animated: true, completion: nil)
                
            } else {
                // show error message
                Utility.showAlertWithErrorMessage(message: message, controller: self, completion: nil)
            }
                                                
        }
    }

}

// MARK: - UITextFieldDelegate

extension RegisterDeviceViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= maxTextFieldMaxLength // Bool
    }
}
