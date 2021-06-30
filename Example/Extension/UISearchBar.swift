//
//  UISearchBar.swift
//  Example
//
//  Created by Qiscus on 14/06/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import Foundation
import AVKit
extension UISearchBar {
    func setTextFieldColor(_ color: UIColor) {
        for subView in self.subviews {
            for subSubView in subView.subviews {
                let view = subSubView as? UITextInputTraits
                if view != nil {
                    let textField = view as? UITextField
                    textField?.backgroundColor = color
                    break
                }
            }
        }
    }
}
