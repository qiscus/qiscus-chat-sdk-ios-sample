//
//  UIImage.swift
//  Alamofire
//
//  Created by asharijuang on 07/08/18.
//

import Foundation
import UIKit
import ImageIO
var QiscusImageCache = NSCache<NSString,UIImage>()

extension UIImage {
    func localizedImage()->UIImage{
        if UIApplication.shared.userInterfaceLayoutDirection == .leftToRight {
            return self
        }else{
            if let cgimage = self.cgImage {
                return UIImage(cgImage: cgimage, scale: 1, orientation:.upMirrored )
            }else{
                return self
            }
        }
    }
}

extension UIImageView {
    
    func applyShadow() {
        let layer           = self.layer
        layer.shadowColor   = UIColor.black.cgColor
        layer.shadowOffset  = CGSize(width: 0, height: 0.5)
        layer.shadowOpacity = 0.2
        layer.shadowRadius  = 1
    }
    
}
