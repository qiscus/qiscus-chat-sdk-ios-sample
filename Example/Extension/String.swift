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
            let range = (self.lowercased() as NSString).range(of: string)
            attributedString.addAttributes([NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: CGFloat(sizeFont)), NSAttributedString.Key.foregroundColor : color], range: range)
        }

        guard let characterSpacing = characterSpacing else {return attributedString}

        attributedString.addAttribute(NSAttributedString.Key.kern, value: characterSpacing, range: NSRange(location: 0, length: attributedString.length))

        return attributedString
    }
    
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.height
    }
    
    func isFileAttachment(urlMessage : String)-> Bool{
        let url = getAttachmentURL(message: urlMessage)
        switch self.fileExtension(fromURL: url) {
        case "jpg","jpg_","png","png_","gif","gif_":
            return false
        case "m4a","m4a_","aac","aac_","mp3","mp3_","oga","ogg":
            return true
        case "mov","mov_","mp4","mp4_":
            return false
        case "pdf","pdf_":
            return true
        case "doc","docx","ppt","pptx","xls","xlsx","txt":
            return true
        default:
            return false
        }
    }
    
    func fileExtension(fromURL url:String) -> String{
        var ext = ""
        if url.range(of: ".") != nil{
            let fileNameArr = url.split(separator: ".")
            ext = String(fileNameArr.last!).lowercased()
            if ext.contains("?"){
                let newArr = ext.split(separator: "?")
                ext = String(newArr.first!).lowercased()
            }
        }
        return ext
    }
    
    func getAttachmentURL(message: String) -> String {
        let component1 = message.components(separatedBy: "[file]")
        let component2 = component1.last!.components(separatedBy: "[/file]")
        let mediaUrlString = component2.first?.trimmingCharacters(in: CharacterSet.whitespaces).replacingOccurrences(of: " ", with: "%20")
        return mediaUrlString!
    }
}
