//
//  CommentModel.swift
//  Alamofire
//
//  Created by asharijuang on 07/08/18.
//

import Foundation
import QiscusCore
import SwiftyJSON

@objc public enum QiscusFileType:Int{
    case image
    case video
    case audio
    case document
    case file
    case pdf
}

@objc public enum CommentModelType:Int {
    case text
    case image
    case video
    case audio
    case file
    case postback
    case account
    case reply
    case system
    case card
    case contact
    case location
    case custom
    case document
    case carousel
    
    static let all = [text.name(), image.name(), video.name(), audio.name(),file.name(),postback.name(),account.name(), reply.name(), system.name(), card.name(), contact.name(), location.name(), custom.name()]
    
    public func name() -> String{
        switch self {
        case .text      : return "text"
        case .image     : return "image"
        case .video     : return "video"
        case .audio     : return "audio"
        case .file      : return "file"
        case .postback  : return "postback"
        case .account   : return "account"
        case .reply     : return "reply"
        case .system    : return "system"
        case .card      : return "card"
        case .contact   : return "contact_person"
        case .location  : return "location"
        case .custom    : return "custom"
        case .document  : return "document"
        case .carousel  : return "carousel"
        }
    }
    public init(name:String) {
        switch name {
        case "text","button_postback_response"     : self = .text ; break
        case "image"            : self = .image ; break
        case "video"            : self = .video ; break
        case "audio"            : self = .audio ; break
        case "file"             : self = .file ; break
        case "postback"         : self = .postback ; break
        case "account"          : self = .account ; break
        case "reply"            : self = .reply ; break
        case "system"           : self = .system ; break
        case "card"             : self = .card ; break
        case "contact_person"   : self = .contact ; break
        case "location"         : self = .location; break
        case "document"         : self = .document; break
        case "carousel"         : self = .carousel; break
        default                 : self = .custom ; break
        }
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
    
    public var typeMessage: CommentModelType{
        get{
            return CommentModelType(rawValue: type.hashValue)!
        }
        
    }
    
    //Todo search comment from local
    internal class func comments(searchQuery: String, onSuccess:@escaping (([CommentModel])->Void), onFailed: @escaping ((String)->Void)){
        
        let comments = QiscusCore.database.comment.all().filter({ (comment) -> Bool in
            return comment.message.lowercased().contains(searchQuery.lowercased())
        })
        
        if(comments.count == 0){
            onFailed("Comment not found")
        }else{
            onSuccess(comments as! [CommentModel])
        }
    }
    
    public func encodeDictionary()->[AnyHashable : Any]{
        var data = [AnyHashable : Any]()
        
        data["qiscus_commentdata"] = true
        data["qiscus_uniqueId"] = self.uniqId
        data["qiscus_id"] = self.id
        data["qiscus_roomId"] = self.roomId
        data["qiscus_beforeId"] = self.commentBeforeId
        data["qiscus_text"] = self.message
        data["qiscus_createdAt"] = self.unixTimestamp
        data["qiscus_senderEmail"] = self.userEmail
        data["qiscus_senderName"] = self.username
        data["qiscus_statusRaw"] = self.status
        data["qiscus_typeRaw"] = self.type
        data["qiscus_data"] = self.payload
        
        return data
    }
    
    /// forward to other roomId
    ///
    /// - Parameters:
    ///   - roomId: roomId
    ///   - onSuccess: will return success
    ///   - onError: will return error message
    public func forward(toRoomWithId roomId: String, onSuccess:@escaping ()->Void, onError:@escaping (String)->Void){
        let comment = CommentModel.init()
        if(comment.type == "file_attachment"){
            comment.type = "file_attachment"
            comment.payload = self.payload
            comment.message = "Send Attachment"
        }else{
            comment.type = self.type
            comment.message = self.message
        }

        QiscusCore.shared.sendMessage(roomID: roomId, comment: comment, onSuccess: { (commentModel) in
            onSuccess()
        }) { (error) in
            onError(error.message)
        }
        
    }
    
    /// Delete message by id
    ///
    /// - Parameters:
    ///   - uniqueID: comment unique id
    ///   - type: forMe or ForEveryone
    ///   - completion: Response Comments your deleted
    public func deleteMessage(uniqueIDs id: [String], type: DeleteType, onSuccess:@escaping ([CommentModel])->Void, onError:@escaping (String)->Void) {
       
        QiscusCore.shared.deleteMessage(uniqueIDs: id, type: type, onSuccess: { (commentsModel) in
            onSuccess(commentsModel)
        }) { (error) in
            onError(error.message)
        }
    }
}
