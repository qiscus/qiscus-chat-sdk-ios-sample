//
//  BroadcastTemplateModel.swift
//  Example
//
//  Created by arief nur putranto on 04/03/22.
//  Copyright © 2022 Qiscus. All rights reserved.
//

import Foundation
import SwiftyJSON

public class BroadcastTemplateModel : NSObject {
    var id : Int = 0
    var channelId : Int = 0
    var channelName : String = ""
    var name : String = ""
    var hsmDetails = [HSMDetails]()
    
    init(json: JSON) {
        self.id                     = json["id"].int ?? 0
        self.channelId              = json["channel_id"].int ?? 0
        self.channelName            = json["channel_name"].string ?? ""
        self.name                   = json["name"].string ?? ""
        if let dataHSMDetails       = json["hsm_details"].array{
            for i in dataHSMDetails{
                let detail = HSMDetails(json: i)
                if detail.approvalStatus == 1 {
                    self.hsmDetails.append(detail)
                }
            }
        }
    }

}

public class HSMDetails : NSObject {
    var id : Int = 0
    var approvalStatus : Int = 0
    var buttons = [HSMButton]()
    var content : String = ""
    var footer : String = ""
    var headerContent : String = ""
    var headerDefaultValue : String = ""
    var headerType : String = ""
    var language: String = ""
    var countBody : Int = 0
    var countHeader: Int = 0
    var countButton: Int = 0
    
    
    init(json: JSON) {
        self.id                     = json["id"].int ?? 0
        self.approvalStatus         = json["approval_status"].int ?? 0
        self.content                = json["content"].string ?? ""
        self.footer                 = json["footer"].string ?? ""
        self.headerContent          = json["header_content"].string ?? ""
        self.headerDefaultValue     = json["header_default_value"].string ?? ""
        self.headerType             = json["header_type"].string ?? ""
        self.language               = json["language"].string ?? ""
        self.countBody              = json["number_of_arguments"].int ?? 0
        if let dataButtons     = json["buttons"].array{
            for i in dataButtons{
                let detail = HSMButton(json: i)
                self.buttons.append(detail)
                
                if detail.type.lowercased() == "URL".lowercased() {
                    var buttonCount = 0
                    var check = false
                    for index in stride(from: 20, through: 0, by: -1) {
                        if detail.url.contains("{{\(index)}}") && check == false{
                            check = true
                            buttonCount = index
                        }
                    }
                    self.countButton = buttonCount
                }
            }
            
        }
        
        if headerContent.isEmpty == false {
            var headerCount = 0
            var check = false
            for index in stride(from: 20, through: 0, by: -1) {
                if self.headerContent.contains("{{\(index)}}") && check == false{
                    check = true
                    headerCount = index
                }
            }
            self.countHeader = headerCount
        }
        
        
    }

}

public class HSMButton : NSObject {
    var id : Int = 0
    var phoneNumber : String = ""
    var text : String = ""
    var type : String = ""
    var url : String = ""
    
    //QUICK_REPLY : text, type
    //PHONE_NUMBER : text ,type, phone_number
    //URL : text, type, URL
    
    init(json: JSON) {
        self.id                 = json["id"].int ?? 0
        self.phoneNumber        = json["phone_number"].string ?? ""
        self.text               = json["text"].string ?? ""
        self.type               = json["type"].string ?? "" //QUICK_REPLY, PHONE_NUMBER // URL
        self.url                = json["url"].string ?? ""
    }

}

