//
//  WacaChannelModel.swift
//  Example
//
//  Created by arief nur putranto on 29/06/22.
//  Copyright © 2022 Qiscus. All rights reserved.
//

import Foundation
import SwiftyJSON

public class WacaChannelModel : NSObject {
    var id : Int = 0
    var name : String = ""
    var isSelected: Bool = false
    init(json: JSON) {
        self.id             = json["id"].int ?? 0
        self.name           = json["name"].string ?? "Waca"
        self.isSelected     = false
    }
}
