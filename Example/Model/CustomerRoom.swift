//
//  RoomListModel.swift
//  QiscusCore
//
//  Created by arief nur putranto on 26/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//
import Foundation
import SwiftyJSON
import QiscusCore

public class CustomerRoom : NSObject {
    var id : String = ""
    var name : String = ""
    var roomId : String = ""
    var avatarUrl : String? = nil
    var source : String = ""
    var lastComment : String = ""
    var lastCommentSender: String = ""
    var lastCommentTimestamp : String = ""
    var lastCustomerTimestamp : String = ""
    var isResolved : Bool = false
    var isWaiting : Bool = false
    var isHandledByBot : Bool = false
    var badge: String? = nil
    var lastCommentUnixTimestamp: Int64 = 0
 
    init(json: JSON) {
        self.id             = json["id"].stringValue
        self.name           = json["name"].stringValue
        self.roomId         = json["room_id"].stringValue
        self.avatarUrl      = json["user_avatar_url"].string ?? nil
        self.source         = json["source"].string ?? ""
        self.lastComment    = json["last_comment_text"].string ?? ""
        self.lastCommentSender = json["last_comment_sender"].string ?? ""
        self.lastCommentTimestamp   = json["last_comment_timestamp"].string ?? ""
        self.lastCustomerTimestamp = json["last_customer_timestamp"].string ?? ""
        self.isResolved     = json["is_resolved"].bool ?? false
        self.isWaiting      = json["is_waiting"].bool ?? false
        self.isHandledByBot  = json["is_handled_by_bot"].bool ?? false
        self.badge          = json["room_badge"].string ?? nil
    }
    
    init(roomSDK : RoomModel){
        self.id                     = roomSDK.id
        self.name                   = roomSDK.name
        self.roomId                 = roomSDK.id
        self.avatarUrl              = roomSDK.avatarUrl?.absoluteString
        self.lastComment            = roomSDK.lastComment?.message ?? ""
        self.lastCommentSender      = roomSDK.lastComment?.username ?? ""
        self.lastCommentTimestamp   = roomSDK.lastComment?.timestamp ?? ""
        self.lastCommentUnixTimestamp = roomSDK.lastComment?.unixTimestamp ?? 0
        self.lastCustomerTimestamp  = ""
        self.isWaiting = false
        self.isResolved = false
        self.badge = nil
        self.source = ""
        self.isHandledByBot = false
        
        if let option = roomSDK.options{
            if !option.isEmpty{
                let json = JSON.init(parseJSON: option)
                let is_resolved = json["is_resolved"].bool ?? false
                let isWaiting = json["is_waiting"].bool ?? false
                let badge = json["room_badge"].string ?? nil
                let source = json["channel"].string ?? ""
                let lastCustomerTime = json["last_customer_message_timestamp"].string ?? ""
                let bot = json["is_handled_by_bot"].bool ?? false
                
                
                self.source = source
                self.isResolved = is_resolved
                self.isWaiting = isWaiting
                self.badge = badge
                self.lastCustomerTimestamp = lastCustomerTime
                self.isHandledByBot = bot
            }
        }
        
    }
    
}


