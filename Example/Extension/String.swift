//
//  String.swift
//  Example
//
//  Created by Qiscus on 16/06/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import Foundation
import UIKit
extension String {
    func attributedStringWithColor(_ strings: [String], color: UIColor, sizeFont : Int = 14, characterSpacing: UInt? = nil) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        for string in strings {
            let range = (self as NSString).range(of: string)
            attributedString.addAttributes([NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: CGFloat(sizeFont)), NSAttributedString.Key.foregroundColor : color], range: range)
        }

        guard let characterSpacing = characterSpacing else {return attributedString}

        attributedString.addAttribute(NSAttributedString.Key.kern, value: characterSpacing, range: NSRange(location: 0, length: attributedString.length))

        return attributedString
    }
}
