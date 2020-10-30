//
//  RefreshToken.swift
//  Example
//
//  Created by Qiscus on 27/10/20.
//  Copyright © 2020 Qiscus. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import QiscusCore

public class RefreshToken: NSObject {
    
    public class func getRefreshToken(response : JSON, onSuccess: @escaping (Bool) -> Void){
        
        let longLiveToken = UserDefaults.standard.getLongLivedToken()
        
        let errorMessage = response["errors"].string ?? ""
        let detailMessage = response["detail"].string ?? ""
        
        if longLiveToken.isEmpty == true {
            QiscusCore.logout { (error) in
                let app = UIApplication.shared.delegate as! AppDelegate
                app.auth()
            }
            return
        } else {
        
            if !longLiveToken.isEmpty && !longLiveToken.contains(UserDefaults.standard.getAuthenticationToken() ?? "") && errorMessage.contains("Unauthorized") || detailMessage.contains("token_expired") {
                let header = ["Authorization": longLiveToken, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
                
                Alamofire.request("\(QiscusHelper.getBaseURL())/api/v2/auth/refresh_token", method: .post, parameters: nil, headers: header as! HTTPHeaders).responseJSON { (response) in
                    if response.result.value != nil {
                        if (response.response?.statusCode)! >= 300 {
                            //error
                            onSuccess(false)
                        } else {
                            //success
                            let payload = JSON(response.result.value)
                            let newTokenQismo = payload["data"]["auth"]["token"].string ?? ""
                            UserDefaults.standard.setAuthenticationToken(value: newTokenQismo)
                            
                            onSuccess(true)
                        }
                    } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                        //failed
                        onSuccess(false)
                    } else {
                        //failed
                        onSuccess(false)
                    }
                }
            } else if errorMessage.contains("invalid token") || errorMessage.contains("Unauthorized"){
                QiscusCore.logout { (error) in
                    let app = UIApplication.shared.delegate as! AppDelegate
                    app.auth()
                }
                return
            } else {
                onSuccess(false)
            }
        }
    }
    
}
