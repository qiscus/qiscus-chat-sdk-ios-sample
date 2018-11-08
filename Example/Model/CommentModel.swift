//
//  CommentModel.swift
//  Alamofire
//
//  Created by asharijuang on 07/08/18.
//

import Foundation
import QiscusCore
import SwiftyJSON

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
    
    /// will post pending message when internet connection is available
    internal class func resendPendingMessage(){
        
        let comments = QiscusCore.database.comment.all().filter({ (comment) in comment.status.rawValue.lowercased() == "failed".lowercased() ||  comment.status.rawValue.lowercased() == "pending".lowercased() })
        
        for comment in comments {
            RoomModel.getRoom(withId: comment.roomId, onSuccess: { (roomModel, commentModel) in
                roomModel.post(comment: comment)
            }) { (error) in
             //error
            }
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
        var comment = CommentModel.init()
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
             onSuccess(commentsModel as! [CommentModel])
        }) { (error) in
            onError(error.message)
        }
    }
}
