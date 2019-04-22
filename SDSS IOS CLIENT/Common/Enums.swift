//
//  Enums.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 30/05/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import Foundation
import UIKit

enum Alignment {
    case topLeft
    case topCenter
    case topRight
    case middleLeft
    case middleCenter
    case middleRight
    case bottomLeft
    case bottomCenter
    case bottomRight
    
    func positionName() -> String {
        switch self {
        case .topLeft:
            return "topleft"
        case .topCenter:
            return "topcenter"
        case .topRight:
            return "topright"
        case .middleLeft:
            return "middleleft"
        case .middleCenter:
            return "middlecenter"
        case .middleRight:
            return "middleright"
        case .bottomLeft:
            return "bottomleft"
        case .bottomCenter:
            return "bottomcenter"
        case .bottomRight:
            return "bottomright"
        }
    }
    
    func selectedImageName() -> String {
        switch self {
        case .topLeft:
            return "icon_align_left_top_sel"
        case .topCenter:
            return "icon_align_middle_top_sel"
        case .topRight:
            return "icon_align_right_top_sel"
        case .middleLeft:
            return "icon_align_left_center_sel"
        case .middleCenter:
            return "icon_align_middle_center_sel"
        case .middleRight:
            return "icon_align_right_center_sel"
        case .bottomLeft:
            return "icon_align_left_bottom_sel"
        case .bottomCenter:
            return "icon_align_middle_bottom_sel"
        case .bottomRight:
            return "icon_align_right_bottom_sel"
        }
    }
    
    func tag() -> Int {
        switch self {
        case .topLeft:
            return 1
        case .topCenter:
            return 2
        case .topRight:
            return 3
        case .middleLeft:
            return 4
        case .middleCenter:
            return 5
        case .middleRight:
            return 6
        case .bottomLeft:
            return 7
        case .bottomCenter:
            return 8
        case .bottomRight:
            return 9
        }
    }
}

enum MediaType {
    case webpage
    case image
    case video
    case text
    case frame
    case widget
    
    func name() -> String {
        switch self {
        case .webpage:
            return "WEBPAGE"
        case .image:
            return "IMAGE"
        case .video:
            return "VIDEO"
        case .text:
            return "TEXT"
        case .frame:
            return "FRAME"
        case .widget:
            return "WIDGET"
        }
    }
    
    func imageName() -> String {
        switch self {
        case .webpage:
            return "icon_right_menu_website"
        case .image:
            return "icon_right_menu_image"
        case .video:
            return "icon_right_menu_video"
        case .text:
            return "icon_right_menu_text"
        case .frame:
            return "icon_right_menu_shape"
        case .widget:
            return "icon_right_menu_widget"
        }
    }
}

enum ImageAssetType {
    case localImage
    case image
    
    func name() -> String {
        switch self {
        case .localImage:
            return "LOCALIMAGE"
        case .image:
            return "IMAGE"
        }
    }
}

enum VideoAssetType {
    case localVideo
    case youtubeVideo
    
    func name() -> String {
        switch self {
        case .localVideo:
            return "LOCALVIDEO"
        case .youtubeVideo:
            return "YOUTUBEVIDEO"
        }
    }
}

enum TextAlignType {
    case left
    case right
    case center
    
    func name() -> String {
        switch self {
        case .left:
            return "left"
        case .right:
            return "right"
        case .center:
            return "center"
        }
    }
}

enum WebAssetType {
    case remote
    
    func name() -> String {
        switch self {
        case .remote:
            return "REMOTEWEBPAGE"
        }
    }
}

enum ShapeAssetType {
    case rectangle
    case circle
    
    func name() -> String {
        switch self {
        case .rectangle:
            return "RECT"
        case .circle:
            return "ELLIPSE"
        }
    }
}

enum ShapeLinePatternType {
    case solid
    case dotted
    case dashed
    
    func name() -> String {
        switch self {
        case .solid:
            return "SOLID"
        case .dotted:
            return "DOTTED"
        case .dashed:
            return "DASHED"
        }
    }
}

enum FontStyle {
    case bold
    case italic
    case underline
    case strikethrough
    case regular
    
    func name() -> String {
        switch self {
        case .bold:
            return "bold"
        case .italic:
            return "italic"
        case .underline:
            return "underline"
        case .strikethrough:
            return "strikethrough"
        case .regular:
            return "regular"
        }
    }
}

enum DeviceListType {
    case unknown
    case instantMessage
    case presentation
    case playList
    case realTimeSchedule
    case weeklySchedule
    case dataset
    case asset
}

enum ContentType {
    case presentation
    case playlist
    case weeklySchedule
    case realtimeSchedule
    case dataset
    case asset
    
    func name() -> String {
        switch self {
        case .presentation:
            return "PRESENTATION"
        case .playlist:
            return "PLAYLIST"
        case .weeklySchedule:
            return "WEEKLY_SCHEDULE"
        case .realtimeSchedule:
            return "REALTIME_SCHEDULE"
        case .dataset:
            return "DATASET"
        case .asset:
            return "ASSET"
        }
        
    }
}

enum BgImageType {
    case localImage
    case remoteImage
    case color
    
    func name() -> String {
        switch self {
        case .localImage:
            return "LOCAL_IMAGE"
        case .remoteImage:
            return "REMOTE_IMAGE"
        case .color:
            return "COLOR"
        }
    }
}

enum ScheduleType {
    case realTime
    case weekly
}

enum WeekType {
    case sun
    case mon
    case tue
    case wed
    case thu
    case fri
    case sat
    
    func weekString() -> String {
        switch self {
        case .sun:
            return "SUNDAY"
        case .mon:
            return "MONDAY"
        case .tue:
            return "TUESDAY"
        case .wed:
            return "WEDNESDAY"
        case .thu:
            return "THURSDAY"
        case .fri:
            return "FRIDAY"
        case .sat:
            return "SATURDAY"
        }
    }
    
    func tag() -> Int {
        switch self {
        case .sun:
            return 1
        case .mon:
            return 2
        case .tue:
            return 3
        case .wed:
            return 4
        case .thu:
            return 5
        case .fri:
            return 6
        case .sat:
            return 7
        }
    }
}

enum DeviceStatus {
    case online
    case offline
    
    func statusString() -> String {
        switch self {
        case .online:
            return "ONLINE"
        case .offline:
            return "OFFLINE"
        }
    }
}

enum EditImageType {
    case normal
    case background
}

enum WidgetType {
    case local
    case cloud
    case remote
    
    func name() -> String {
        switch self {
        case .local:
            return "LOCAL"
        case .cloud:
            return "CLOUD"
        case .remote:
            return "REMOTE"
        }
    }
}

enum TagType {
    case none
    case catalogue
    case userGroup
    case description
    
    func name() -> String {
        switch self {
        case .none:
            return "NONE"
        case .catalogue:
            return "CATALOGUE"
        case .userGroup:
            return "USER_GROUP"
        case .description:
            return "DESCRIPTION"
        }
    }
}

enum AssetType {
    case none
    case image
    case video
    
    func name() -> String {
        switch self {
        case .none:
            return "NONE"
        case .image:
            return "IMAGE"
        case .video:
            return "VIDEO"
        }
    }
}

enum OnOffType {
    case bold
    case italic
    case fullScreen
    case schedule
    case loop
}
