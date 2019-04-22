//
//  NetInfoHelper.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 28/04/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

struct NetInfoHelper {
    // IP Address
    let ip: String
    
    // Netmask Address
    let netmask: String
    
    // CIDR: Classless Inter-Domain Routing
    var cidr: Int {
        var cidr = 0
        for number in binaryRepresentation(s: netmask) {
            let numberOfOnes = number.components(separatedBy: ("1")).count - 1
            cidr += numberOfOnes
        }
        return cidr
    }
    
    // Network Address
    var network: String {
        return bitwise(op: &, net1: ip, net2: netmask)
    }
    
    // Broadcast Address
    var broadcast: String {
        let inverted_netmask = bitwise(op: ~, net1: netmask)
        let broadcast = bitwise(op: |, net1: network, net2: inverted_netmask)
        return broadcast
    }
    
    fileprivate func binaryRepresentation(s: String) -> [String] {
        var result: [String] = []
        let parts = s.components(separatedBy: ".")
        for numbers in parts {
            if let intNumber = Int(numbers) {
                if let binary = Int(String(intNumber, radix: 2)) {
                    result.append(NSString(format: "%08d", binary) as String)
                }
            }
        }
        return result
    }
    
    fileprivate func bitwise(op: (UInt8,UInt8) -> UInt8, net1: String, net2: String) -> String {
        let net1numbers = toInts(networkString: net1)
        let net2numbers = toInts(networkString: net2)
        var result = ""
        for i in 0..<net1numbers.count {
            result += "\(op(net1numbers[i],net2numbers[i]))"
            if i < (net1numbers.count-1) {
                result += "."
            }
        }
        return result
    }
    
    fileprivate func bitwise(op: (UInt8) -> UInt8, net1: String) -> String {
        let net1numbers = toInts(networkString: net1)
        var result = ""
        for i in 0..<net1numbers.count {
            result += "\(op(net1numbers[i]))"
            if i < (net1numbers.count-1) {
                result += "."
            }
        }
        return result
    }
    
    fileprivate func toInts(networkString: String) -> [UInt8] {
        let parts = networkString.components(separatedBy: ".")
        return parts.map{UInt8(Int($0)!)}
    }
}
