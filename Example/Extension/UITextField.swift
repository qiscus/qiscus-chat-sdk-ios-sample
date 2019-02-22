//
//  UITextField.swift
//  Example
//
//  Created by Qiscus on 20/02/19.
//  Copyright © 2019 Qiscus. All rights reserved.
//

import Foundation
import UIKit
extension UITextField {
    func setBottomBorder() {
        self.borderStyle = .none
        self.layer.backgroundColor = UIColor.white.cgColor
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
    
    func setBottomGreen(){
        self.layer.shadowColor = UIColor.green.cgColor
    }
    
    func setBottomColorGrey(){
        self.layer.shadowColor = UIColor.gray.cgColor
    }
}
