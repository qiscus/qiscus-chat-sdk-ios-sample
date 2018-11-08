//
//  QBallon.swift
//  Qiscus
//
//  Created by asharijuang on 04/09/18.
//

import Foundation
import QiscusUI
import QiscusCore
import SwiftyJSON

public enum QReplyType:Int{
    case text
    case image
    case video
    case audio
    case document
    case location
    case contact
    case file
    case other
}

extension UIBaseChatCell {
    
    open func getBallon()->UIImage?{
        var balloonImage:UIImage? = nil
        var edgeInset = UIEdgeInsetsMake(13, 13, 13, 28)
        
        if (self.comment?.isMyComment() == true){
            balloonImage = AssetsConfiguration.rightBallonLast
        }else{
            edgeInset = UIEdgeInsetsMake(13, 28, 13, 13)
            balloonImage = AssetsConfiguration.leftBallonLast
        }
        
        return balloonImage?.resizableImage(withCapInsets: edgeInset, resizingMode: .stretch).withRenderingMode(.alwaysTemplate)
    }
}

extension CommentModel {
    
    open func isMyComment() -> Bool {
        // change this later when user savevd on presisstance storage
        if let user = QiscusCore.getProfile() {
            return userEmail == user.email
        }else {
            return false
        }
    }
    
    open func date() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat    = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.timeZone      = TimeZone(abbreviation: "UTC")
        let date = formatter.date(from: self.timestamp)
        return date
    }
    
    open func hour() -> String {
        guard let date = self.date() else {
            return "-"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone      = TimeZone.current
        let defaultTimeZoneStr = formatter.string(from: date);
        return defaultTimeZoneStr
    }
    
    open func replyType(message:String)->QReplyType{
        if self.isAttachment(text: message){
            let url = getAttachmentURL(message: message)
            
            switch self.fileExtension(fromURL: url) {
            case "jpg","jpg_","png","png_","gif","gif_":
                return .image
            case "m4a","m4a_","aac","aac_","mp3","mp3_":
                return .audio
            case "mov","mov_","mp4","mp4_":
                return .video
            case "pdf","pdf_":
                return .document
            case "doc","docx","ppt","pptx","xls","xlsx","txt":
                return .file
            default:
                return .other
            }
        }else{
            return .text
        }
    }
    
    open func isAttachment(text:String) -> Bool {
        var check:Bool = false
        if(text.hasPrefix("[file]")){
            check = true
        }
        return check
    }
    open func getAttachmentURL(message: String) -> String {
        let component1 = message.components(separatedBy: "[file]")
        let component2 = component1.last!.components(separatedBy: "[/file]")
        let mediaUrlString = component2.first?.trimmingCharacters(in: CharacterSet.whitespaces).replacingOccurrences(of: " ", with: "%20")
        return mediaUrlString!
    }
    
    open func fileExtension(fromURL url:String) -> String{
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
    
    open func fileName(text:String) ->String{
        let url = getAttachmentURL(message: text)
        var fileName:String = ""
        
        let remoteURL = url.replacingOccurrences(of: " ", with: "%20").replacingOccurrences(of: "’", with: "%E2%80%99")
        
        if let mediaURL = URL(string: remoteURL) {
            fileName = mediaURL.lastPathComponent.replacingOccurrences(of: "%20", with: "_")
        }
        
        return fileName
    }

}
