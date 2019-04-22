//
//  NetworkManager.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 24/04/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import Alamofire

class NetworkManager {
    
    // MARK: - Properties
    static let shared = NetworkManager(baseURL: Network.baseURL)
    let baseURL: String
    
    let STATUS_CODE_SUCCESS = 200
    
    // Initialization
    private init(baseURL: String) {
        self.baseURL = baseURL
    }
}

// MARK: - Helper Methods

extension NetworkManager {
    
    func saveDesignJsonToFile(fileUrl: URL, jsonDict: NSDictionary, completion: @escaping (Bool, String) -> Swift.Void) {
        let rawData: NSData!
        if JSONSerialization.isValidJSONObject(jsonDict) {
            do {
                rawData = try JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted) as NSData
                try rawData.write(toFile: fileUrl.path, options: .atomic)
                
                completion(true, "")
                
            } catch {
                completion(false, localizedString(key: "common_error_message"))
            }
        } else {
            completion(false, localizedString(key: "common_error_message"))
        }
    }
    
    func getPresentationFolder(presentationId: String) -> URL {
        return Utility.getUrlFromDocumentWithAppend(url: Dir.savePresentation + presentationId)
    }
    
    func createFolder(withFolderURL folderURL: URL, completion: @escaping (Bool) -> Void) {
        if !FileManager.default.fileExists(atPath: folderURL.path) {
            do {
                try FileManager.default.createDirectory(atPath: folderURL.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                dLog(message: error.localizedDescription)
                completion(false)
                return
            }
        }
        
        completion(true)
    }
}

// MARK: - Common API

extension NetworkManager {
    
    func login(username: String, password: String, completion: @escaping (Bool, User?, String) -> Void) {
        Alamofire.request(
            baseURL + Network.loginUrl,
            method: .post,
            parameters: [Network.paramUsername: username,
                         Network.paramPassword: password]
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, nil, error)
                        return
                    } else {
                        completion(false, nil, localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                let user = User(dictionary: responseJSON as NSDictionary)
                
                completion(true, user, "")
        }
    }
    
    func register(username: String, email: String, password: String, completion: @escaping (Bool, User?, String) -> Void) {
        Alamofire.request(
            baseURL + Network.registerUrl,
            method: .post,
            parameters: [Network.paramUsername: username,
                         Network.paramEmail: email,
                         Network.paramPassword: password]
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, nil, error)
                        return
                    } else {
                        completion(false, nil, localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                let user = User(dictionary: responseJSON as NSDictionary)
                
                completion(true, user, "")
        }
    }
}

// MARK: - Device
extension NetworkManager {
    
    func getDeviceList(token: String, sort: String, page: Int, perPage: Int, filter: String, completion: @escaping (Bool, [Device]?, PageInfo?, String) -> Void) {
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        // call API
        Alamofire.request(
            baseURL + Network.deviceUrl,
            method: .get,
            parameters: [Network.paramPage: page,
                         Network.paramPerPage: perPage,
                         Network.paramSort: sort,
                         Network.paramFilter: filter],
            headers: headers
            )
            .responseJSON { response in
                
                // if result != isSuccess return error message
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, nil, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                // get json value
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, nil, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, nil, nil, error)
                        return
                    } else {
                        completion(false, nil, nil, localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                guard let dataList = responseJSON[Network.paramDataList] as? [[String: Any]] else {
                    completion(false, nil, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                let deviceList = dataList.flatMap({ (dict) -> Device? in
                    return Device(dictionary: dict as NSDictionary)
                })
                
                guard let pageInfoDict = responseJSON[Network.paramPages] as? NSDictionary else {
                    completion(false, nil, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                let pageInfo = PageInfo(dictionary: pageInfoDict)
                completion(true, deviceList, pageInfo, "")
        }
    }
    
    func activateDevice(pinCode: String, token: String, completion: @escaping (Bool, String) -> Void) {
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        Alamofire.request(
            baseURL + Network.activateUrl,
            method: .post,
            parameters: [Network.paramPinCode: pinCode],
            headers: headers
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, error)
                        return
                    } else {
                        completion(false, localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                completion(true, "")
        }
    }
    
    func deleteDevice(id: String, token: String, completion: @escaping (Bool, String) -> Void) {
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        Alamofire.request(
            baseURL + Network.deviceUrl + "/" + id,
            method: .delete,
            headers: headers
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, error)
                        return
                    } else {
                        completion(false, localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                completion(true, "")
        }
    }
    
    func editNameDevice(id: String, name: String, token: String, completion: @escaping (Bool, String) -> Void) {
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        Alamofire.request(
            baseURL + Network.deviceUrl + "/" + id,
            method: .put,
            parameters: [Network.paramName: name],
            headers: headers
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, error)
                        return
                    } else {
                        completion(false, localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                completion(true, "")
        }
    }
    
    func updateDevice(id: String, content: String?, scheduleContent: String?, events: String?, isDim: Bool?, playStatus: String?, group: String?, autoScale: String?, name: String?, token: String, completion: @escaping (Bool, String) -> Void) {
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        var parameters: [String: Any] = [:]
        if content != nil {
            parameters.updateValue(content ?? "", forKey: Network.paramDeviceContent)
        }
        if scheduleContent != nil {
            parameters.updateValue(scheduleContent ?? "", forKey: Network.paramDeviceScheduleContent)
        }
        if events != nil {
            parameters.updateValue(events ?? "", forKey: Network.paramDeviceEvents)
        }
        if isDim != nil {
            parameters.updateValue(isDim ?? "", forKey: Network.paramDeviceIsDim)
        }
        if playStatus != nil {
            parameters.updateValue(playStatus ?? "", forKey: Network.paramDevicePlayStatus)
        }
        if group != nil {
            parameters.updateValue(group ?? "", forKey: Network.paramDeviceGroup)
        }
        if autoScale != nil {
            parameters.updateValue(autoScale ?? "", forKey: Network.paramDeviceAutoScale)
        }
        if name != nil {
            parameters.updateValue(name ?? "", forKey: Network.paramName)
        }
        
        Alamofire.request(
            baseURL + Network.deviceUrl + "/" + id,
            method: .put,
            parameters: parameters,
            headers: headers
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, error)
                        return
                    } else {
                        completion(false, localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                completion(true, "")
        }
    }
    
    func downloadSnapshot(id: String, token: String, downloadProgress: @escaping (Float) -> Swift.Void, completion: @escaping (Bool, String, UIImage?) -> Swift.Void) {
        let fileURL = Utility.getUrlFromDocumentWithAppend(url: Dir.snapshot + id + ".png")
        
        // create destination url
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let folderUrl = Utility.getUrlFromDocumentWithAppend(url: Dir.snapshot)
            do {
                try FileManager.default.createDirectory(atPath: folderUrl.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription);
            }

            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        let url = baseURL + String(format:Network.downloadSnapshotUrl, id, Utility.getToken())
        dLog(message: "download url = " + url)
        
        Alamofire.download(
            url,
            method: .get,
            encoding: JSONEncoding.default,
            headers: headers,
            to: destination)
            .downloadProgress(closure: { (progress) in
                
                downloadProgress(Float(progress.fractionCompleted))
                
            }).response(completionHandler: { (response) in
                                
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    completion(false, localizedString(key: "common_error_message"), nil)
                    return
                }

                if response.error == nil, let imagePath = response.destinationURL?.path {
                    guard let image = UIImage(contentsOfFile: imagePath) else {
                        completion(false, localizedString(key: "common_error_message"), nil)
                        return
                    }
                    
                    completion(true, "", image)
                    return
                }
                
                completion(false, localizedString(key: "common_error_message"), nil)
        })
    }
    
    func controlDeviceToPlay(pinCodeList: String, contentId: String, contentType: String, contentName: String, contentData: String?, token: String,
                             completion: @escaping (Bool, String) -> Void) {
        
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        var parameters: [String: Any] = [:]
        parameters.updateValue(pinCodeList, forKey: Network.paramPinCodeList)
        parameters.updateValue(contentId, forKey: Network.paramContentId)
        parameters.updateValue(contentType, forKey: Network.paramContentType)
        parameters.updateValue(contentName, forKey: Network.paramContentName)
        if contentData != nil {
            parameters.updateValue(contentData ?? "", forKey: Network.paramContentData)
        }
        
        Alamofire.request(
            baseURL + Network.controlDeviceToPlayUrl,
            method: .post,
            parameters: parameters,
            headers: headers
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
//                guard let responseJSON = response.result.value as? [String: Any] else {
//                    dLog(message: "didn't get todo object as JSON from API")
//                    completion(false, localizedString(key: "common_error_message"))
//                    return
//                }
//                
//                // check status code != 200 && has error message from server -> process error
//                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
//                    if let error = responseJSON[Network.paramDesc] as? String {
//                        dLog(message: "Error while fetching data")
//                        completion(false, error)
//                        return
//                    } else {
//                        completion(false, localizedString(key: "common_error_message"))
//                        return
//                    }
//                }
                
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                completion(true, "")
        }
    }
    
    func controlDeviceToUpdate(pinCodeList: String, contentId: String, contentType: String, contentName: String, contentData: String?, token: String,
                             completion: @escaping (Bool, String) -> Void) {
        
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        var parameters: [String: Any] = [:]
        parameters.updateValue(pinCodeList, forKey: Network.paramPinCodeList)
        parameters.updateValue(contentId, forKey: Network.paramContentId)
        parameters.updateValue(contentType, forKey: Network.paramContentType)
        parameters.updateValue(contentName, forKey: Network.paramContentName)
        if contentData != nil {
            parameters.updateValue(contentData ?? "", forKey: Network.paramContentData)
        }
        
        Alamofire.request(
            baseURL + Network.controlDeviceToUpdateUrl,
            method: .post,
            parameters: parameters,
            headers: headers
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                //                guard let responseJSON = response.result.value as? [String: Any] else {
                //                    dLog(message: "didn't get todo object as JSON from API")
                //                    completion(false, localizedString(key: "common_error_message"))
                //                    return
                //                }
                //
                //                // check status code != 200 && has error message from server -> process error
                //                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                //                    if let error = responseJSON[Network.paramDesc] as? String {
                //                        dLog(message: "Error while fetching data")
                //                        completion(false, error)
                //                        return
                //                    } else {
                //                        completion(false, localizedString(key: "common_error_message"))
                //                        return
                //                    }
                //                }
                
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                completion(true, "")
        }
    }
    
    func controlToSnapshot(pinCodeList: String, token: String, completion: @escaping (Bool, String) -> Void) {
        
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        Alamofire.request(
            baseURL + Network.controlDeviceToSnapshotUrl,
            method: .post,
            parameters: [Network.paramPinCodeList: pinCodeList],
            headers: headers
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, error)
                        return
                    } else {
                        completion(false, localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                completion(true, "")
        }
    }
    
    func controlDevice(action: String, idList: String, token: String, completion: @escaping (Bool, String) -> Void) {
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        Alamofire.request(
            baseURL + Network.controlDeviceUrl,
            method: .post,
            parameters: [Network.paramAction: action,
                         Network.paramIdList: idList],
            headers: headers
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, error)
                        return
                    } else {
                        completion(false, localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                completion(true, "")
        }
    }
}

// MARK: - Instant Message
extension NetworkManager {
    
    func playEventInstantMessage(token: String, name: String, data: String, eventType: String, playTime: String, duration: Int, pinCodeList: String, completion: @escaping (Bool, String) -> Void) {
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        Alamofire.request(
            baseURL + Network.controlDeviceEventUrl,
            method: .post,
            parameters: [Network.paramName: name,
                         Network.paramData: data,
                         Network.paramEventType: eventType,
                         Network.paramPlayTime: playTime,
                         Network.paramDuration: duration,
                         Network.paramPinCodeList: pinCodeList],
            headers: headers
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
//                guard let responseJSON = response.result.value as? [String: Any] else {
//                    dLog(message: "didn't get todo object as JSON from API")
//                    completion(false, localizedString(key: "common_error_message"))
//                    return
//                }
//                
//                // check status code != 200 && has error message from server -> process error
//                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
//                    if let error = responseJSON[Network.paramDesc] as? String {
//                        dLog(message: "Error while fetching data")
//                        completion(false, error)
//                        return
//                    } else {
//                        completion(false, localizedString(key: "common_error_message"))
//                        return
//                    }
//                }
                
                completion(true, "")
        }
    }
}

// MARK: - Tag
extension NetworkManager {
    
    func getTagList(token: String, sort: String, page: Int, perPage: Int, completion: @escaping (Bool, [Tag]?, PageInfo?, String) -> Void) {
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        // call API
        Alamofire.request(
            baseURL + Network.tagUrl,
            method: .get,
            parameters: [Network.paramPage: page,
                         Network.paramPerPage: perPage,
                         Network.paramSort: sort],
            headers: headers
            )
            .responseJSON { response in
                
                // if result != isSuccess return error message
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, nil, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                // get json value
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, nil, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, nil, nil, error)
                        return
                    } else {
                        completion(false, nil, nil, localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                guard let dataList = responseJSON[Network.paramDataList] as? [[String: Any]] else {
                    completion(false, nil, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                let tagList = dataList.flatMap({ (dict) -> Tag? in
                    return Tag(dictionary: dict as NSDictionary)
                })
                
                guard let pageInfoDict = responseJSON[Network.paramPages] as? NSDictionary else {
                    completion(false, nil, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                let pageInfo = PageInfo(dictionary: pageInfoDict)
                completion(true, tagList, pageInfo, "")
        }
    }
}

// MARK: - Presentation
extension NetworkManager {
    
    func getPresentationList(filter: String, sort: String, token: String, page: Int, perPage: Int, completion: @escaping (Bool, [Presentation]?, PageInfo?, String) -> Void) {
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        // call API
        Alamofire.request(
            baseURL + Network.presentationUrl,
            method: .get,
            parameters: [Network.paramPage: page,
                         Network.paramPerPage: perPage,
                         Network.paramFilter: filter,
                         Network.paramSort: sort],
            headers: headers
            )
            .responseJSON { response in
                
                // if result != isSuccess return error message
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, nil, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                // get json value
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, nil, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, nil, nil, error)
                        return
                    } else {
                        completion(false, nil, nil, localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                guard let dataList = responseJSON[Network.paramDataList] as? [[String: Any]] else {
                    completion(false, nil, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                let presentationList = dataList.flatMap({ (dict) -> Presentation? in
                    return Presentation(dictionary: dict as NSDictionary)
                })
                
                guard let pageInfoDict = responseJSON[Network.paramPages] as? NSDictionary else {
                    completion(false, nil, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                let pageInfo = PageInfo(dictionary: pageInfoDict)
                completion(true, presentationList, pageInfo, "")
        }
    }
    
    func downloadTemplateAsset(asset: Asset, token: String, downloadProgress: @escaping (Float) -> Swift.Void, completion: @escaping (Bool, String) -> Swift.Void) {
        let fileURL = Utility.getUrlFromDocumentWithAppend(url: Dir.assets + asset.id + asset.ext)
        
        downloadAsset(fileURL: fileURL, asset: asset, token: token, downloadProgress: downloadProgress, completion: completion)
    }
    
    func downloadPresentationAsset(presentationId: String, asset: Asset, token: String, downloadProgress: @escaping (Float) -> Swift.Void, completion: @escaping (Bool, String) -> Swift.Void) {
        let fileURL = getPresentationFolder(presentationId: presentationId).appendingPathComponent(asset.id + asset.ext)
        
        downloadAsset(fileURL: fileURL, asset: asset, token: token, downloadProgress: downloadProgress, completion: completion)
    }
    
    func downloadAsset(fileURL: URL, asset: Asset, token: String, downloadProgress: @escaping (Float) -> Swift.Void, completion: @escaping (Bool, String) -> Swift.Void) {
        
        // check if asset exist -> return success
        if FileManager.default.fileExists(atPath: fileURL.path) {
            completion(true, "")
            return
        }
        
        // create destination url
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            
//            let folderUrl = Utility.getUrlFromDocumentWithAppend(url: Dir.assets)
//            do {
//                try FileManager.default.createDirectory(atPath: folderUrl.path, withIntermediateDirectories: true, attributes: nil)
//            } catch {
//                dLog(message: error.localizedDescription)
//            }
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        let url = baseURL + String(format:Network.downloadPresentationAssetUrl, asset.id)
        dLog(message: "download url = " + url)
        
        Alamofire.download(
            url,
            method: .get,
            encoding: JSONEncoding.default,
            headers: headers,
            to: destination)
            .downloadProgress(closure: { (progress) in
                
                downloadProgress(Float(progress.fractionCompleted))
                
            }).response(completionHandler: { (response) in
                
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    // remove useless file
                    if FileManager.default.fileExists(atPath: fileURL.path) {
                        do {
                            try FileManager.default.removeItem(at: fileURL)
                        } catch {
                            dLog(message: error.localizedDescription)
                        }
                    }
                    
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                completion(true, "")
            })
    }
    
    func getTemplateDesignData(presentationId: String, token: String, completion: @escaping (Bool, String) -> Void) {
        let fileURL = Utility.getUrlFromDocumentWithAppend(url: Dir.template + presentationId + Dir.presentationDesignExtension)

        // create Template folder to save template design file
        let folderUrl = Utility.getUrlFromDocumentWithAppend(url: Dir.template)
        createFolder(withFolderURL: folderUrl) { (success) in
            if !success {
                completion(false, localizedString(key: "common_error_message"))
                return
            }
        }
        
        getDesignData(presentationId: presentationId, fileURL: fileURL, token: token, completion: completion)
    }
    
    func getPresentationDesignData(presentationId: String, token: String, completion: @escaping (Bool, String) -> Void) {
        let fileURL = getPresentationFolder(presentationId: presentationId).appendingPathComponent(presentationId + Dir.presentationDesignExtension)
        
        // create presentation folder to save design file
        createFolder(withFolderURL: getPresentationFolder(presentationId: presentationId)) { (success) in
            if !success {
                completion(false, localizedString(key: "common_error_message"))
                return
            }
        }
        
        getDesignData(presentationId: presentationId, fileURL: fileURL, token: token, completion: completion)
    }
    
    func getDesignData(presentationId: String, fileURL: URL, token: String, completion: @escaping (Bool, String) -> Void) {
        // check if design file exist -> return success
//        if FileManager.default.fileExists(atPath: fileURL.path) {
//            completion(true, "")
//            return
//        }
        
        let url = baseURL + String(format:Network.downloadPresentationDesignDataUrl, presentationId)
        
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        // call API
        Alamofire.request(
            url,
            method: .get,
            headers: headers
            )
            .responseJSON { response in
                
                // if result != isSuccess return error message
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                // get json value
                guard let responseJSON = response.result.value as? NSDictionary else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, error)
                        return
                    } else {
                        completion(false, localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                // save responseJSON to file
                self.saveDesignJsonToFile(fileUrl: fileURL, jsonDict: responseJSON, completion: completion)
        }
    }
    
    func downloadTemplateThumbnail(presentationId: String, url: String, downloadProgress: @escaping (Float) -> Swift.Void, completion: @escaping (Bool, String) -> Swift.Void) {
        let fileURL = Utility.getUrlFromDocumentWithAppend(url: Dir.templateThumbnail + presentationId + Dir.presentationThumbnailExtension)
        
        downloadThumbnail(id: presentationId, url: url, fileURL: fileURL, downloadProgress: downloadProgress, completion: completion)
    }
    
    func downloadPresentationThumbnail(presentationId: String, url: String, downloadProgress: @escaping (Float) -> Swift.Void, completion: @escaping (Bool, String) -> Swift.Void) {
        let fileURL = getPresentationFolder(presentationId: presentationId).appendingPathComponent(presentationId + Dir.presentationThumbnailExtension)
        
        downloadThumbnail(id: presentationId, url: url, fileURL: fileURL, downloadProgress: downloadProgress, completion: completion)
    }
    
    func downloadThumbnail(id: String, url: String, fileURL: URL, downloadProgress: @escaping (Float) -> Swift.Void, completion: @escaping (Bool, String) -> Swift.Void) {
        
        // check if design file exist -> return success
//        if FileManager.default.fileExists(atPath: fileURL.path) {
//            completion(true, "")
//            return
//        }
        
        // create destination url
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            //            let folderUrl = Utility.getUrlFromDocumentWithAppend(url: Dir.templateThumbnail)
            //            do {
            //                try FileManager.default.createDirectory(atPath: folderUrl.path, withIntermediateDirectories: true, attributes: nil)
            //            } catch {
            //                print(error.localizedDescription);
            //            }
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        // create header to add token
        let url = baseURL + url
        dLog(message: "download presentation thumbnail url = " + url)
        
        Alamofire.download(
            url,
            method: .get,
            encoding: JSONEncoding.default,
            to: destination)
            .downloadProgress(closure: { (progress) in
                
                downloadProgress(Float(progress.fractionCompleted))
                
            }).response(completionHandler: { (response) in
                
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                if response.error == nil, let imagePath = response.destinationURL?.path {
                    guard UIImage(contentsOfFile: imagePath) != nil else {
                        completion(false, localizedString(key: "common_error_message"))
                        return
                    }
                    
                    completion(true, "")
                    return
                }
                
                completion(false, localizedString(key: "common_error_message"))
            })
    }
    
    func updatePresentation(id: String, regions: String, assetList: String, token: String, completion: @escaping (Bool, String) -> Void) {
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        Alamofire.request(
            baseURL + Network.presentationUrl + "/" + id,
            method: .put,
            parameters: [Network.paramRegions: regions,
                         Network.paramAssetList: assetList],
            headers: headers
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, error)
                        return
                    } else {
                        completion(false, localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                completion(true, "")
        }
    }
    
    func updatePresentation(id: String, code: String, name: String, lock: Bool, orientation: String, shortDescription: String, ratio: String, width: CGFloat, height: CGFloat, bgAudioEnable: Bool, bgImage: String?, tags: [String], assetList: String, regions: String, token: String, completion: @escaping (Bool, String, String) -> Void) {
        
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        var parameters: [String: Any] = [:]
        parameters.updateValue(code, forKey: Network.paramCode)
        parameters.updateValue(name, forKey: Network.paramName)
        parameters.updateValue(lock, forKey: Network.paramLock)
        parameters.updateValue(orientation, forKey: Network.paramOrientation)
        parameters.updateValue(shortDescription, forKey: Network.paramShortDescription)
        parameters.updateValue(ratio, forKey: Network.paramRatio)
        parameters.updateValue(width, forKey: Network.paramWidth)
        parameters.updateValue(height, forKey: Network.paramHeight)
        parameters.updateValue(bgAudioEnable, forKey: Network.paramBgAudioEnable)
        if bgImage != nil {
            parameters.updateValue(bgImage ?? "", forKey: Network.paramBgImage)
        }
        parameters.updateValue(tags, forKey: Network.paramTags)
        parameters.updateValue(regions, forKey: Network.paramRegions)
        parameters.updateValue(assetList, forKey: Network.paramAssetList)

        Alamofire.request(
            baseURL + Network.presentationUrl + "/" + id,
            method: .put,
            parameters: parameters,
            headers: headers
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, "", localizedString(key: "common_error_message"))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, "", localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, "", error)
                        return
                    } else {
                        completion(false, "", localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                guard let presentationId = responseJSON[Network.paramId] as? String else {
                    completion(false, "", localizedString(key: "common_error_message"))
                    return
                }
                
                completion(true, presentationId, "")
        }
    }
    
    func updatePresentationThumbnail(presentaionId: String, token: String, fileName: String, fileData: Data, completion: @escaping (Bool, String) -> Void) {
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        // just cheat like GET method because Android can't add params in the body of request, will change it later with just uncomment some text below
        let url = baseURL + String(format: Network.updatePresentationThumbnailUrl, presentaionId)
        dLog(message: "upload presentation thumbnail url = " + url)
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(fileData, withName: Network.paramFile, fileName: fileName, mimeType: "")
        },
            to: url,
            method: .post,
            headers: headers,
            encodingCompletion: { encodingResult in
                
                switch encodingResult {
                    
                case .success(let upload, _, _):
                    
                    upload.uploadProgress(closure: { (progress) in
                        dLog(message: "Upload Progress: \(progress.fractionCompleted)")
                    })
                    
                    upload.responseJSON { response in
                        
                        guard response.result.isSuccess else {
                            dLog(message: "Error while fetching data")
                            completion(false, localizedString(key: "common_error_message"))
                            return
                        }
                        
                        guard let responseJSON = response.result.value as? [String: Any] else {
                            dLog(message: "didn't get todo object as JSON from API")
                            completion(false, localizedString(key: "common_error_message"))
                            return
                        }
                        
                        // check status code != 200 && has error message from server -> process error
                        if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                            if let error = responseJSON[Network.paramDesc] as? String {
                                dLog(message: "Error while fetching data")
                                completion(false, error)
                                return
                            } else {
                                completion(false, localizedString(key: "common_error_message"))
                                return
                            }
                        }
                        
                        completion(true, "")
                    }
                    
                case .failure(let encodingError):
                    dLog(message: encodingError.localizedDescription)
                    completion(false, localizedString(key: "common_error_message"))
                }
            }
        )
    }
    
    func getPresentation(presentationId: String, token: String, completion: @escaping (Bool, Presentation?, String) -> Void) {
        let url = baseURL + Network.presentationUrl + "/" + presentationId
        
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        // call API
        Alamofire.request(
            url,
            method: .get,
            headers: headers
            )
            .responseJSON { response in
                
                // if result != isSuccess return error message
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                // get json value
                guard let responseJSON = response.result.value as? NSDictionary else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, nil, error)
                        return
                    } else {
                        completion(false, nil, localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                // save responseJSON to file
                let presentation = Presentation(dictionary: responseJSON)
                completion(true, presentation, "")
        }
    }
    
    func deletePresentation(id: String, token: String, completion: @escaping (Bool, String) -> Void) {
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        Alamofire.request(
            baseURL + Network.presentationUrl + "/" + id,
            method: .delete,
            headers: headers
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let errorMessage = responseJSON[Network.paramDesc] as? String,
                        let errorCode = responseJSON[Network.paramError] as? Int {
                        
                        if errorCode == ErrorCode.unavaiable || errorCode == ErrorCode.invalidData {
                            // just presentation from local, can delete it
                            completion(true, "")
                        } else {
                            dLog(message: "Error while fetching data")
                            completion(false, errorMessage)
                        }
                        return
                    } else {
                        completion(false, localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                completion(true, "")
        }
    }
    
    func editNamePresentation(id: String, name: String, token: String, completion: @escaping (Bool, String) -> Void) {
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        Alamofire.request(
            baseURL + Network.presentationUrl + "/" + id,
            method: .put,
            parameters: [Network.paramName: name],
            headers: headers
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let errorMessage = responseJSON[Network.paramDesc] as? String,
                        let errorCode = responseJSON[Network.paramError] as? Int {
                        
                        if errorCode == ErrorCode.unavaiable || errorCode == ErrorCode.invalidData {
                            // just presentation from local, can change name it
                            completion(true, "")
                        } else {
                            dLog(message: "Error while fetching data")
                            completion(false, errorMessage)
                        }
                        return
                    } else {
                        completion(false, localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                completion(true, "")
        }
    }
}

// MARK: - PresentationPublic

extension NetworkManager {
    
    func getPresentationPublicList(category: String, token: String, page: Int, perPage: Int, completion: @escaping (Bool, [Presentation]?, PageInfo?, String) -> Void) {
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        // call API
        Alamofire.request(
            baseURL + Network.presentationPublicUrl,
            method: .get,
            parameters: [Network.paramCategory: category,
                         Network.paramPage: page,
                         Network.paramPerPage: perPage],
            headers: headers
            )
            .responseJSON { response in
                
                // if result != isSuccess return error message
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, nil, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                // get json value
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, nil, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, nil, nil, error)
                        return
                    } else {
                        completion(false, nil, nil, localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                guard let dataList = responseJSON[Network.paramDataList] as? [[String: Any]] else {
                    completion(false, nil, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                let presentationList = dataList.flatMap({ (dict) -> Presentation? in
                    return Presentation(dictionary: dict as NSDictionary)
                })
                
                guard let pageInfoDict = responseJSON[Network.paramPages] as? NSDictionary else {
                    completion(false, nil, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                let pageInfo = PageInfo(dictionary: pageInfoDict)
                completion(true, presentationList, pageInfo, "")
        }
    }
    
    func presentationPublicCopyItToMine(id: String, token: String, completion: @escaping (Bool, String) -> Void) {
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        Alamofire.request(
            baseURL + String.init(format: Network.presentationPublicCopyItToMineUrl, id),
            method: .post,
            parameters: nil,
            headers: headers
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, error)
                        return
                    } else {
                        completion(false, localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                completion(true, "")
        }
    }

}

// MARK: - BoughtPresentation

extension NetworkManager {
    
    func getBoughtPresentation(presentationId: String, eCoinXorF: Bool, token: String, completion: @escaping (Bool, String) -> Void) {
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        Alamofire.request(
            baseURL + Network.boughtPresentationUrl,
            method: .post,
            parameters: [Network.paramPresentationId: presentationId,
                         Network.paramECoinXorF: eCoinXorF],
            headers: headers
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, error)
                        return
                    } else {
                        completion(false, localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                completion(true, "")
        }
    }
}

// MARK: - Asset

extension NetworkManager {
    
    func checkAssetExist(md5s: String, token: String, completion: @escaping (Bool, [Asset], String) -> Void) {
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        Alamofire.request(
            baseURL + Network.checkAssetExistUrl,
            method: .post,
            parameters: [Network.paramMd5s: md5s],
            headers: headers
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, [], localizedString(key: "common_error_message"))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, [], localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, [], error)
                        return
                    } else {
                        completion(false, [], localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                // parse asset list from response data
                guard let assetDictList = responseJSON[Network.paramAssets] as? [NSDictionary] else {
                    completion(false, [], localizedString(key: "common_error_message"))
                    return
                }
                
                if assetDictList.count == 0 {
                    completion(true, [], "")
                    return
                }
                
                let assetList = NSMutableArray.init()
                for assetDict in assetDictList {
                    let asset = Asset(dictionary: assetDict)
                    assetList.add(asset)
                }
                
                completion(true, assetList as! [Asset], "")
        }
    }
    
    func createAsset(md5: String, token: String, fileName: String, fileData: Data, completion: @escaping (Bool, String, String) -> Void) {
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        // just cheat like GET method because Android can't add params in the body of request, will change it later with just uncomment some text below
        let url = baseURL + Network.createAssetUrl + "?md5=" + md5
        dLog(message: "upload url = " + url)
        
//        let parameters = [
//            Network.paramMd5: md5,
//        ]
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
//                for (key, value) in parameters {
//                    multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
//                }
//                multipartFormData.append(fileData, withName: Network.paramFile)
                multipartFormData.append(fileData, withName: Network.paramFile, fileName: fileName, mimeType: "")
            },
            to: url,
            method: .post,
            headers: headers,
            encodingCompletion: { encodingResult in
                
                switch encodingResult {
                    
                case .success(let upload, _, _):
                    
                    upload.uploadProgress(closure: { (progress) in
                        dLog(message: "Upload Progress: \(progress.fractionCompleted)")
                    })
                    
                    upload.responseJSON { response in
                        
                        guard response.result.isSuccess else {
                            dLog(message: "Error while fetching data")
                            completion(false, "", localizedString(key: "common_error_message"))
                            return
                        }
                        
                        guard let responseJSON = response.result.value as? [String: Any] else {
                            dLog(message: "didn't get todo object as JSON from API")
                            completion(false, "", localizedString(key: "common_error_message"))
                            return
                        }
                        
                        // check status code != 200 && has error message from server -> process error
                        if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                            if let error = responseJSON[Network.paramDesc] as? String {
                                dLog(message: "Error while fetching data")
                                completion(false, "", error)
                                return
                            } else {
                                completion(false, "", localizedString(key: "common_error_message"))
                                return
                            }
                        }
                        
                        guard let assetId = responseJSON[Network.paramId] as? String else {
                            completion(false, "", localizedString(key: "common_error_message"))
                            return

                        }
                        
                        completion(true, assetId, "")
                    }

                case .failure(let encodingError):
                    dLog(message: encodingError.localizedDescription)
                    completion(false, "", localizedString(key: "common_error_message"))
                }
            }
        )
    }
    
    func getAssetListFromCloud(filter: String, sort: String, token: String, page: Int, perPage: Int, completion: @escaping (Bool, [AssetDetail]?, PageInfo?, String) -> Void) {
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        // call API
        Alamofire.request(
            baseURL + Network.createAssetUrl,
            method: .get,
            parameters: [Network.paramPage: page,
                         Network.paramPerPage: perPage,
                         Network.paramFilter: filter,
                         Network.paramSort: sort],
            headers: headers
            )
            .responseJSON { response in
                
                // if result != isSuccess return error message
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, nil, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                // get json value
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, nil, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, nil, nil, error)
                        return
                    } else {
                        completion(false, nil, nil, localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                guard let dataList = responseJSON[Network.paramDataList] as? [[String: Any]] else {
                    completion(false, nil, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                let assetDetail = dataList.flatMap({ (dict) -> AssetDetail? in
                    return AssetDetail(dictionary: dict as NSDictionary)
                })
                
                guard let pageInfoDict = responseJSON[Network.paramPages] as? NSDictionary else {
                    completion(false, nil, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                let pageInfo = PageInfo(dictionary: pageInfoDict)
                completion(true, assetDetail, pageInfo, "")
        }
    }
    
    func downloadAssetFromAssetListInCloud(fileURL: URL, assetDetail: AssetDetail, token: String, downloadProgress: @escaping (Float) -> Swift.Void, completion: @escaping (Bool, String) -> Swift.Void) {
        
        // check if asset exist -> return success
        if FileManager.default.fileExists(atPath: fileURL.path) {
            completion(true, "")
            return
        }
        
        // create destination url
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        let url = baseURL + String(format:Network.downloadPresentationAssetUrl, assetDetail.id)
        dLog(message: "download url = " + url)
        
        Alamofire.download(
            url,
            method: .get,
            encoding: JSONEncoding.default,
            headers: headers,
            to: destination)
            .downloadProgress(closure: { (progress) in
                
                downloadProgress(Float(progress.fractionCompleted))
                
            }).response(completionHandler: { (response) in
                
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    // remove useless file
                    if FileManager.default.fileExists(atPath: fileURL.path) {
                        do {
                            try FileManager.default.removeItem(at: fileURL)
                        } catch {
                            dLog(message: error.localizedDescription)
                        }
                    }
                    
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                completion(true, "")
            })
    }
    
    func deleteAsset(id: String, token: String, completion: @escaping (Bool, String) -> Void) {
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        Alamofire.request(
            baseURL + Network.createAssetUrl + "/" + id,
            method: .delete,
            headers: headers
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, error)
                        return
                    } else {
                        completion(false, localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                completion(true, "")
        }
    }
    
    func editAsset(id: String, name: String, tags: String, token: String, completion: @escaping (Bool, String) -> Void) {
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        Alamofire.request(
            baseURL + Network.createAssetUrl + "/" + id,
            method: .put,
            parameters: [Network.paramName: name,
                         Network.paramTags: tags],
            headers: headers
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, error)
                        return
                    } else {
                        completion(false, localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                completion(true, "")
        }
    }
    
    func uploadAsset(fileName: String, fileData: Data, completion: @escaping (Bool, String) -> Void) {
        // encode params
        let paramsString = "name=\(fileName)"
        let encodedParamsString = paramsString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        let url = baseURL + Network.createAssetUrl + "?" + encodedParamsString
        
        dLog(message: "upload url = " + url)
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(fileData, withName: "", fileName: fileName, mimeType: "")
        },
            to: url,
            method: .post,
            encodingCompletion: { encodingResult in
                
                switch encodingResult {
                    
                case .success(let upload, _, _):
                    
                    upload.uploadProgress(closure: { (progress) in
                        dLog(message: "Upload Progress: \(progress.fractionCompleted)")
                    })
                    
                    upload.responseJSON { response in
                        
                        //                        guard response.result.isSuccess else {
                        //                            dLog(message: "Error while fetching data")
                        //                            completion(false, localizedString(key: "common_error_message"))
                        //                            return
                        //                        }
                        
                        // check status code != 200 && has error message from server -> process error
                        if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                            completion(false, localizedString(key: "common_error_message"))
                            return
                        }
                        
                        completion(true, "")
                    }
                    
                case .failure(let encodingError):
                    dLog(message: encodingError.localizedDescription)
                    completion(false, localizedString(key: "common_error_message"))
                }
        }
        )
    }
}

// MARK: - PlayList

extension NetworkManager {
    
    func getPlayList(token: String, sort: String, page: Int, perPage: Int, completion: @escaping (Bool, [PlayList]?, PageInfo?, String) -> Void) {
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        // call API
        Alamofire.request(
            baseURL + Network.playListUrl,
            method: .get,
            parameters: [Network.paramPage: page,
                         Network.paramPerPage: perPage,
                         Network.paramSort: sort],
            headers: headers
            )
            .responseJSON { response in
                
                // if result != isSuccess return error message
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, nil, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                // get json value
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, nil, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, nil, nil, error)
                        return
                    } else {
                        completion(false, nil, nil, localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                guard let dataList = responseJSON[Network.paramDataList] as? [[String: Any]] else {
                    completion(false, nil, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                let playList = dataList.flatMap({ (dict) -> PlayList? in
                    return PlayList(dictionary: dict as NSDictionary)
                })
                
                guard let pageInfoDict = responseJSON[Network.paramPages] as? NSDictionary else {
                    completion(false, nil, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                let pageInfo = PageInfo(dictionary: pageInfoDict)
                completion(true, playList, pageInfo, "")
        }
    }
    
    func editNamePlayList(id: String, name: String, token: String, completion: @escaping (Bool, String) -> Void) {
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        Alamofire.request(
            baseURL + Network.playListUrl + "/" + id,
            method: .put,
            parameters: [Network.paramName: name],
            headers: headers
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, error)
                        return
                    } else {
                        completion(false, localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                completion(true, "")
        }
    }
    
    func deletePlayList(id: String, token: String, completion: @escaping (Bool, String) -> Void) {
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        Alamofire.request(
            baseURL + Network.playListUrl + "/" + id,
            method: .delete,
            headers: headers
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, error)
                        return
                    } else {
                        completion(false, localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                completion(true, "")
        }
    }
    
    func addPlayList(name: String, token: String, completion: @escaping (Bool, String, String) -> Void) {
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        Alamofire.request(
            baseURL + Network.playListUrl,
            method: .post,
            parameters: [Network.paramName: name],
            headers: headers
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, "", localizedString(key: "common_error_message"))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, "", localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, "", error)
                        return
                    } else {
                        completion(false, "", localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                guard let id = responseJSON[Network.paramId] as? String else {
                    completion(false, "", localizedString(key: "common_error_message"))
                    return
                }
                
                completion(true, id, "")
        }
    }
    
    func updatePlayList(id: String, code: String?, totalTime: Int?, name: Bool?, shortDescription: String?, displayList: String?, group: String?, token: String, completion: @escaping (Bool, String) -> Void) {
        
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        var parameters: [String: Any] = [:]
        if code != nil {
            parameters.updateValue(code ?? "", forKey: Network.paramCode)
        }
        if totalTime != nil {
            parameters.updateValue(totalTime ?? 1, forKey: Network.paramTotalTime)
        }
        if name != nil {
            parameters.updateValue(name ?? "", forKey: Network.paramName)
        }
        if shortDescription != nil {
            parameters.updateValue(shortDescription ?? "", forKey: Network.paramShortDescription)
        }
        if displayList != nil {
            parameters.updateValue(displayList ?? "", forKey: Network.paramDisplayList)
        }
        if group != nil {
            parameters.updateValue(group ?? "", forKey: Network.paramGroup)
        }
        
        Alamofire.request(
            baseURL + Network.playListUrl + "/" + id,
            method: .put,
            parameters: parameters,
            headers: headers
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, error)
                        return
                    } else {
                        completion(false, localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                completion(true, "")
        }
    }
}

// MARK: - Weekly Schedule

extension NetworkManager {
    
    func getWeeklyScheduleList(token: String, sort: String, page: Int, perPage: Int, completion: @escaping (Bool, [WeeklySchedule]?, PageInfo?, String) -> Void) {
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        // call API
        Alamofire.request(
            baseURL + Network.weeklyScheduleListUrl,
            method: .get,
            parameters: [Network.paramPage: page,
                         Network.paramPerPage: perPage,
                         Network.paramSort: sort],
            headers: headers
            )
            .responseJSON { response in
                
                // if result != isSuccess return error message
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, nil, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                // get json value
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, nil, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, nil, nil, error)
                        return
                    } else {
                        completion(false, nil, nil, localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                guard let displaySchedule = responseJSON[Network.paramDataList] as? [[String: Any]] else {
                    completion(false, nil, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                let weeklyScheduleList = displaySchedule.flatMap({ (dict) -> WeeklySchedule? in
                    return WeeklySchedule(dictionary: dict as NSDictionary)
                })
                
                guard let pageInfoDict = responseJSON[Network.paramPages] as? NSDictionary else {
                    completion(false, nil, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                let pageInfo = PageInfo(dictionary: pageInfoDict)
                completion(true, weeklyScheduleList, pageInfo, "")
        }
    }
    
    func editNameWeeklySchedule(id: String, name: String, token: String, completion: @escaping (Bool, String) -> Void) {
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        Alamofire.request(
            baseURL + Network.weeklyScheduleListUrl + "/" + id,
            method: .put,
            parameters: [Network.paramName: name],
            headers: headers
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, error)
                        return
                    } else {
                        completion(false, localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                completion(true, "")
        }
    }
    
    func deleteWeeklySchedule(id: String, token: String, completion: @escaping (Bool, String) -> Void) {
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        Alamofire.request(
            baseURL + Network.weeklyScheduleListUrl + "/" + id,
            method: .delete,
            headers: headers
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, error)
                        return
                    } else {
                        completion(false, localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                completion(true, "")
        }
    }
    
    func addWeeklySchedule(name: String, token: String, completion: @escaping (Bool, String, String) -> Void) {
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        Alamofire.request(
            baseURL + Network.weeklyScheduleListUrl,
            method: .post,
            parameters: [Network.paramName: name],
            headers: headers
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, "", localizedString(key: "common_error_message"))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, "", localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, "", error)
                        return
                    } else {
                        completion(false, "", localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                guard let id = responseJSON[Network.paramId] as? String else {
                    completion(false, "", localizedString(key: "common_error_message"))
                    return
                }
                
                completion(true, id, "")
        }
    }
    
    func updateWeeklySchedule(id: String, code: String?, name: Bool?, shortDescription: String?, displaySchedule: String?, group: String?, token: String, completion: @escaping (Bool, String) -> Void) {
        
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        var parameters: [String: Any] = [:]
        if code != nil {
            parameters.updateValue(code ?? "", forKey: Network.paramCode)
        }
        if name != nil {
            parameters.updateValue(name ?? "", forKey: Network.paramName)
        }
        if shortDescription != nil {
            parameters.updateValue(shortDescription ?? "", forKey: Network.paramShortDescription)
        }
        if displaySchedule != nil {
            parameters.updateValue(displaySchedule ?? "", forKey: Network.paramDisplaySchedule)
        }
        if group != nil {
            parameters.updateValue(group ?? "", forKey: Network.paramGroup)
        }
        
        Alamofire.request(
            baseURL + Network.weeklyScheduleListUrl + "/" + id,
            method: .put,
            parameters: parameters,
            headers: headers
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, error)
                        return
                    } else {
                        completion(false, localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                completion(true, "")
        }
    }
}

// MARK: - RealTime Schedule

extension NetworkManager {
    
    func getRealTimeScheduleList(token: String, sort: String, page: Int, perPage: Int, completion: @escaping (Bool, [RealTimeSchedule]?, PageInfo?, String) -> Void) {
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        // call API
        Alamofire.request(
            baseURL + Network.realTimeScheduleListUrl,
            method: .get,
            parameters: [Network.paramPage: page,
                         Network.paramPerPage: perPage,
                         Network.paramSort: sort],
            headers: headers
            )
            .responseJSON { response in
                
                // if result != isSuccess return error message
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, nil, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                // get json value
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, nil, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, nil, nil, error)
                        return
                    } else {
                        completion(false, nil, nil, localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                guard let displayCalendar = responseJSON[Network.paramDataList] as? [[String: Any]] else {
                    completion(false, nil, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                let realTimeScheduleList = displayCalendar.flatMap({ (dict) -> RealTimeSchedule? in
                    return RealTimeSchedule(dictionary: dict as NSDictionary)
                })
                
                guard let pageInfoDict = responseJSON[Network.paramPages] as? NSDictionary else {
                    completion(false, nil, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                let pageInfo = PageInfo(dictionary: pageInfoDict)
                completion(true, realTimeScheduleList, pageInfo, "")
        }
    }
    
    func editNameRealTimeSchedule(id: String, name: String, token: String, completion: @escaping (Bool, String) -> Void) {
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        Alamofire.request(
            baseURL + Network.realTimeScheduleListUrl + "/" + id,
            method: .put,
            parameters: [Network.paramName: name],
            headers: headers
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, error)
                        return
                    } else {
                        completion(false, localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                completion(true, "")
        }
    }
    
    func deleteRealTimeSchedule(id: String, token: String, completion: @escaping (Bool, String) -> Void) {
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        Alamofire.request(
            baseURL + Network.realTimeScheduleListUrl + "/" + id,
            method: .delete,
            headers: headers
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, error)
                        return
                    } else {
                        completion(false, localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                completion(true, "")
        }
    }
    
    func addRealTimeSchedule(name: String, token: String, completion: @escaping (Bool, String, String) -> Void) {
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        Alamofire.request(
            baseURL + Network.realTimeScheduleListUrl,
            method: .post,
            parameters: [Network.paramName: name],
            headers: headers
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, "", localizedString(key: "common_error_message"))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, "", localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, "", error)
                        return
                    } else {
                        completion(false, "", localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                guard let id = responseJSON[Network.paramId] as? String else {
                    completion(false, "", localizedString(key: "common_error_message"))
                    return
                }
                
                completion(true, id, "")
        }
    }
    
    func updateRealTimeSchedule(id: String, code: String?, name: Bool?, shortDescription: String?, displayCalendar: String?, group: String?, token: String, completion: @escaping (Bool, String) -> Void) {
        
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        var parameters: [String: Any] = [:]
        if code != nil {
            parameters.updateValue(code ?? "", forKey: Network.paramCode)
        }
        if name != nil {
            parameters.updateValue(name ?? "", forKey: Network.paramName)
        }
        if shortDescription != nil {
            parameters.updateValue(shortDescription ?? "", forKey: Network.paramShortDescription)
        }
        if displayCalendar != nil {
            parameters.updateValue(displayCalendar ?? "", forKey: Network.paramDisplayCalendar)
        }
        if group != nil {
            parameters.updateValue(group ?? "", forKey: Network.paramGroup)
        }
        
        Alamofire.request(
            baseURL + Network.realTimeScheduleListUrl + "/" + id,
            method: .put,
            parameters: parameters,
            headers: headers
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, error)
                        return
                    } else {
                        completion(false, localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                completion(true, "")
        }
    }
}

// MARK: - For Local

extension NetworkManager {
    
    func checkLocalAssetExist(pinCode: String, clientAddress: String, presentationId: String, data: String,
                              completion: @escaping (Bool, [[String: Any]]?, String) -> Void) {
        
        // encode params
        let paramsString = "pinCode=\(pinCode)&clientAddress=\(clientAddress)&presentationId=\(presentationId)&templateId=\(presentationId)&data=\(data)"
        let encodedParamsString = paramsString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        let url = "http://\(clientAddress):8080/isPresentationsUploaded?" + encodedParamsString
        
        Alamofire.request(
            url,
            method: .post
            //            parameters: ["pinCode": pinCode,
            //                         "clientAddress": clientAddress,
            //                         "presentationId": localPresentationId,
            //                         "templateId": presentationId,
            //                         "data": data]
            )
            .responseJSON { response in
                
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                guard let result = responseJSON["result"] as? Bool,
                    let message = responseJSON["message"] as? String else {
                        
                        completion(false, nil, localizedString(key: "common_error_message"))
                        return
                }
                
                if result == true {
                    guard let data = responseJSON["data"] as? [[String: Any]] else {
                        completion(false, nil, localizedString(key: "common_error_message"))
                        return
                    }
                    
                    completion(true, data, message)
                    return
                }
                
                completion(false, nil, message)
        }
    }
    
    func uploadZipFolderToDevice(clientAddress: String, contentId: String, zipFileName: String, zipData: Data, completion: @escaping (Bool, String) -> Void) {
        // encode params
        let paramsString = "name=\(contentId)&fileName=\(zipFileName)"
        let encodedParamsString = paramsString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        let url = "http://" + clientAddress + ":8080/?" + encodedParamsString
        
        dLog(message: "upload url = " + url)
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(zipData, withName: "", fileName: zipFileName, mimeType: "")
        },
            to: url,
            method: .post,
            encodingCompletion: { encodingResult in
                
                switch encodingResult {
                    
                case .success(let upload, _, _):
                    
                    upload.uploadProgress(closure: { (progress) in
                        dLog(message: "Upload Progress: \(progress.fractionCompleted)")
                    })
                    
                    upload.responseJSON { response in
                        
                        //                        guard response.result.isSuccess else {
                        //                            dLog(message: "Error while fetching data")
                        //                            completion(false, localizedString(key: "common_error_message"))
                        //                            return
                        //                        }
                        
                        // check status code != 200 && has error message from server -> process error
                        if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                            completion(false, localizedString(key: "common_error_message"))
                            return
                        }
                        
                        completion(true, "")
                    }
                    
                case .failure(let encodingError):
                    dLog(message: encodingError.localizedDescription)
                    completion(false, localizedString(key: "common_error_message"))
                }
            }
        )
    }
    
    func playLocalPresentation(pinCode: String, clientAddress: String, presentationId: String, completion: @escaping (Bool, String) -> Void) {
        
        // encode params
        let paramsString = "pinCode=\(pinCode)&clientAddress=\(clientAddress)&presentationId=\(presentationId)"
        let encodedParamsString = paramsString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!

        let url = "http://\(clientAddress):8080/displayPresentation?" + encodedParamsString

        Alamofire.request(
            url,
            method: .post
//            parameters: ["pinCode": pinCode,
//                         "clientAddress": clientAddress,
//                         "presentationId": localPresentationId]
            )
            .responseJSON { response in
                //                debugPrint(response)
                
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                guard let result = responseJSON["result"] as? Bool,
                    let message = responseJSON["message"] as? String else {
                        
                        completion(false, localizedString(key: "common_error_message"))
                        return
                }
                
                if result == true {
                    completion(true, message)
                    return
                }
                
                completion(false, message)
        }
    }
    
    func playLocalPlayList(pinCode: String, clientAddress: String, playListId: String, completion: @escaping (Bool, String) -> Void) {
        
        // encode params
        let paramsString = "pinCode=\(pinCode)&clientAddress=\(clientAddress)&playlistId=\(playListId)"
        let encodedParamsString = paramsString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        let url = "http://\(clientAddress):8080/displayPlaylist?" + encodedParamsString
        
        Alamofire.request(
            url,
            method: .post
            //            parameters: ["pinCode": pinCode,
            //                         "clientAddress": clientAddress,
            //                         "presentationId": localPresentationId]
            )
            .responseJSON { response in
                //                debugPrint(response)
                
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                guard let result = responseJSON["result"] as? Bool,
                    let message = responseJSON["message"] as? String else {
                        
                        completion(false, localizedString(key: "common_error_message"))
                        return
                }
                
                if result == true {
                    completion(true, message)
                    return
                }
                
                completion(false, message)
        }
    }
    
    func playLocalScheduleRealTime(pinCode: String, clientAddress: String, scheduleId: String, completion: @escaping (Bool, String) -> Void) {
        
        // encode params
        let paramsString = "pinCode=\(pinCode)&clientAddress=\(clientAddress)&scheduleId=\(scheduleId)"
        let encodedParamsString = paramsString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        let url = "http://\(clientAddress):8080/displayCalendar?" + encodedParamsString
        
        Alamofire.request(
            url,
            method: .post
            //            parameters: ["pinCode": pinCode,
            //                         "clientAddress": clientAddress,
            //                         "presentationId": localPresentationId]
            )
            .responseJSON { response in
                //                debugPrint(response)
                
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                guard let result = responseJSON["result"] as? Bool,
                    let message = responseJSON["message"] as? String else {
                        
                        completion(false, localizedString(key: "common_error_message"))
                        return
                }
                
                if result == true {
                    completion(true, message)
                    return
                }
                
                completion(false, message)
        }
    }
    
    func playLocalScheduleWeekly(pinCode: String, clientAddress: String, scheduleId: String, completion: @escaping (Bool, String) -> Void) {
        
        // encode params
        let paramsString = "pinCode=\(pinCode)&clientAddress=\(clientAddress)&scheduleId=\(scheduleId)"
        let encodedParamsString = paramsString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        let url = "http://\(clientAddress):8080/displaySchedule?" + encodedParamsString
        
        Alamofire.request(
            url,
            method: .post
            //            parameters: ["pinCode": pinCode,
            //                         "clientAddress": clientAddress,
            //                         "presentationId": localPresentationId]
            )
            .responseJSON { response in
                //                debugPrint(response)
                
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                guard let result = responseJSON["result"] as? Bool,
                    let message = responseJSON["message"] as? String else {
                        
                        completion(false, localizedString(key: "common_error_message"))
                        return
                }
                
                if result == true {
                    completion(true, message)
                    return
                }
                
                completion(false, message)
        }
    }
    
    func playLocalInstantMessage(pinCode: String, clientAddress: String, duration: String, position: String, imMessage: String, isTTS: String, ttsMessage: String, color: String, animationEffect: String, fontName: String, fontSize: String, topPosition: String, leftPosition: String, bold: String, italic: String, completion: @escaping (Bool, String) -> Void) {
        
//        let url = "http://" + clientAddress + ":8080/instantMessage"
        
        // encode params
        let paramsString = "pinCode=\(pinCode)&clientAddress=\(clientAddress)&duration=\(duration)&position=\(position)&imMessage=\(imMessage)&isTTS=\(isTTS)&ttsMessage=\(ttsMessage)&color=\(color)&animationEffect=\(animationEffect)&fontName=\(fontName)&fontSize=\(fontSize)&topPosition=\(topPosition)&leftPosition=\(leftPosition)&bold=\(bold)&italic=\(italic)"
        let encodedParamsString = paramsString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        let url = "http://\(clientAddress):8080/instantMessage?" + encodedParamsString
        
        Alamofire.request(
            url,
            method: .post
//            parameters: ["pinCode": pinCode,
//                         "clientAddress": clientAddress,
//                         "duration": duration,
//                         "position": position,
//                         "imMessage": imMessage,
//                         "isTTS": isTTS,
//                         "ttsMessage": ttsMessage,
//                         "color": color,
//                         "animationEffect": animationEffect,
//                         "fontName": fontName,
//                         "fontSize": fontSize,
//                         "topPosition": topPosition,
//                         "leftPosition": leftPosition,
//                         "bold": bold,
//                         "italic": italic]
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                guard let result = responseJSON["result"] as? Bool,
                    let message = responseJSON["message"] as? String else {
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                if result == true {
                    completion(true, message)
                    return
                }
                
                completion(false, message)
                return
        }
    }
}

// MARK: - Group
extension NetworkManager {
    
    func getGroupList(token: String, sort: String, page: Int, perPage: Int, completion: @escaping (Bool, [Group]?, PageInfo?, String) -> Void) {
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        // call API
        Alamofire.request(
            baseURL + Network.groupUrl,
            method: .get,
            parameters: [Network.paramPage: page,
                         Network.paramPerPage: perPage,
                         Network.paramSort: sort],
            headers: headers
            )
            .responseJSON { response in
                
                // if result != isSuccess return error message
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, nil, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                // get json value
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, nil, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, nil, nil, error)
                        return
                    } else {
                        completion(false, nil, nil, localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                guard let dataList = responseJSON[Network.paramDataList] as? [[String: Any]] else {
                    completion(false, nil, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                let groupList = dataList.flatMap({ (dict) -> Group? in
                    return Group(dictionary: dict as NSDictionary)
                })
                
                guard let pageInfoDict = responseJSON[Network.paramPages] as? NSDictionary else {
                    completion(false, nil, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                let pageInfo = PageInfo(dictionary: pageInfoDict)
                completion(true, groupList, pageInfo, "")
        }
    }
    
    func addGroup(name: String, contentType: String, token: String, completion: @escaping (Bool, String, String) -> Void) {
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        Alamofire.request(
            baseURL + Network.groupUrl,
            method: .post,
            parameters: [Network.paramName: name,
                         Network.paramContentType: contentType],
            headers: headers
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, "", localizedString(key: "common_error_message"))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, "", localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, "", error)
                        return
                    } else {
                        completion(false, "", localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                guard let id = responseJSON[Network.paramId] as? String else {
                    completion(false, "", localizedString(key: "common_error_message"))
                    return
                }
                
                completion(true, id, "")
        }
    }
    
    func editNameGroup(id: String, name: String, token: String, completion: @escaping (Bool, String) -> Void) {
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        Alamofire.request(
            baseURL + Network.groupUrl + "/" + id,
            method: .put,
            parameters: [Network.paramName: name],
            headers: headers
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, error)
                        return
                    } else {
                        completion(false, localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                completion(true, "")
        }
    }
    
    func deleteGroup(id: String, token: String, completion: @escaping (Bool, String) -> Void) {
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        Alamofire.request(
            baseURL + Network.groupUrl + "/" + id,
            method: .delete,
            headers: headers
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, error)
                        return
                    } else {
                        completion(false, localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                completion(true, "")
        }
    }
}

// MARK: - Dataset

extension NetworkManager {
    
    func getDatasetList(filter: String, sort: String, token: String, page: Int, perPage: Int, completion: @escaping (Bool, [Dataset]?, PageInfo?, String) -> Void) {
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        Alamofire.request(baseURL + Network.datasetUrl,
                          method: HTTPMethod.get,
                          parameters: [Network.paramFilter: filter,
                                       Network.paramPage: page,
                                       Network.paramPerPage: perPage,
                                       Network.paramSort: sort],
                          encoding: JSONEncoding.default,
                          headers: headers
            ).responseJSON { response in
                
                // if result != isSuccess return error message
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, nil, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                // get json value
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, nil, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, nil, nil, error)
                        return
                    } else {
                        completion(false, nil, nil, localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                guard let dataList = responseJSON[Network.paramDataList] as? [[String: Any]] else {
                    completion(false, nil, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                let datasetList = dataList.flatMap({ (dict) -> Dataset? in
                    return Dataset(dictionary: dict as NSDictionary)
                })
                
                guard let pageInfoDict = responseJSON[Network.paramPages] as? NSDictionary else {
                    completion(false, nil, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                let pageInfo = PageInfo(dictionary: pageInfoDict)
                completion(true, datasetList, pageInfo, "")
        }
    }
    
    func addDataset(dataset: Dataset, token: String, completion: @escaping (Bool, String, String) -> Void) {
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        Alamofire.request(
            baseURL + Network.datasetUrl,
            method: .post,
            parameters: [Network.paramName: dataset.name,
                         Network.paramColumns: dataset.columns.toJsonString()],
            headers: headers
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, "", localizedString(key: "common_error_message"))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, "", localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, "", error)
                        return
                    } else {
                        completion(false, "", localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                guard let id = responseJSON[Network.paramId] as? String else {
                    completion(false, "", localizedString(key: "common_error_message"))
                    return
                }
                
                completion(true, id, "")
        }
    }


    func updateDataset(id: String, name: String?, columns: [DatasetType]?, data: [DatasetData]?, token: String, completion: @escaping (Bool, String) -> Void) {
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        var parameters: [String: Any] = [:]

        if name != nil {
            parameters.updateValue(name ?? "", forKey: Network.paramName)
        }
        if columns != nil {
            parameters.updateValue(columns?.toJsonString() ?? "", forKey: Network.paramColumns)
        }
        if data != nil {
            parameters.updateValue(data?.toJsonString() ?? "", forKey: Network.paramData)
        }
        
        Alamofire.request(
            baseURL + Network.datasetUrl + "/" + id,
            method: .put,
            parameters: parameters,
            headers: headers
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, error)
                        return
                    } else {
                        completion(false, localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                completion(true, "")
        }
    }
    
    func deleteDataset(id: String, token: String, completion: @escaping (Bool, String) -> Void) {
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        Alamofire.request(
            baseURL + Network.datasetUrl + "/" + id,
            method: .delete,
            headers: headers
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, error)
                        return
                    } else {
                        completion(false, localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                completion(true, "")
        }
    }
}

// MARK: - Display Event

extension NetworkManager {
    
    func getDisplayEventList(token: String, sort: String, page: Int, perPage: Int, completion: @escaping (Bool, [DisplayEvent]?, PageInfo?, String) -> Void) {
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        // call API
        Alamofire.request(
            baseURL + Network.displayEventUrl,
            method: .get,
            parameters: [Network.paramPage: page,
                         Network.paramPerPage: perPage,
                         Network.paramSort: sort],
            headers: headers
            )
            .responseJSON { response in
                
                // if result != isSuccess return error message
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, nil, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                // get json value
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, nil, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, nil, nil, error)
                        return
                    } else {
                        completion(false, nil, nil, localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                guard let dataList = responseJSON[Network.paramDataList] as? [[String: Any]] else {
                    completion(false, nil, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                let displayEventList = dataList.flatMap({ (dict) -> DisplayEvent? in
                    return DisplayEvent(dictionary: dict as NSDictionary)
                })
                
                guard let pageInfoDict = responseJSON[Network.paramPages] as? NSDictionary else {
                    completion(false, nil, nil, localizedString(key: "common_error_message"))
                    return
                }
                
                let pageInfo = PageInfo(dictionary: pageInfoDict)
                completion(true, displayEventList, pageInfo, "")
        }
    }
    
    func addDisplayEvent(name: String, duration: Int, eventType: String, playTime: String, data: String, token: String, completion: @escaping (Bool, String, String) -> Void) {
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        Alamofire.request(
            baseURL + Network.displayEventUrl,
            method: .post,
            parameters: [Network.paramName: name,
                         Network.paramDuration: duration,
                         Network.paramEventType: eventType,
                         Network.paramPlayTime: playTime,
                         Network.paramData: data],
            headers: headers
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, "", localizedString(key: "common_error_message"))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, "", localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, "", error)
                        return
                    } else {
                        completion(false, "", localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                guard let id = responseJSON[Network.paramId] as? String else {
                    completion(false, "", localizedString(key: "common_error_message"))
                    return
                }
                
                completion(true, id, "")
        }
    }
    
    func deleteDisplayEvent(id: String, token: String, completion: @escaping (Bool, String) -> Void) {
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        Alamofire.request(
            baseURL + Network.displayEventUrl + "/" + id,
            method: .delete,
            headers: headers
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, error)
                        return
                    } else {
                        completion(false, localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                completion(true, "")
        }
    }
    
    func editDisplayEvent(id: String, name: String, duration: Int, eventType: String, playTime: String, data: String, token: String, completion: @escaping (Bool, String) -> Void) {
        // create header to add token
        let headers: HTTPHeaders = [
            Network.paramAccessToken: token
        ]
        
        Alamofire.request(
            baseURL + Network.displayEventUrl + "/" + id,
            method: .put,
            parameters: [Network.paramName: name,
                         Network.paramDuration: duration,
                         Network.paramEventType: eventType,
                         Network.paramPlayTime: playTime,
                         Network.paramData: data],
            headers: headers
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    dLog(message: "Error while fetching data")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    dLog(message: "didn't get todo object as JSON from API")
                    completion(false, localizedString(key: "common_error_message"))
                    return
                }
                
                // check status code != 200 && has error message from server -> process error
                if response.response?.statusCode != self.STATUS_CODE_SUCCESS {
                    if let error = responseJSON[Network.paramDesc] as? String {
                        dLog(message: "Error while fetching data")
                        completion(false, error)
                        return
                    } else {
                        completion(false, localizedString(key: "common_error_message"))
                        return
                    }
                }
                
                completion(true, "")
        }
    }
}
