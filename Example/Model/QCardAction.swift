//
//  QCardAction.swift
//  Example
//
//  Created by arief nur putranto on 29/09/23.
//  Copyright © 2023 Qiscus. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

public class QCardAction: NSObject {
    public var title = ""
    public var type = QCardButtonType.link
    public var postbackText = ""
    public var payload:JSON?
    
    public init(json:JSON) {
        self.title = json["label"].stringValue
        if json["type"].stringValue == "postback" {
            self.type = .postback
        }
        self.postbackText = json["postback_text"].stringValue
        self.payload = json["payload"]
    }
}
