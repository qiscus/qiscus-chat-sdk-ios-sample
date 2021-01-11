//
//  HSMTemplateModel.swift
//  Example
//
//  Created by Qiscus on 11/01/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import Foundation
import SwiftyJSON

public class HSMTemplateModel : NSObject {
    var id : Int = 0
    var content : String = ""
    var language : String = ""
    var countryName : String = ""
    
    init(json: JSON) {
        self.id             = json["id"].int ?? 0
        self.content           = json["content"].string ?? ""
        self.language      = json["language"].string ?? ""
        
        let frLocale = NSLocale(localeIdentifier: "\(self.language)")
        self.countryName = frLocale.displayName(forKey: .identifier, value: "\(self.language)") ?? ""
    }

}
