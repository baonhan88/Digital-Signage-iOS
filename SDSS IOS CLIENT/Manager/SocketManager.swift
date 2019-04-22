//
//  SocketManager.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 20/06/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class SocketManager {
    static let shared: SocketManager = {
        let instance = SocketManager()
        return instance
    }()
    
    let socket: GCDAsyncUdpSocket

    // Initialization
    init() {
        self.socket = GCDAsyncUdpSocket.init(delegate: nil, delegateQueue: DispatchQueue.main)
    }
}

