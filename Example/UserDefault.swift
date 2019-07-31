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
    
    //MARK: Save appID
    func setAppID(value: String){
        set(value, forKey: "appID")
        //synchronize()
    }
    
    //MARK: Retrieve User Data
    func getAppID() -> String?{
        return string(forKey: "appID")
    }
    
    //MARK: Save authentication_token
    func setAuthenticationToken(value: String){
        set(value, forKey: "token")
        //synchronize()
    }
    
    //MARK: Retrieve User Data
    func getAuthenticationToken() -> String?{
        return string(forKey: "token")
    }
    
    //user type 1 = admin
    //MARK: Save authentication_token
    func setUserType(value: Int){
        set(value, forKey: "userType")
        //synchronize()
    }
    
    //MARK: Retrieve User Data
    func getUserType() -> Int?{
        return integer(forKey: "userType")
    }
    
    //MARK: Save bubble color
    func setBubbleColor(value: String){
        set(value, forKey: "bubble")
        //synchronize()
    }
    
    //MARK: Retrieve User Data
    func getBubbleColor() -> String?{
       return string(forKey: "bubble")
    }
    
}
