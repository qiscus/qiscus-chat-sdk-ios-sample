//
//  BroadCastHistoryModel.swift
//  Example
//
//  Created by Qiscus on 13/12/20.
//  Copyright © 2020 Qiscus. All rights reserved.
//

import Foundation
import SwiftyJSON

public class BroadCastHistoryModel : NSObject {
    var id : String = ""
    var customerName : String = ""
    var message : String = ""
    var messageId : String = ""
    var phoneNumber : String = ""
    var sentAt : String = ""
    var status : Int = 4
    var templateName : String = "-"
    var header  : String = ""
    var footer : String = ""
    var button : String = ""
    
    init(json: JSON) {
        self.id             = json["id"].string ?? ""
        self.customerName           = json["customer_name"].string ?? ""
        self.message      = json["message"].string ?? ""
        self.messageId         = json["message_id"].string ?? ""
        self.phoneNumber    = json["phone_number"].string ?? ""
        self.sentAt = json["sent_at"].string ?? ""
        self.status = json["status"].int ?? 4
        self.templateName = json["template_name"].string ?? "-"
        self.header = json["header_value"].string ?? ""
        self.footer = json["footer_value"].string ?? ""
        let buttonData = json["button_params"].string ?? ""
        
        if buttonData == "[]" {
            self.button = ""
        }else{
            self.button = buttonData
        }
        
    }
    
    func getDate() -> Date {
        //let timezone = TimeZone.current.identifier
        let formatter = DateFormatter()
        formatter.dateFormat    = "yyyy-MM-dd'T'HH:mm:ssZ"
        //formatter.timeZone      = TimeZone(secondsFromGMT: 0)
        formatter.timeZone      = TimeZone(abbreviation: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let date = formatter.date(from: self.sentAt)
        return date ?? Date()
    }
    
    func hour(date: Date?) -> String {
        guard let date = date else {
            return "-"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        formatter.timeZone      = TimeZone.current
        let defaultTimeZoneStr = formatter.string(from: date);
        return defaultTimeZoneStr
    }
    
    func dateString(date: Date?) -> String {
        guard let date = date else {
            return "-"
        }
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone      = TimeZone.current
        dateFormatter.dateFormat = "dd MMMM YYYY"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
}

