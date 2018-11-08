//
//  QRoomListCell.swift
//  Example
//
//  Created by Ahmad Athaullah on 9/15/17.
//  Copyright © 2017 Ahmad Athaullah. All rights reserved.
//

import UIKit
import QiscusCore

open class QRoomListCell: UITableViewCell {
    
    public var searchText = ""{
        didSet{
            self.searchTextChanged()
        }
    }
    
    public var room:RoomModel? {
        didSet{
            setupUI()
            
//            if let oldRoom = oldValue {
//                if !oldRoom.isInvalidated {
//                    let roomId = oldRoom.id
//                    self.unsubscribeEvent(roomId: roomId)
//                }
//            }
            
            if let currentRoom = room {
                let roomId = currentRoom.id
                self.subscribeEvent(roomId: roomId)
            }
        }
    }

    func subscribeEvent(roomId: String) {
        let center: NotificationCenter = NotificationCenter.default
        //center.addObserver(self, selector: #selector(QRoomListCell.userTyping(_:)), name: QiscusNotification.USER_TYPING(onRoom: roomId), object: nil)
       // center.addObserver(self, selector: #selector(QRoomListCell.roomChangeNotif(_:)), name: QiscusNotification.ROOM_CHANGE(onRoom: roomId), object: nil)
    }
    
    func unsubscribeEvent(roomId: String) {
        let center: NotificationCenter = NotificationCenter.default
        center.removeObserver(self, name: QiscusNotification.USER_TYPING(onRoom: roomId), object: nil)
        center.removeObserver(self, name: QiscusNotification.ROOM_CHANGE(onRoom: roomId), object: nil)
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        let center: NotificationCenter = NotificationCenter.default
        center.addObserver(self, selector: #selector(QRoomListCell.newCommentNotif(_:)), name: QiscusNotification.GOT_NEW_COMMENT, object: nil)
    }

    override open func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /**
    Config Custom Cell
    */
    open func setupUI(){}
    
    
   // open func onUserTyping(user:QUser, typing:Bool){}
    
    open func onRoomChange(room: RoomModel){
        self.room = room
    }
    
    open func gotNewComment(comment:CommentModel){
//        self.room = comment.room!
    }
    
    
    open func searchTextChanged(){}
//
//    @objc private func userTyping(_ notification: Notification){
//        if let userInfo = notification.userInfo {
//            let user = userInfo["user"] as! QUser
//            let typing = userInfo["typing"] as! Bool
//            let room = userInfo["room"] as! QRoom
//
//            if self.room?.id != room.id { return}
//            self.onUserTyping(user: user, typing: typing)
//        }
//    }
    @objc private func newCommentNotif(_ notification: Notification){
        if let userInfo = notification.userInfo {
            if let currentRoom = self.room {
                
                if let comment = userInfo["comment"] as? CommentModel{
                    self.gotNewComment(comment: comment)
                }
            }
        }
    }
    
    @objc private func roomChangeNotif(_ notification: Notification){
        if let userInfo = notification.userInfo {
            if let room = userInfo["room"] as? RoomModel {
                
                
//                    if let property = userInfo["property"] as? QRoomProperty {
//                        switch property {
//                        case .name:
//                            self.roomDataChange()
//                            break
//                        case .avatar:
//                            self.roomAvatarChange()
//                            break
//                        case .participant:
//                            self.roomParticipantChange()
//                            break
//                        case .lastComment:
//                            self.roomLastCommentChange()
//                            break
//                        case .unreadCount:
//                            self.roomUnreadCountChange()
//                            break
//                        case .data:
//                            self.roomDataChange()
//                            break
//                        }
//                    }
                    if room.id == self.room?.id {
                        self.onRoomChange(room: room)
                    }
                
            }
        }
    }
    open func roomNameChange(){}
    open func roomAvatarChange(){}
    open func roomParticipantChange(){}
    open func roomLastCommentChange(){}
    open func roomUnreadCountChange(){}
    open func roomDataChange(){}
}
