//
//  Background.swift
//  qonsultant
//
//  Created by Ahmad Athaullah on 7/13/16.
//  Copyright © 2016 qiscus. All rights reserved.
//

import UIKit

class Background: NSObject {

}

extension CAGradientLayer {
    class func gradientLayerForBounds(_ bounds: CGRect, topColor:UIColor, bottomColor:UIColor) -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.frame = bounds
        layer.colors = [topColor.cgColor, bottomColor.cgColor]
        return layer
    }
}

extension UINavigationBar {
    override public func verticalGradientColor(_ topColor:UIColor, bottomColor:UIColor){
        var updatedFrame = self.bounds
        // take into account the status bar
        updatedFrame.size.height += 20
        
        let layer = CAGradientLayer.gradientLayerForBounds(updatedFrame, topColor: topColor, bottomColor: bottomColor)
        UIGraphicsBeginImageContext(layer.bounds.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.barTintColor = UIColor.clear
        self.setBackgroundImage(image, for: UIBarMetrics.default)
    }
}
