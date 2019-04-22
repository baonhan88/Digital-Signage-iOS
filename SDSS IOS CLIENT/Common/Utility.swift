//
//  Utility.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 24/04/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import SystemConfiguration
import SwiftyJSON

struct NetInfo {
    let ip: String
    let netmask: String
}

class Utility: NSObject {
    static func showAlertWithErrorMessage(message: String, controller: UIViewController, completion: (() -> Swift.Void)? = nil) {
        let alert = UIAlertController(title: localizedString(key: "common_error_title"),
                                      message: message,
                                      preferredStyle: UIAlertControllerStyle.alert)

        alert.addAction(UIAlertAction(title: localizedString(key: "common_ok"),
                                      style: UIAlertActionStyle.default,
                                      handler: { (alert) in
                                        
                                        if completion != nil {
                                            completion!()
                                        }
        }))
        controller.present(alert, animated: true, completion: nil)
    }
    
    static func showAlertWithSuccessMessage(message: String, controller: UIViewController, completion:(() -> Swift.Void)? = nil) {
        let alert = UIAlertController(title: localizedString(key: "common_success_title"),
                                      message: message,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: localizedString(key: "common_ok"),
                                      style: UIAlertActionStyle.default,
                                      handler: { (alert) in
                                        
                                        if completion != nil {
                                            completion!()
                                        }
        }))
        controller.present(alert, animated: true, completion: nil)
    }
    
    static func isLogined() -> Bool {
        guard let token = UserDefaults.standard.value(forKey: Network.paramToken) as? String else {
            return false
        }
        
        if token == "" {
            return false
        }
        return true
    }
    
    static func getUrlFromDocumentWithAppend(url: String) -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsURL.appendingPathComponent(url)
    }
    
    // Get the local ip addresses used by this node
    static func getIFAddresses() -> [NetInfo] {
        var addresses = [NetInfo]()
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            
            var ptr = ifaddr;
            while ptr != nil {
                
                let flags = Int32((ptr?.pointee.ifa_flags)!)
                var addr = ptr?.pointee.ifa_addr.pointee
                
                // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
                if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                    if addr?.sa_family == UInt8(AF_INET) || addr?.sa_family == UInt8(AF_INET6) {
                        
                        // Convert interface address to a human readable string:
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        if (getnameinfo(&addr!, socklen_t((addr?.sa_len)!), &hostname, socklen_t(hostname.count),
                                        nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                            if let address = String.init(validatingUTF8:hostname) {
                                
                                var net = ptr?.pointee.ifa_netmask.pointee
                                var netmaskName = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                                getnameinfo(&net!, socklen_t((net?.sa_len)!), &netmaskName, socklen_t(netmaskName.count),
                                            nil, socklen_t(0), NI_NUMERICHOST)// == 0
                                if let netmask = String.init(validatingUTF8:netmaskName) {
                                    addresses.append(NetInfo(ip: address, netmask: netmask))
                                }
                            }
                        }
                    }
                }
                ptr = ptr?.pointee.ifa_next
            }
            freeifaddrs(ifaddr)
        }
        return addresses
    }
    
    static func getUsername() -> String {
        return UserDefaults.standard.value(forKey: Network.paramUsername) as! String
    }
    
    static func getToken() -> String {
        return UserDefaults.standard.value(forKey: Network.paramToken) as! String
    }
    
    static func getYoutubeId(youtubeUrl: String) -> String? {
        let parts = youtubeUrl.components(separatedBy: "youtu.be/")
        if parts.count == 2 {
            return parts[1]
        }
        return nil
    }
    
    static func takeSnapshotWithView(_ view: UIView, andSaveTo fileURL: URL, completion: @escaping (Bool) -> Void) {
        // take a snapshot
        UIGraphicsBeginImageContextWithOptions(view.frame.size, view.isOpaque, 0.0)
//        UIGraphicsBeginImageContext(view.frame.size)
        
//        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // save snapshot 
        let imageData = UIImagePNGRepresentation(image)
        do {
            try imageData?.write(to: fileURL)
        } catch {
            dLog(message: error.localizedDescription)
            completion(false)
            return
        }
        
        completion(true)
    }
    
    static func isInternetAvailable() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    static func secondsToDaysHoursMinutesSeconds (seconds: Int) -> (Int, Int, Int, Int) {
        return (seconds / 86400, (seconds % 86400) / 3600, ((seconds % 86400) % 3600) / 60, ((seconds % 86400) % 3600) % 60)
    }
    
    static func generateDaysHoursMinutesSecondsStringWithSeconds(seconds: Int) -> String {
        let (days, hours, minutes, seconds) = secondsToDaysHoursMinutesSeconds(seconds: seconds)
        
        var timeString = ""
        
        if days > 0 {
            if days == 1 {
                timeString.append("\(days) day ")
            } else {
                timeString.append("\(days) days ")
            }
        }
        
        if hours > 0 {
            if hours == 1 {
                timeString.append("\(hours) hour ")
            } else {
                timeString.append("\(hours) hours ")
            }
        }
        
        if minutes > 0 {
            if minutes == 1 {
                timeString.append("\(minutes) minute ")
            } else {
                timeString.append("\(minutes) minutes ")
            }
        }
        
        if seconds > 0 {
            if seconds == 1 {
                timeString.append("\(seconds) second")
            } else {
                timeString.append("\(seconds) seconds")
            }
        }
        
        return timeString
    }
    
    static func clearImageFromCache(withURL url: URL) {
        let urlRequest = URLRequest.init(url: url)
        
        let imageDownloader = UIImageView.af_sharedImageDownloader
        
        // Clear the URLRequest from the in-memory cache
        _ = imageDownloader.imageCache?.removeImage(for: urlRequest, withIdentifier: nil)
        
        // Clear the URLRequest from the on-disk cache
        imageDownloader.sessionManager.session.configuration.urlCache?.removeCachedResponse(for: urlRequest)
    }
    
    static func setAnchorPoint(anchorPoint: CGPoint, view: UIView) {
        var newPoint = CGPoint.init(x: view.bounds.size.width * anchorPoint.x, y: view.bounds.size.height * anchorPoint.y)
        var oldPoint = CGPoint.init(x: view.bounds.size.width * view.layer.anchorPoint.x, y: view.bounds.size.height * view.layer.anchorPoint.y)
        
        newPoint = newPoint.applying(view.transform)
        oldPoint = oldPoint.applying(view.transform)
        
        var position : CGPoint = view.layer.position
        
        position.x -= oldPoint.x
        position.x += newPoint.x;
        
        position.y -= oldPoint.y;
        position.y += newPoint.y;
        
        view.layer.position = position;
        view.layer.anchorPoint = anchorPoint;
    }
    
    static func convertToJson(from object:Any) -> String? {
        do {
            // Convert to Data
            let jsonData = try JSONSerialization.data(withJSONObject: object, options: [])
            
            // Convert back to string. Usually only do this for debugging
            if let JSONString = String(data: jsonData, encoding: String.Encoding.utf8) {
                return JSONString
            }
            
        } catch {
            print(error)
        }
        
        return ""
        
//        let json = JSON(object)
//        return json.rawString([.castNilToNSNull: true])
    }
}

// MARK: - For Region

extension Utility {
    static func getFirstImageFromRegion(region: Region) -> Image? {
        guard let objects = region.objects else {
            return nil
        }
        
        if objects.count > 0 {
            return objects[0] as? Image
        }
        
        return nil
    }
    
    static func getFirstTextFromRegion(region: Region) -> Text? {
        guard let objects = region.objects else {
            return nil
        }
        
        if objects.count > 0 {
            return objects[0] as? Text
        }
        
        return nil
    }
    
    static func getFirstVideoFromRegion(region: Region) -> Video? {
        guard let objects = region.objects else {
            return nil
        }
        
        if objects.count > 0 {
            return objects[0] as? Video
        }
        
        return nil
    }
    
    static func getFirstWebpageFromRegion(region: Region) -> Webpage? {
        guard let objects = region.objects else {
            return nil
        }
        
        if objects.count > 0 {
            return objects[0] as? Webpage
        }
        
        return nil
    }
    
    static func getFirstShapeFromRegion(region: Region) -> Frame? {
        guard let objects = region.objects else {
            return nil
        }
        
        if objects.count > 0 {
            return objects[0] as? Frame
        }
        
        return nil
    }
    
    static func getYoutubeThumbnail(youtubeUrl: String) -> UIImage? {
        guard let token = Utility.getYoutubeId(youtubeUrl: youtubeUrl) else {
//            Utility.showAlertWithErrorMessage(message: localizedString(key: "presentation_editor_get_youtube_token_fail"), controller: self)
            return nil
        }
        
        do {
            let imageData = try Data.init(contentsOf: URL.init(string: "https://img.youtube.com/vi/\(token)/0.jpg")!)
            return UIImage(data: imageData)
        } catch let error as NSError {
            dLog(message: error.description)
        }
        
        return nil
    }
    
    static func getWeekdayString(by weekDayIndex: Int) -> String {
        switch weekDayIndex {
        case WeekType.sun.tag():
            return WeekType.sun.weekString()
        case WeekType.mon.tag():
            return WeekType.mon.weekString()
        case WeekType.tue.tag():
            return WeekType.tue.weekString()
        case WeekType.wed.tag():
            return WeekType.wed.weekString()
        case WeekType.thu.tag():
            return WeekType.thu.weekString()
        case WeekType.fri.tag():
            return WeekType.fri.weekString()
        case WeekType.sat.tag():
            return WeekType.sat.weekString()
        default:
            return WeekType.mon.weekString()
        }
    }
}

// MARK: - For Validation

extension Utility {
    
    static func isValidName(name: String) -> Bool {
        if name == "" {
            return false
        }
        
        if name.characters.count < 4 {
            return false
        }
        
        if name.characters.count > 126 {
            return false
        }
        
        return true
    }
}

