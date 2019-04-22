//
//  WREvent.swift
//  Pods
//
//  Created by wayfinder on 2017. 4. 29..
//
//

import UIKit
import DateToolsSwift

open class WREvent: TimePeriod {
    open var title: String = ""
    open var id: String = ""
    open var color: String = ""
    
    // for weekly
    open var startDay: String = ""
    open var startTime: Int = 0
    open var duration: Int = 0
    
    open class func make(date:Date, chunk: TimeChunk, title: String) -> WREvent {
        let event = WREvent(beginning: date, chunk: chunk)
        event.title = title
        
        return event
    }
    
    open class func make(id: String, startDate: Date, endDate: Date, title: String, color: String) -> WREvent {
        let event = WREvent(beginning: startDate, end: endDate)
        event.title = title
        event.id = id
        event.color = color
        
        return event
    }
    
    // for weekly
    open class func make(id: String, startDay: String, duration: Int, startTime: Int, title: String, color: String) -> WREvent {
        let event = WREvent.init()
        event.id = id
        event.startDay = startDay
        event.duration = duration
        event.startTime = startTime
        event.title = title
        event.color = color
        
        return event
    }
}
