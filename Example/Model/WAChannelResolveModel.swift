//
//  WAChannelResolveModel.swift
//  Example
//
//  Created by Qiscus on 07/06/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import Foundation
import SwiftyJSON
public class WAChannelResolveModel : NSObject {
    var channelId : Int = 0
    var channelName : String = ""
    var totalRooms: Int = 0
    var inProgressResolve = false
    var isWaiting = true
    var progressStatus = ""
    var progressSuccess = 0
    var progressFailed = 0
    var progressProcessed = 0
    var progressTotal = 0
    
    init(json: JSON) {
        self.channelId             = json["channel_id"].int ?? 0
        self.channelName           = json["channel_name"].string ?? ""
        self.totalRooms             = json["total_rooms"].int ?? 0
    }
}
