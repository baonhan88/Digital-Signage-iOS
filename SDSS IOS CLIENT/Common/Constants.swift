//
//  Constants.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 24/04/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import Foundation
import UIKit

// MARK: - For Presentation Editor screen
public let kMinimumZoomScale: CGFloat = 1.0
public let kMaximumZoomScale: CGFloat = 6.0
public let kDoubleTapZoomScale: CGFloat = 4.0

public let kRightMenuZoomScale: CGFloat = 2.0
public let kRightMenuBorderWidth: CGFloat = 3.0
public let kRightMenuBorderColor: UIColor = UIColor.blue

public let kMinNameLength = 4
public let kMaxNameLength = 126

public let kShowHubDismissTime = 3

public let kFontNameList = ["Arial", "Anton", "Josefin Sans", "Lobster", "Lora", "Open Sans", "Oswald", "Roboto", "BM HANNA_TTF", "JejuGothic", "JejuHallasan", "JejuMyeongjo", "KoPub Batang", "Nanum Brush Script", "NanumGothic", "NanumGothicCoding", "NanumMyeongjo", "Nanum Pen"]
public let kFontDefaultIndex = 5 // Open Sans

public let kLinePatternList = ["SOLID", "DOTTED", "DASHED"]
public let kLinePatternDefault = 0

// for PlayList
public let kPlayListMinDuration = 5 // 5 seconds
public let kPlayListDurationDefault = 1800 // 30 mins

// for Schedule
public let kScheduleMinDuration = 30 // 30 mins
public let kScheduleHourGripDivisionValue = 30 // 30 mins

// MARK: - Others Constants

// define all constant for Network
struct Network {
    // Common
    static let perPage = 30
    
    // URL for API Server
    static let baseURL = "https://api.cublick.com/v1"
//    static let baseURL = "https://api.dev.cublick.com"

    static let loginUrl = "/login"
    static let registerUrl = "/user"
    
    static let deviceUrl = "/auth/devices"
    static let activateUrl = "/auth/devices/activate"
//    static let playEventMessageUrl = "/auth/devices/playeventmessage"
    static let downloadSnapshotUrl = "/auth/devices/%@/snapshot?access_token=%@"
    static let controlDeviceToPlayUrl = "/auth/devices/control_play"
    static let controlDeviceToSnapshotUrl = "/auth/devices/control_to_snapshot"
    static let controlDeviceToUpdateUrl = "/auth/devices/control_update"
    static let controlDeviceEventUrl = "/auth/devices/control_event"
    static let controlDeviceUrl = "/auth/devices/control"
    
    static let tagUrl = "/auth/tags"
    static let tagThumbnailUrl = "/auth/tags/%@/thumbnail?access_token=%@"
    
    static let presentationUrl = "/auth/presentations"
    static let presentationThumbnailUrl = "/auth/presentations/%@/thumbnail?access_token=%@"
    static let downloadPresentationDesignDataUrl = "/auth/presentations/%@/designdata"
    static let updatePresentationThumbnailUrl = "/auth/presentations/%@/thumbnail"
//        static let presentationThumbnailUrl = "presentation/%@.png"
    
    static let presentationPublicUrl = "/auth/presentation_publics"
    static let presentationPublicCopyItToMineUrl = "/auth/presentation_publics/%@/copytomine"

    static let boughtPresentationUrl = "/auth/bought_presentations"
    
    static let downloadPresentationAssetUrl = "/auth/assets/%@/data"
    static let checkAssetExistUrl = "/auth/assets/check_exist"
    static let createAssetUrl = "/auth/assets"
    static let assetThumbnailUrl = "/auth/assets/%@/thumbnail?access_token=%@"
    
    static let playListUrl = "/auth/playlists"
    
    static let weeklyScheduleListUrl = "/auth/weekly_schedules"
    static let realTimeScheduleListUrl = "/auth/real_time_schedules"
    
    static let widgetRenderContentUrl = "/auth/widget_instants/%@/content"
    
    static let groupUrl = "/auth/groups"
    
    static let datasetUrl = "/auth/data_sets"
    
    static let displayEventUrl = "/auth/display_events"

    // URL for Clouse Server
    static let cloudServerUrl = "http://api.evnage.com/"
//        static let presentationThumbnailUrl = "v1/templates/%@/thumbnail"

    /***************** BEGIN - PARAM *******************/
    // Common
    static let paramToken = "token"
    static let paramId = "id"
    static let paramSuccess = "success"
    static let paramError = "error"
    static let paramInfo = "info"
    static let paramMessage = "message"
    static let paramData = "data"
    static let paramContentData = "contentData"
    static let paramName = "name"
    static let paramPage = "page"
    static let paramPerPage = "perPage"
    static let paramSort = "sort"
    static let paramOrder = "order"
    static let paramFilterLock = "_lock"
    static let paramDataList = "data"
    static let paramPages = "pages"
    static let paramItems = "items"
    static let paramFilter = "filter"
    static let paramDesc = "desc"
    
    static let paramCurrent = "current"
    static let paramPrev = "prev"
    static let paramHasPrev = "hasPrev"
    static let paramNext = "next"
    static let paramHasNext = "hasNext"
    static let paramTotal = "total"
    
    static let paramAccessToken = "X-Access-Token"
    
    static let paramUpdatedDate = "updatedDate"
    static let paramStatus = "status"
    static let paramOwner = "owner"
    static let paramSymbolUrl = "symbolUrl"
    
    static let paramAction = "action"
    static let paramIdList = "IDList"

    // for User
    static let paramUsername = "username"
    static let paramDisplayName = "displayName"
    static let paramEmail = "email"
    static let paramAvatarUrl = "avatarUrl"
    static let paramPassword = "password"
    
    // for Location
    static let paramLocation = "location"
    static let paramLatitude = "latitude"
    static let paramLongitude = "longitude"
    
    // for Device
    static let paramPinCode = "pinCode"
    static let paramSocketId = "socketId"
    static let paramOverlayingEvent = "overlayingEvent"
    static let paramHoldingPresentationId = "holdingPresentationId"
    static let paramHoldingContentId = "holdingContentId"
    static let paramHoldingContentType = "holdingContentType"
    static let paramPlayingPresentationId = "playingPresentationId"
    static let paramPlayingContentId = "playingContentId"
    static let paramPlayingContentType = "playingContentType"
    static let paramIsRealTime = "isRealTime"
    static let paramActivatedDate = "activatedDate"
    static let paramLastAccessDate = "lastAccessDate"
    static let paramRegisteredDate = "registeredDate"
    static let paramProducedDate = "producedDate"
    static let paramSoftwareVersion = "softwareVersion"
    static let paramOsVersion = "osVersion"
    static let paramOperationSystem = "operationSystem"
    static let paramLiveStatus = "liveStatus"
    static let paramSnapshotPath = "snapshotPath"
    static let paramDisplayHeight = "displayHeight"
    static let paramDisplayWidth = "displayWidth"
    static let paramMacAddress = "macAddress"
    static let paramIpAddress = "ipAddress"
    static let paramEventType = "eventType"
    static let paramPlayTime = "playTime"
    static let paramDuration = "duration"
    static let paramPinCodeList = "pinCodeList"
    static let paramContentId = "contentId"
    static let paramContentType = "contentType"
    static let paramContentName = "contentName"
    static let paramDeviceList = "deviceList"
    static let paramDeviceContent = "content"
    static let paramDeviceScheduleContent = "scheduleContent"
    static let paramDeviceEvents = "events"
    static let paramDeviceIsDim = "isDim"
    static let paramDevicePlayStatus = "playStatus"
    static let paramDeviceGroup = "group"
    static let paramDeviceAutoScale = "autoScale"
    
    // for Tag
    static let paramValue = "value"
    static let paramCreatedDate = "createdDate"
    static let paramAccessRight = "accessRight"
    static let paramIsSystem = "isSystem"
    static let paramIsPrivate = "isPrivate"
    static let paramUpdater = "updater"
    static let paramTagType = "tagType"
    static let paramFilterTagType = "_tagType"
    
    // for Asset
    static let paramMd5 = "md5"
    static let paramExt = "ext"
    static let paramMd5s = "md5s"
    static let paramAssets = "assets"
    static let paramFile = "file"
    static let paramAssetType = "_assetType"
    
    // for Presentation
    static let paramViewCount = "viewCount"
    static let paramDownloadCount = "downloadCount"
    static let paramTags = "tags"
    static let paramAssetList = "assetList"
    static let paramBgAudioEnable = "bgAudioEnable"
    static let paramHeight = "height"
    static let paramWidth = "width"
    static let paramRatio = "ratio"
    static let paramOrientation = "orientation"
    static let paramLock = "lock"
    static let paramShortDescription = "shortDescription"
    static let paramCode = "code"
    static let paramCategory = "_category"
    static let paramThumbnailUrl = "thumbnailUrl"
    static let paramRegions = "regions"
    static let paramBgImage = "bgImage"
    static let paramGroup = "group"
    
    // for BoughtPresentation
    static let paramPresentationId = "presentationId"
    static let paramECoinXorF = "eCoinXorF"
    
    // for PlayList
    static let paramTotalTime = "totalTime"
    static let paramDisplayList = "displayList"
    
    // for RealTime Schedule
    static let paramDisplayCalendar = "displayCalendar"
    
    // for Weekly Schedule
    static let paramDisplaySchedule = "displaySchedule"
    
    // for Dataset
    static let paramColumns = "columns"
    
    
    /***************** END - PARAM *******************/
    
}

struct Dir {
    static let snapshot = "Snapshot/"
    static let assets = "TemplateAssets/"
    static let template = "Template/"
    static let templateThumbnail = "TemplateThumbnail/"
    static let savePresentation = "PresentationSaved/"

    static let templateSlideFile = "templateSlide.json"
    
    static let tmpFolderName = "tmp"
    static let forZipFolderName = "ForZip"

    static let presentationDesignExtension = ".evt"
    static let presentationThumbnailExtension = ".png"
    static let cameraRollImageExtension = ".png"
    static let cameraRollVideoExtension = ".mp4"
    
    static let playListDesignExtension = ".evpl"
    static let scheduleDesignExtension = ".evsch"
}

struct DesignFile {
    static let paramPresentationInfo = "presentationInfo"
    static let paramRegions = "regions"
}

struct Socket {
    static let socketPrefix = "SDSSStandalone"
    static let socketSeparator = "#"
    static let deviceType = "ios"
    static let packageType = "discovery"
    static let port = 51234
    static let timeout = 2500
    static let sendBroadcastDelayTime = 3
}

struct ErrorCode {
    static let unavaiable = 460
    static let invalidData = 461
}

