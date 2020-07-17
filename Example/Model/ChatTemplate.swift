//
//  ChatTemplate.swift
//  Example
//
//  Created by Qiscus on 17/07/20.
//  Copyright © 2020 Qiscus. All rights reserved.
//

import Foundation
import SwiftyJSON

public class ChatTemplate : NSObject {
    var id : Int = 0
    var command : String = ""
    var message : String = ""
    var appID : Int = 0
 
    init(json: JSON) {
        self.id            = json["id"].int ?? 0
        self.command       = json["command"].string ?? ""
        self.message       = json["message"].string ?? ""
        self.appID         = json["app_id"].int ?? 0
        
    }
    
}


