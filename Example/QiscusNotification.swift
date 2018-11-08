//
//  QiscusNotification.swift
//  Example
//
//  Created by Ahmad Athaullah on 9/12/17.
//  Copyright © 2017 Ahmad Athaullah. All rights reserved.
//

import UIKit
import QiscusCore

public class QiscusNotification: NSObject {
    
    static let shared = QiscusNotification()
    let nc = NotificationCenter.default
    var roomOrderTimer:Timer?
    
    private static var typingTimer = [String:Timer]()
    
    public static let MESSAGE_STATUS = NSNotification.Name("qiscus_messageStatus")
    public static let USER_PRESENCE = NSNotification.Name("quscys_userPresence")
    public static let USER_AVATAR_CHANGE = NSNotification.Name("qiscus_userAvatarChange")
    public static let USER_NAME_CHANGE = NSNotification.Name("qiscus_userNameChange")
    public static let GOT_NEW_ROOM = NSNotification.Name("qiscus_gotNewRoom")
    public static let GOT_NEW_COMMENT = NSNotification.Name("qiscus_gotNewComment")
    public static let ROOM_DELETED = NSNotification.Name("qiscus_roomDeleted")
    public static let ROOM_ORDER_MAY_CHANGE = NSNotification.Name("qiscus_romOrderChange")
    public static let FINISHED_CLEAR_MESSAGES = NSNotification.Name("qiscus_finishedClearMessages")
    public static let FINISHED_SYNC_ROOMLIST = NSNotification.Name("qiscus_finishedSyncRoomList")
    public static let START_CLOUD_SYNC = NSNotification.Name("qiscus_startCloudSync")
    public static let FINISHED_CLOUD_SYNC = NSNotification.Name("qiscus_finishedCloudSync")
    public static let ERROR_CLOUD_SYNC = NSNotification.Name("qiscus_finishedCloudSync")
    public static let DID_TAP_SAVE_CONTACT = NSNotification.Name("qiscus_didTapSaveContact")
    public static let DID_TAP_MENU_REPLY = NSNotification.Name("qiscus_didClickReply")
    public static let DID_TAP_MENU_SHARE = NSNotification.Name("qiscus_didClickShare")
    public static let DID_TAP_MENU_INFO = NSNotification.Name("qiscus_didClickInfo")
    public static let DID_TAP_MENU_FORWARD = NSNotification.Name("qiscus_didClickForward")
    
    override private init(){
        super.init()
    }
    // MARK: Notification Name With Specific Data
    public class func USER_TYPING(onRoom roomId: String) -> NSNotification.Name {
        return NSNotification.Name("qiscus_userTyping_\(roomId)")
    }
    public class func ROOM_CHANGE(onRoom roomId: String) -> NSNotification.Name {
        return NSNotification.Name("qiscus_roomChange_\(roomId)")
    }
    public class func ROOM_CLEARMESSAGES(onRoom roomId: String) -> NSNotification.Name {
        return NSNotification.Name("qiscus_clearMessages_\(roomId)")
    }
    public class func COMMENT_DELETE(onRoom roomId: String) -> NSNotification.Name {
        return NSNotification.Name("qiscus_commentDelete_\(roomId)")
    }
//    public class func DID_TAP_SAVE_CONTACT(message : CommentModel) -> NSNotification.Name {
//        return NSNotification.Name("qiscus_didTapSaveContact\(message)")
//    }
    
    
    public class func publishDidTapSaveContact(message : CommentModel){
        let notification = QiscusNotification.shared
        notification.publishDidTapSaveContact(message: message)
    }
    
    private func publishDidTapSaveContact(message:CommentModel){
        let userInfo = ["comment" : message]
        self.nc.post(name: QiscusNotification.DID_TAP_SAVE_CONTACT, object: nil, userInfo: userInfo)
    }
    
    public class func publishDidClickReply(message : CommentModel){
        let notification = QiscusNotification.shared
        notification.publishDidClickReply(message: message)
    }
    
    private func publishDidClickReply(message:CommentModel){
        let userInfo = ["comment" : message]
        self.nc.post(name: QiscusNotification.DID_TAP_MENU_REPLY, object: nil, userInfo: userInfo)
    }
    
    public class func publishDidClickShare(message : CommentModel){
        let notification = QiscusNotification.shared
        notification.publishDidClickShare(message: message)
    }
    
    private func publishDidClickShare(message:CommentModel){
        let userInfo = ["comment" : message]
        self.nc.post(name: QiscusNotification.DID_TAP_MENU_SHARE, object: nil, userInfo: userInfo)
    }
    
    public class func publishDidClickInfo(message : CommentModel){
        let notification = QiscusNotification.shared
        notification.publishDidClickInfo(message: message)
    }
    
    private func publishDidClickInfo(message:CommentModel){
        let userInfo = ["comment" : message]
        self.nc.post(name: QiscusNotification.DID_TAP_MENU_INFO, object: nil, userInfo: userInfo)
    }
    
    public class func publishDidClickForward(message : CommentModel){
        let notification = QiscusNotification.shared
        notification.publishDidClickForward(message: message)
    }
    
    private func publishDidClickForward(message:CommentModel){
        let userInfo = ["comment" : message]
        self.nc.post(name: QiscusNotification.DID_TAP_MENU_FORWARD, object: nil, userInfo: userInfo)
    }
    
    public class func publish(gotNewComment comment:CommentModel, room:RoomModel){
        let notification = QiscusNotification.shared
        notification.publish(gotNewComment: comment, room: room)
    }
    
    private func publish(gotNewComment comment:CommentModel, room:RoomModel){
        let userInfo = ["comment" : comment, "room" : room] as [String : Any]
        self.nc.post(name: QiscusNotification.GOT_NEW_COMMENT, object: nil, userInfo: userInfo)
    }
    
    public class func publish(gotNewRoom room:RoomModel){
        let notification = QiscusNotification.shared
        notification.publish(gotNewRoom: room)
    }
    
    private func publish(gotNewRoom room:RoomModel){
        let userInfo = ["room" : room]
        self.nc.post(name: QiscusNotification.GOT_NEW_ROOM, object: nil, userInfo: userInfo)
    }
    
    public class func publish(userTyping user:MemberModel, room:RoomModel ,typing:Bool = true){
        let notification = QiscusNotification.shared
        notification.publish(userTyping: user, room: room, typing: typing)
    }
    
    private func publish(userTyping user:MemberModel, room:RoomModel ,typing:Bool = true){
    
        let roomId = room.id
        let userInfo: [AnyHashable: Any] = ["room" : room,"user" : user, "typing": typing]
        
        self.nc.post(name: QiscusNotification.USER_TYPING(onRoom: roomId), object: nil, userInfo: userInfo)
    }

    public class func publish(userPresence user:MemberModel, isOnline online: Bool, at time: Date){
        let notification = QiscusNotification.shared
        notification.publish(userPresence: user, isOnline: online, at: time)
    }
    
    private func publish(userPresence user:MemberModel, isOnline online: Bool, at time: Date){
        let userInfo: [AnyHashable: Any] = ["user" : user, "online" : online, "time" : time]
        self.nc.post(name: QiscusNotification.USER_PRESENCE, object: nil, userInfo: userInfo)
    }
    
    public class func publish(messageStatus comment:CommentModel, status:CommentStatus, room:RoomModel){
        let notification = QiscusNotification.shared
        notification.publish(messageStatus: comment, status: status, room: room)
    }
    
    private func publish(messageStatus comment:CommentModel, status:CommentStatus, room:RoomModel){
        let userInfo: [AnyHashable: Any] = ["comment" : comment, "status": status, "room":room]
        self.nc.post(name: QiscusNotification.MESSAGE_STATUS, object: nil, userInfo: userInfo)
    }
    
    public class func publish(commentDeleteOnRoom room:RoomModel, comment:CommentModel, status:CommentStatus){
        let notification = QiscusNotification.shared
        notification.publish(commentDeleteOnRoom: room, comment: comment, status: status)
    }
    
    private func publish(commentDeleteOnRoom room:RoomModel, comment:CommentModel, status:CommentStatus) {
         let userInfo: [AnyHashable: Any] = ["comment" : comment, "status": status, "room":room]
        self.nc.post(name: QiscusNotification.COMMENT_DELETE(onRoom: room.id), object: nil, userInfo: userInfo)
    }
    
    public class func publish(roomChange room:RoomModel){
        let notification = QiscusNotification.shared
        notification.publish(roomChange: room)
    }
    
    private func publish(roomChange room:RoomModel){
        let userInfo: [AnyHashable: Any] = [
            "room"      : room
        ]
        self.nc.post(name: QiscusNotification.ROOM_CHANGE(onRoom: room.id), object: nil, userInfo: userInfo)
    }
    
    public class func publish(roomOrder change:Bool = true){
        let notification = QiscusNotification.shared
        notification.roomOrderChange()
    }
    
    private func roomOrderChange(){
        if self.roomOrderTimer != nil {
            self.roomOrderTimer?.invalidate()
        }
        self.roomOrderTimer = Timer.scheduledTimer(timeInterval: 1.3, target: self, selector: #selector(self.publishRoomOrderChange), userInfo: nil, repeats: false)
    }
    
    @objc private func publishRoomOrderChange(){
        self.nc.post(name: QiscusNotification.ROOM_ORDER_MAY_CHANGE, object: nil, userInfo: nil)
        self.roomOrderTimer = nil
    }
    
    public class func publish(roomDeleted roomId:String){
        let notification = QiscusNotification.shared
        notification.publish(roomDeleted: roomId)
    }
    
    private func publish(roomDeleted roomId:String){
        let userInfo: [AnyHashable: Any] = ["room_id" : roomId]
        self.nc.post(name: QiscusNotification.ROOM_DELETED, object: nil, userInfo: userInfo)
    }
    
    public class func publish(userAvatarChange user:UserModel){
        let notification = QiscusNotification.shared
        notification.publish(userAvatarChange: user)
    }
    
    private func publish(userAvatarChange user:UserModel){
        let userInfo: [AnyHashable: Any] = ["user" : user]
        self.nc.post(name: QiscusNotification.USER_AVATAR_CHANGE, object: nil, userInfo: userInfo)
    }
    
    public class func publish(userNameChange user:UserModel){
        let notification = QiscusNotification.shared
        notification.publish(userNameChange: user)
    }
    
    private func publish(userNameChange user:UserModel){
        let userInfo: [AnyHashable: Any] = ["user" : user]
        self.nc.post(name: QiscusNotification.USER_NAME_CHANGE, object: nil, userInfo: userInfo)
    }
    
}

