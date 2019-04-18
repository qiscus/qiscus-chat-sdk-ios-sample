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
    
    func image(named name:String)->UIImage?{
        return UIImage(named: name, in: MyChat.bundle, compatibleWith: nil)
    }
    
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
    
    // MARK: - Upload image preparation
    class func uploadImagePreparation(pickedImage: UIImage) -> String {
        // We use document directory to place our cloned image
        let documentDirectory: NSString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as NSString
        
        // Set static name, so everytime image is cloned, it will be named "temp", thus rewrite the last "temp" image.
        // *Don't worry it won't be shown in Photos app.
        let imageName = "temp_avatar.png"
        let imagePath = documentDirectory.appendingPathComponent(imageName)
        
        // Encode this image into JPEG. *You can add conditional based on filetype, to encode into JPEG or PNG
        if let data = pickedImage.jpegData(compressionQuality: 80)  {
            // Save cloned image into document directory
            try! data.write(to: URL(fileURLWithPath: imagePath))
        }
        
        // Save it's path
        let localPath = imagePath
        return localPath
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
