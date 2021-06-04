//
//  FBChannelModel.swift
//  Example
//
//  Created by Qiscus on 15/04/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import Foundation
import SwiftyJSON

public class FBChannelModel : NSObject {
    var id : Int = 0
    var name : String = ""
    var isSelected: Bool = false
    init(json: JSON) {
        self.id             = json["id"].int ?? 0
        self.name           = json["profile_name"].string ?? "Facebook"
        self.isSelected     = false
    }
}
