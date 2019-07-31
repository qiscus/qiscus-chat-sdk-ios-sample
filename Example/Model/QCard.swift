//
//  QCard.swift
//  Pods
//
//  Created by asharijuang on 02/11/18.
//

import Foundation
import UIKit
import SwiftyJSON

public class QCard: NSObject {
    var title:String = ""
    var desc:String = ""
    var displayURL:String = ""
    var actions:[QCardAction] = [QCardAction]()
    var defaultAction:QCardAction?
    
    public init(json:JSON) {
        self.title = json["title"].stringValue
        self.desc = json["description"].stringValue
        self.displayURL = json["image"].stringValue
        let actions = json["buttons"].arrayValue
        self.defaultAction = QCardAction(json: json["default_action"])
        for actionData in actions {
            let action = QCardAction(json: actionData)
            self.actions.append(action)
        }
    }
}
