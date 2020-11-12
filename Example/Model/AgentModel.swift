//
//  AgentModel.swift
//  Example
//
//  Created by Qiscus on 12/11/20.
//  Copyright © 2020 Qiscus. All rights reserved.
//

import Foundation
import SwiftyJSON

public class AgentModel : NSObject {
    var id : String = ""
    var name : String = ""
    var avatarUrl : String? = nil
    var email : String = ""
    var isAvailable : Bool = false
    var currentCustomerCount : Int = 0
    var userRoles : [UserRoles] =  [UserRoles]()
    
    init(json: JSON) {
        self.id             = json["id"].stringValue
        self.name           = json["name"].stringValue
        self.avatarUrl      = json["avatar_url"].string ?? nil
        self.email         = json["email"].string ?? ""
        self.isAvailable    = json["is_available"].bool ?? false
        self.currentCustomerCount = json["current_customer_count"].int ?? 0
        
        let role = json["user_roles"].array ?? json["assigned_agent_roles"].array ?? nil
        
        if role != nil {
            for roleData in role! {
                let data = UserRoles(json: roleData)
                self.userRoles.append(data)
            }
        }
    }
}

public class UserRoles: NSObject {
    public var id = ""
    public var name = ""
    
    public init(json:JSON) {
         self.id             = json["id"].string ?? ""
         self.name           = json["name"].string ?? ""
    }
}
