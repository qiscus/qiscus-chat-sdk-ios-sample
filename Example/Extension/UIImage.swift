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
