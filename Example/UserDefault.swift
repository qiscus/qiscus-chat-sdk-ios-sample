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
    
    //MARK: Retrieve User Data
    func getLongLivedToken() -> String{
        return string(forKey: "longlivedtoken") ?? ""
    }
    
    //user type 1 = admin
    //MARK: Save authentication_token
    func setLongLivedToken(value: String){
        set(value, forKey: "longlivedtoken")
        //synchronize()
    }
    
    //MARK: Retrieve User Data
    func getBaseURL() -> String{
        return string(forKey: "baseurl") ?? "https://multichannel.qiscus.com"
    }
    
    //user type 1 = admin
    //MARK: Save authentication_token
    func setBaseURL(value: String){
        set(value, forKey: "baseurl")
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
    
    func setAfterLogin(value: Bool){
        set(value, forKey: "afterlogin")
        //synchronize()
    }
    
    //MARK: Retrieve User Data
    func getAfterLogin() -> Bool{
        return bool(forKey: "afterlogin")
    }
    
    func getStatusFeatureOverallAgentAnalytics() -> Int?{
        return integer(forKey: "featureOverallAgentAnalytics")
    }
    
    func setStatusFeatureOverallAgentAnalytics(value: Int){
        set(value, forKey: "featureOverallAgentAnalytics")
    }
    
    func getStatusFeatureCustomAnalytics() -> Int?{
        return integer(forKey: "featureCustomAnalytics")
    }
    
    func setStatusFeatureSubmitTicket(value: Int){
        set(value, forKey: "featureSubmitTicket")
    }
    
    func getStatusFeatureSubmitTicket() -> Int?{
        return integer(forKey: "featureSubmitTicket")
    }
    
    func setStatusFeatureContact(value: Int){
        set(value, forKey: "featureContact")
    }
    
    func getStatusFeatureContact() -> Int?{
        return integer(forKey: "featureContact")
    }
    
    func setStatusFeatureCustomAnalytics(value: Int){
        set(value, forKey: "featureCustomAnalytics")
    }
    
    func getStatusFeatureAnalyticsWA() -> Int?{
        return integer(forKey: "featureAnalyticsWA")
    }
    
    func setStatusFeatureAnalyticsWA(value: Int){
        set(value, forKey: "featureAnalyticsWA")
    }
    
    //MARK: Save account id
    func setAccountId(value: Int){
        set(value, forKey: "accountId")
    }
    
    //MARK: Retrieve User Data
    func getAccountId() -> Int?{
        return integer(forKey: "accountId")
    }
    
    //MARK: Save botConfig
    func setBot(value: Bool){
        set(value, forKey: "is_bot_enabled")
        //synchronize()
    }
    
    //MARK: Retrieve User Data
    func getBot() -> Bool{
        return bool(forKey: "is_bot_enabled")
    }
    
    func setEmailMultichannel(value: String){
        set(value, forKey: "email_multichannel")
    }
    
    func getEmailMultichannel() -> String{
        return string(forKey: "email_multichannel") ?? ""
    }
    
    func setSelectWAChannelsAnalytics(value: Int){
        set(value, forKey: "selectWAChannelsAnalytics")
    }
    
    func getSelectWAChannelsAnalytics() -> Int?{
        return integer(forKey: "selectWAChannelsAnalytics")
    }
}
