//
//  BluetoothCommands.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 21/01/2019.
//  Copyright © 2019 SLab. All rights reserved.
//

import Foundation
import CoreBluetooth

extension BluetoothService {
    
    func getSettings() {
        self.peripheral?.readValue(for: self.dataCharacteristic!)
    }
    
    // TODO: add other methods to expose high level requests to peripheral
}
