//
//  FeaturesModel.swift
//  Example
//
//  Created by Qiscus on 10/05/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import Foundation
import SwiftyJSON

public class FeaturesModel : NSObject {
    var caption : String = ""
    var features = [Features]()
    var id : Int = 0
    var level: Int = 0
    var name : String = ""
    var status: Int = 0
    var section : String = ""
    init(json: JSON) {
        self.caption            = json["caption"].string ?? ""
        self.id                 = json["id"].int ?? 0
        self.level              = json["level"].int ?? 0
        self.name               = json["name"].string ?? ""
        self.status             = json["status"].int ?? 0
        self.section            = json["section"].string ?? ""
        if let arrayFeature     = json["features"].array{
            for i in arrayFeature{
                let dataFeature = Features(json: i)
                features.append(dataFeature)
            }
        }
        
    }
}

public class Features : NSObject {
    var id : Int = 0
    var level: Int = 0
    var name : String = ""
    var status: Int = 0
    var features = [Features]()
    init(json: JSON) {
        self.id                 = json["id"].int ?? 0
        self.level              = json["level"].int ?? 0
        self.name               = json["name"].string ?? ""
        self.status             = json["status"].int ?? 0
        if let arrayFeature     = json["features"].array{
            for i in arrayFeature{
                let dataFeature = Features(json: i)
                features.append(dataFeature)
            }
        }
    }
}
