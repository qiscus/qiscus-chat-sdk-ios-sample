//
//  CustomerProperties.swift
//  Example
//
//  Created by arief nur putranto on 10/12/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import Foundation
import SwiftyJSON

public class CustomerProperties : NSObject {
    var id : Int = 0
    var label : String = ""
    var value: String = ""
    init(json: JSON) {
        self.id             = json["id"].int ?? 0
        self.label          = json["label"].string ?? "-"
        self.value          = json["value"].string ?? "-"
    }
}
