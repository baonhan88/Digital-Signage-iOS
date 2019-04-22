//
//  Data+Extension.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 07/06/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

extension Data {
    var hexDescription: String {
        return reduce("") {$0 + String(format: "%02x", $1)}
    }
    
    static func md5File(url: URL) -> Data? {
        
        let bufferSize = 1024 * 1024
        
        do {
            // Open file for reading:
            let file = try FileHandle(forReadingFrom: url)
            defer {
                file.closeFile()
            }
            
            // Create and initialize MD5 context:
            var context = CC_MD5_CTX()
            CC_MD5_Init(&context)
            
            // Read up to `bufferSize` bytes, until EOF is reached, and update MD5 context:
            while case let data = file.readData(ofLength: bufferSize), data.count > 0 {
                data.withUnsafeBytes {
                    _ = CC_MD5_Update(&context, $0, CC_LONG(data.count))
                }
            }
            
            // Compute the MD5 digest:
            var digest = Data(count: Int(CC_MD5_DIGEST_LENGTH))
            digest.withUnsafeMutableBytes {
                _ = CC_MD5_Final($0, &context)
            }
            
            return digest
            
        } catch {
            print("Cannot open file:", error.localizedDescription)
            return nil
        }
    }
    
    func md5String() -> String {
        return self.map { String(format: "%02hhx", $0) }.joined()
    }
    

}

