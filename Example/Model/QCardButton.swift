//
//  QCardButton.swift
//  Example
//
//  Created by arief nur putranto on 29/09/23.
//  Copyright © 2023 Qiscus. All rights reserved.
//

import Foundation
import UIKit
public enum QCardButtonType:Int{
    case link
    case postback
}
class QCardButton: UIButton {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    var type:QCardButtonType = .link
    var label:String = "" {
        didSet{
            self.setTitle(label, for: .normal)
        }
    }
    var payload:String = ""
}
