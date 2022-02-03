//
//  QCommentContact.swift
//  Example
//
//  Created by arief nur putranto on 07/12/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import Foundation
import SwiftyJSON
import QiscusCore

public class QCommentContact : NSObject {
    public var commentBeforeId      : String        = ""
    public var id                   : String        = ""
    public var isDeleted            : Bool          = false
    public var isPublicChannel      : Bool          = false
    public var status               : QCommentContactStatus = .sending
    public var message              : String        = ""
    /// Comment payload, to describe comment type.
    public var payload              : [String:Any]? = nil
    /// Extra data, set after comment is complate.
    public var extras               : [String:Any]? = nil
    public var userExtras           : [String:Any]? = nil
    public var roomId               : String        = ""
    public var timestamp            : String        = ""
    public var type                 : String        = "text"
    public var uniqId               : String        = ""
    public var unixTimestamp        : Int64         = 0
    public var userAvatarUrl        : URL?          = nil
    public var userId               : String        = ""
    public var username             : String        = ""
    public var userEmail            : String        = ""
    /// automatic set when comment initiated
    public var date                 : Date {
        get {
            return self.getDate()
        }
    }
    init(json: JSON) {
        self.id                 = json["id_str"].stringValue
        self.roomId             = json["room_id_str"].string ?? json["Room_id_str"].string ?? ""
        self.uniqId             = json["unique_temp_id"].stringValue
        self.commentBeforeId    = json["comment_before_id_str"].stringValue
        self.userEmail          = json["email"].stringValue
        self.isDeleted          = json["is_deleted"].boolValue
        self.isPublicChannel    = json["is_public_channel"].boolValue
        self.message            = json["message"].stringValue
        self.payload            = json["payload"].dictionaryObject
        self.timestamp          = json["timestamp"].stringValue
        self.unixTimestamp      = json["unix_nano_timestamp"].int64Value
        self.userAvatarUrl      = json["user_avatar_url"].url ?? json["user_avatar"].url ?? URL(string: "http://")
        self.username           = json["username"].stringValue
        self.userId             = json["user_id_str"].stringValue
        let _status             = json["status"].stringValue
        for s in QCommentContactStatus.all {
            if s.rawValue == _status {
                self.status = s
            }
        }
        if isDeleted {
            self.status = .deleted // maping status deleted, backend not provide
        }
        let _type   = json["type"].stringValue
        if _type.lowercased() != "custom" {
            self.type = _type
        }else {
            
            let payloadType = payload?["type"] as! String
            
            if payloadType == nil {
                self.type = "custom"
            }else{
                self.type = payloadType
            }
            
            // parsing payload
            if let _payload = self.payload {
                self.payload?.removeAll()
                
                if let payload = _payload["content"] as? [String:Any]{
                    if !payload.isEmpty {
                        self.payload = payload
                    }else {
                        self.payload = nil
                    }
                }else {
                    self.payload = nil
                }
            }
        }
        
        self.extras             = json["extras"].dictionaryObject
        self.userExtras         = json["user_extras"].dictionaryObject
        
    }
    
    func getDate() -> Date {
        //let timezone = TimeZone.current.identifier
        let formatter = DateFormatter()
        formatter.dateFormat    = "yyyy-MM-dd'T'HH:mm:ssZ"
        //formatter.timeZone      = TimeZone(secondsFromGMT: 0)
        formatter.timeZone      = TimeZone(abbreviation: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let date = formatter.date(from: self.timestamp)
        return date ?? Date()
    }
    
    func getTimestamp() -> String {
        let timezone = TimeZone.current.identifier
        let formatter = DateFormatter()
        formatter.dateFormat    = "yyyy-MM-dd'T'HH:mm:ssZ"
        //formatter.timeZone      = TimeZone(secondsFromGMT: 0)
        formatter.timeZone      = TimeZone(abbreviation: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: Date())
    }
    
    func isQiscustype() -> Bool {
        var result = false
        for t in QCommentContactStatus.all {
            if self.type == t.rawValue {
                result = true
            }
        }
        return result
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
    
    func fileName(text:String) ->String{
        let url = getAttachmentURL(message: text)
        var fileName:String = ""
        
        let remoteURL = url.replacingOccurrences(of: " ", with: "%20").replacingOccurrences(of: "’", with: "%E2%80%99")
        
        if let mediaURL = URL(string: remoteURL) {
            fileName = mediaURL.lastPathComponent.replacingOccurrences(of: "%20", with: "_")
        }
        
        return fileName
    }
    
    func isAttachment(text:String) -> Bool {
        var check:Bool = false
        if(text.hasPrefix("[file]")){
            check = true
        }
        return check
    }
    func getAttachmentURL(message: String) -> String {
        let component1 = message.components(separatedBy: "[file]")
        let component2 = component1.last!.components(separatedBy: "[/file]")
        let mediaUrlString = component2.first?.trimmingCharacters(in: CharacterSet.whitespaces).replacingOccurrences(of: " ", with: "%20")
        return mediaUrlString!
    }
    
    func getStickerURL(message: String) -> String {
        let component1 = message.components(separatedBy: "[sticker]")
        let component2 = component1.last!.components(separatedBy: "[/sticker]")
        let mediaUrlString = component2.first?.trimmingCharacters(in: CharacterSet.whitespaces).replacingOccurrences(of: " ", with: "%20")
        return mediaUrlString!
    }
    
    func replyType(message:String)-> QReplyType{
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
}
 public enum QCommentContactStatus : String, CaseIterable {
    case sending    = "sending"
    case pending    = "pending"
    case failed     = "failed"
    case sent       = "sent"
    case delivered  = "delivered"
    case read       = "read"
    case deleting   = "deleting" // because delete process not only in device
    case deleted    = "deleted"
    
    static let all = [sending, pending, failed, sent, delivered, read, deleted]
    
    var intValue : Int {
        get {
            return self.asInt()
        }
    }
    private func asInt() -> Int {
        for (index,s) in QCommentContactStatus.all.enumerated() {
            if self == s {
                return index
            }
        }
        return 0
    }
}

enum QCommentContactType: String {
    case text                       = "text"
    case fileAttachment             = "file_attachment"
    case accountLink                = "account_linking"
    case buttons                    = "buttons"
    case buttonPostbackResponse     = "button_postback_response"
    case reply                      = "reply"
    case systemEvent                = "system_event"
    case card                       = "card"
    case custom                     = "custom"
    case location                   = "location"
    case contactPerson              = "contact_person"
    case carousel                   = "carousel"
    
    static let all = [text,fileAttachment,accountLink,buttons,buttonPostbackResponse,reply,systemEvent,card,custom,location,contactPerson,carousel]
}

