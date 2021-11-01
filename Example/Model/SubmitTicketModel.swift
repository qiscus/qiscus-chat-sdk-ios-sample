//
//  SubmitTicketModel.swift
//  Example
//
//  Created by Qiscus on 18/10/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import Foundation
import SwiftyJSON

public class SubmitTicketModel : NSObject {
    var id : Int = 0
    var nameButton : String = ""
    var label : String = ""
    var enabled : Bool = false
   
    init(json: JSON) {
        self.id             = json["id"].int ?? 0
        self.nameButton     = json["button"].string ?? "Submit ticket"
        self.label          = json["label"].string ?? "Ticketing"
        self.enabled        = json["enabled"].bool ?? false
    }
}


// MARK: - Agent
public class Agent {
    let email, name, type: String

    init(email: String, name: String, type: String) {
        self.email = email
        self.name = name
        self.type = type
    }
}

// MARK: - Customer
public class Customer {
    let avatar: String
    let name, userID: String

    init(avatar: String, name: String, userID: String) {
        self.avatar = avatar
        self.name = name
        self.userID = userID
    }
}

//// MARK: - CustomerProperty
//public class CustomerProperty {
//    let id: Int
//    let label, value: String
//
//    init(id: Int, label: String, value: String) {
//        self.id = id
//        self.label = label
//        self.value = value
//    }
//}


