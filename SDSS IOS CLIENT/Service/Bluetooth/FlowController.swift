//
//  FlowController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 21/01/2019.
//  Copyright © 2019 SLab. All rights reserved.
//

import Foundation
import CoreBluetooth

class FlowController {
    
    weak var bluetoothSerivce: BluetoothService? 
    
    init(bluetoothSerivce: BluetoothService) {
        self.bluetoothSerivce = bluetoothSerivce
    }
    
    func bluetoothOn() {
    }
    
    func bluetoothOff() {
    }
    
    func scanStarted() {
    }
    
    func scanStopped() {
    }
    
    func connected(peripheral: CBPeripheral) {
    }
    
    func disconnected(failure: Bool) {
    }
    
    func discoveredPeripheral() {
    }
    
    func readyToWrite() {
    }
    
    func received(response: Data) {
    }
    
    // TODO: add other events if needed
}
