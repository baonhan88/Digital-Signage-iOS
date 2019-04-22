//
//  Macros.swift
//
//  Created by Xavier Muñiz on 6/12/14.

import Foundation


// dLog and aLog macros to abbreviate NSLog.
// Use like this:
//
//   dLog("Log this!")
//
func dLog(message: String, filename: String = #file, function: String = #function, line: Int = #line) {
    #if DEBUG
        NSLog("[\((filename as NSString).lastPathComponent):\(line)] \(function) - \(message)")
    #endif
}

func localizedString(key: String) -> String {
    return NSLocalizedString(key, comment: "")
}

