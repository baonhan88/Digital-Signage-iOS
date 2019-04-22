//
//  DeviceWifiSettingViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 21/01/2019.
//  Copyright © 2019 SLab. All rights reserved.
//

import UIKit

class DeviceWifiSettingViewController: UIViewController {
    
    @IBOutlet weak var ssidLabel: UILabel!
    @IBOutlet weak var passLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var ssidTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    
    @IBOutlet weak var connectButton: UIButton!
    
    var qrCodeString = ""
    
    let bluetoothService = BluetoothService()
    var pairingFlow: PairingFlow?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        ssidLabel.text = localizedString(key: "device_wifi_setting_ssid")
        passLabel.text = localizedString(key: "device_wifi_setting_pass")
        
        ssidTextField.placeholder = localizedString(key: "device_wifi_setting_ssid_place_holder")
        passTextField.placeholder = localizedString(key: "device_wifi_setting_pass_place_holder")
        
        connectButton.setTitle(localizedString(key: "device_wifi_setting_connect_button_title"), for: UIControlState.normal)
        
        self.bluetoothService.flowController = self.pairingFlow
        self.pairingFlow = PairingFlow(bluetoothSerivce: self.bluetoothService)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.checkBluetoothState()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func initNavigationBar() {
        self.title = localizedString(key: "device_wifi_setting_title")
    }
    
    private func checkBluetoothState() {
        self.statusLabel.text = "Status: bluetooth is \(bluetoothService.bluetoothState == .poweredOn ? "ON" : "OFF")"
        
        if self.bluetoothService.bluetoothState != .poweredOn {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { self.checkBluetoothState() }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func connectButtonClicked(_ sender: UIButton) {
        guard self.bluetoothService.bluetoothState == .poweredOn else { return }
        
        self.statusLabel.text = "Status: waiting for peripheral..."
        self.pairingFlow?.waitForPeripheral { // start flow
            
            self.statusLabel.text = "Status: connecting..."
            self.pairingFlow?.pair { result in // continue with next step
                self.statusLabel.text = "Status: pairing \(result ? "successful" : "failed")"
            }
        }
    }
}
