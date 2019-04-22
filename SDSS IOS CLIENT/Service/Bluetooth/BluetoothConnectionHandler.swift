//
//  BluetoothConnectionHandler.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 21/01/2019.
//  Copyright © 2019 SLab. All rights reserved.
//

import Foundation
import CoreBluetooth

extension BluetoothService: CBCentralManagerDelegate {
    
    var expectedNamePrefix: String { return "GoPro" }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != .poweredOn {
            print("bluetooth is OFF (\(central.state.rawValue))")
            self.stopScan()
            self.disconnect()
            self.flowController?.bluetoothOff()
        } else {
            print("bluetooth is ON")
            self.flowController?.bluetoothOn()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
//        guard peripheral.name != nil && peripheral.name?.hasPrefix(self.expectedNamePrefix) ?? false else { return }
        guard peripheral.name != nil else { return }
        print("discovered peripheral: \(peripheral.name!)")
        
        self.peripheral = peripheral
        self.flowController?.discoveredPeripheral()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if let periperalName = peripheral.name {
            print("connected to: \(periperalName)")
        } else {
            print("connected to peripheral")
        }
        
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        self.flowController?.connected(peripheral: peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("peripheral disconnected")
        self.dataCharacteristic = nil
        self.flowController?.disconnected(failure: false)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("failed to connect: \(error.debugDescription)")
        self.dataCharacteristic = nil
        self.flowController?.disconnected(failure: true) 
    }
}
