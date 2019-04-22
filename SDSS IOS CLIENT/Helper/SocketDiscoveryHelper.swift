//
//  SocketDiscoveryHelper.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 27/04/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

protocol SocketDiscoveryHelperDelegate {
    func didReceiveResponseFromDevice(localDevice: Device)
}

class SocketDiscoveryHelper : NSObject {
    
    static let shared = SocketDiscoveryHelper()

    var address = "192.168.0.255"
    var socket:GCDAsyncUdpSocket!
    var socketReceive:GCDAsyncUdpSocket!
    var error : NSError?
    
    var delegate: SocketDiscoveryHelperDelegate?
    
    private override init() {}
    
    func sendBroadcastSocket() {
        let deviceType = Socket.deviceType.base64Encoded()
        let packageType = Socket.packageType.base64Encoded()
        
        let dataString = Socket.socketPrefix + Socket.socketSeparator + deviceType! + Socket.socketSeparator + packageType!
        let message = dataString.data(using: String.Encoding.utf8)
        
        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        
        socket.send(message!,
                    toHost: address,
                    port: UInt16(Socket.port),
                    withTimeout: TimeInterval(Socket.timeout),
                    tag: 0)
        
        do {
            try socket.bind(toPort: UInt16(Socket.port))
        } catch {
            print(error)
        }
        
        do {
            try socket.enableBroadcast(true)
        } catch {
            print(error)
        }
        
        do {
            try socket.beginReceiving()
        } catch {
            print(error)
        }
    }
}

// MARK: - GCDAsyncUdpSocketDelegate

// handle all socket events
extension SocketDiscoveryHelper: GCDAsyncUdpSocketDelegate {
    func udpSocket(_ sock: GCDAsyncUdpSocket, didConnectToAddress address: Data) {
        dLog(message: "didConnectToAddress")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotConnect error: Error?) {
        dLog(message: "didNotConnect \(String(describing: error))")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
        dLog(message: "didSendDataWithTag")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotSendDataWithTag tag: Int, dueToError error: Error?) {
        dLog(message: "didNotSendDataWithTag")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
//        dLog(message: "didReceiveData")
        
        var host: NSString?
        var port1: UInt16 = 0
        GCDAsyncUdpSocket.getHost(&host, port: &port1, fromAddress: address)
//        print("From \(host!)")
        
        let gotData: NSString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
        print(gotData)
        let device = parseResponseData(data: gotData as String, host: host! as String)
        if device != nil {
            delegate?.didReceiveResponseFromDevice(localDevice: device!)
        }
    }
    
    func parseResponseData(data: String?, host: String) -> Device? {
        if data != nil && (data?.hasPrefix(Socket.socketPrefix))! {
            let parts = data?.components(separatedBy: Socket.socketSeparator)
            if parts?.count == 7 {
                let device = Device()
                device.ipAddress = host
                device.name = (parts?[1])!
                device.pinCode = (parts?[2])!
                device.softwareVersion = (parts?[3])!
                device.displayWidth = Int((parts?[4])!)!
                device.displayHeight = Int((parts?[5])!)!
                
                let liveStatus = Int((parts?[6])!)
                if liveStatus == 0 {
                    device.liveStatus = "OFFLINE"
                } else {
                    device.liveStatus = "ONLINE"
                }
                return device
            }
        }
        
        return nil
    }
}
