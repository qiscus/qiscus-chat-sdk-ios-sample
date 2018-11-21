//
//  UIView.swift
//  LinkDokter
//
//  Created by QiscusDev on 11/2/15.
//  Copyright © 2015 qiscus. All rights reserved.
//

import Foundation
import UIKit


extension UIView {
    func addBorderTop(size: CGFloat, color: UIColor) {
        addBorderUtility(x: 0, y: 0, width: frame.width, height: size, color: color)
    }
    func addBorderBottom(size: CGFloat, color: UIColor) {
        addBorderUtility(x: 0, y: frame.height - size, width: frame.width, height: size, color: color)
    }
    func addBorderLeft(size: CGFloat, color: UIColor) {
        addBorderUtility(x: 0, y: 0, width: size, height: frame.height, color: color)
    }
    func addBorderRight(size: CGFloat, color: UIColor) {
        addBorderUtility(x: frame.width - size, y: 0, width: size, height: frame.height, color: color)
    }
    func addBorder(size: CGFloat, color: UIColor) {
        addBorderTop(size: size, color: color)
        addBorderLeft(size: size, color: color)
        addBorderBottom(size: size, color: color)
        addBorderRight(size: size, color: color)
    }
    fileprivate func addBorderUtility(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, color: UIColor) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: x, y: y, width: width, height: height)
        layer.addSublayer(border)
    }
    
    // MARK: - Vertical Gradient Background
    @objc public func verticalGradientColor(_ topColor:UIColor, bottomColor:UIColor){
        var updatedFrame = self.bounds
        // take into account the status bar
        updatedFrame.size.height += 20
        
        let layer = CAGradientLayer.gradientLayerForBounds(updatedFrame, topColor: topColor, bottomColor: bottomColor)
        UIGraphicsBeginImageContext(layer.bounds.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        backgroundColor = UIColor(patternImage: image!)
    }

}

extension UIFont {
    internal func withTraits(traits:UIFontDescriptor.SymbolicTraits) -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(traits)
        return UIFont(descriptor: descriptor!, size: 0) //size 0 means keep the size as it is
    }
    
    internal func bold() -> UIFont {
        return withTraits(traits: .traitBold)
    }
    
    internal func italic() -> UIFont {
        return withTraits(traits: .traitItalic)
    }
}
