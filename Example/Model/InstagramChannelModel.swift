//
//  InstagramChannelModel.swift
//  Example
//
//  Created by Qiscus on 18/11/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import Foundation
import SwiftyJSON

public class InstagramChannelModel : NSObject {
    var id : Int = 0
    var name : String = ""
    var username: String = ""
    var isSelected: Bool = false
    init(json: JSON) {
        self.id             = json["id"].int ?? 0
        self.name           = json["name"].string ?? ""
        self.username       = json["username"].string ?? ""
        self.isSelected     = false
    }
}
