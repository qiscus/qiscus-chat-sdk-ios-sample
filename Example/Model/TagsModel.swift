//
//  TagsModel.swift
//  Example
//
//  Created by Qiscus on 12/11/20.
//  Copyright © 2020 Qiscus. All rights reserved.
//

import Foundation
import SwiftyJSON

public class TagsModel : NSObject {
    var id : Int = 0
    var name : String = ""
    var dictio : [String: Any] = [String:Any]()
    
    init(json: JSON) {
        self.id             = json["id"].int ?? 0
        self.name           = json["name"].string ?? ""
        self.dictio = ["id": id, "name": name]
    }
    
    init(id: Int, name : String) {
        self.id             = id
        self.name           = name
        self.dictio = ["id": id, "name": name]
    }
}
