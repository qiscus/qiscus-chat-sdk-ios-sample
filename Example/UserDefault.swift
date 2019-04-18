//
//  UserDefault.swift
//  Example
//
//  Created by Qiscus on 18/04/19.
//  Copyright © 2019 Qiscus. All rights reserved.
//

import Foundation
extension UserDefaults{
    
    //MARK: Save Device Token
    func setDeviceToken(value: String){
        set(value, forKey: "deviceTokenKey")
        //synchronize()
    }
    
    //MARK: Retrieve User Data
    func getDeviceToken() -> String?{
        return string(forKey: "deviceTokenKey")
    }
}
