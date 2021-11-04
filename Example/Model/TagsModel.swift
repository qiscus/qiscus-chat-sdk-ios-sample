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
    var createdAt : String = ""
    var updatedAt : String = ""
    var roomTagCreated : String = ""
    var dictio : [String: Any] = [String:Any]()
    var completeDict: [String: Any] = [String:Any]()
    
    init(json: JSON) {
        self.id             = json["id"].int ?? 0
        self.name           = json["name"].string ?? ""
        self.createdAt      = json["created_at"].string ?? ""
        self.updatedAt      = json["updated_at"].string ?? ""
        self.roomTagCreated = json["room_tag_created"].string ?? ""
        self.dictio = ["id": id, "name": name]
        self.completeDict = ["id": id, "name": name, "created_at" : createdAt, "updated_at" : updatedAt, "room_tag_created" : roomTagCreated ]
    }
    
    init(id: Int, name : String) {
        self.id             = id
        self.name           = name
        self.dictio = ["id": id, "name": name]
    }
}
