//
//  AdditionalInformationModel.swift
//  Example
//
//  Created by Qiscus on 03/12/20.
//  Copyright © 2020 Qiscus. All rights reserved.
//

import Foundation
import SwiftyJSON

public class AdditionalInformationModel : NSObject {
    public var titleInformation : String = ""
    public var descriptionInformation : String = ""
    public var dictio = [String : Any]()
    
    init(json: JSON) {
        self.titleInformation             = json["key"].string ?? ""
        self.descriptionInformation       = json["value"].string ?? ""
        self.dictio = ["key" : self.titleInformation, "value" : self.descriptionInformation]
    }
    
    override init(){
        
    }
}
