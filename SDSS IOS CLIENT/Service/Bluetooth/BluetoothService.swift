//
//  BluetoothService.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 21/01/2019.
//  Copyright © 2019 SLab. All rights reserved.
//

import UIKit
import CoreBluetooth

class BluetoothService: NSObject {
    
    let dataServiceUuid = "180A"
    let dataCharacteristicUuid = "2A29"
    
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral?
    var dataCharacteristic: CBCharacteristic?
    var bluetoothState: CBManagerState {
        return self.centralManager.state
    }
    var flowController: FlowController?
    
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScan() {
        self.peripheral = nil
        guard self.centralManager.state == .poweredOn else { return }
        
        self.centralManager.scanForPeripherals(withServices: [])
        self.flowController?.scanStarted()
        print("scan started")
    }
    
    func stopScan() {
        self.centralManager.stopScan()
        self.flowController?.scanStopped() 
        print("scan stopped\n")
    }
    
    func connect() {
        guard self.centralManager.state == .poweredOn else { return }
        guard let peripheral = self.peripheral else { return }
        self.centralManager.connect(peripheral)
    }
    
    func disconnect() {
        guard let peripheral = self.peripheral else { return }
        self.centralManager.cancelPeripheralConnection(peripheral)
    }
}
