//
//  UIChatListPresenter.swift
//  QiscusUI
//
//  Created by Qiscus on 30/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import Foundation
import QiscusCore

protocol UIChatListView {
    func setEmptyData(message: String)
    func didFinishLoadChat(rooms : [QChatRoom])
    func updateRooms(data: QChatRoom)
    func didUpdate(user: QParticipant, isTyping typing: Bool, in room: QChatRoom)
}

class UIChatListPresenter {
    
    private var viewPresenter : UIChatListView?
    var rooms : [QChatRoom] = [QChatRoom]()
    
    init() {
        QiscusCoreManager.qiscusCore1.delegate = self
    }
    
    func attachView(view : UIChatListView){
        viewPresenter = view
    }
    
    func detachView() {
        viewPresenter = nil
    }
    
    func loadChat() {
        self.loadFromLocal()
    }
    
    func reLoadChat() {
       self.loadFromServer()
    }
    
    private func loadFromLocal(refresh: Bool = true) {
        // get from local
        let localdb = QiscusCoreManager.qiscusCore1.database.room.all()
        self.rooms = filterRoom(data: localdb)
        if refresh {
            self.viewPresenter?.didFinishLoadChat(rooms: self.rooms)
        }
        
        //for sub
        //sample code for subscribe room manually
        //QiscusCore.shared.subscribeChatRooms(self.rooms)
        
        //for unsub
        //sample code for unSubscribe room manually
        //QiscusCore.shared.unSubcribeChatRooms(self.rooms)
        if refresh{
             self.loadFromServer()
        }
       
    }
    
    // Hide empty rooms
    func filterRoom(data: [QChatRoom]) -> [QChatRoom] {
        var source = data
        //source = source.filter({ ($0.lastComment != nil || $0.type != .single) })
        source.sort { (room1, room2) -> Bool in
            if let comment1 = room1.lastComment, let comment2 = room2.lastComment {
                return comment1.unixTimestamp > comment2.unixTimestamp
            }else {
                return false
            }
        }
        return source
    }
    
    private func loadFromServer() {
        // check update from server
        QiscusCoreManager.qiscusCore1.shared.getAllChatRooms(showParticipant: true, showRemoved: false, showEmpty: true, page: 1, limit: 100, onSuccess: { (results, meta) in
            self.rooms = self.filterRoom(data: results)
            self.viewPresenter?.didFinishLoadChat(rooms: self.rooms)
        }, onError: { (error) in
            if  self.rooms.count == 0{
                self.viewPresenter?.setEmptyData(message: "")
            }
        })
        
    }
    
}

extension UIChatListPresenter : QiscusCoreDelegate {
    func onRoomMessageUpdated(_ room: QChatRoom, message: QMessage) {
        loadFromLocal(refresh: false)
        self.viewPresenter?.updateRooms(data: room)
    }

    func onRoomMessageReceived(_ room: QChatRoom, message: QMessage){
        // show in app notification
        print("got new comment: \(message.message)")
        self.rooms = filterRoom(data: self.rooms)
        self.viewPresenter?.updateRooms(data: room)
        
    }
    
    func onRoomMessageDelivered(message : QMessage){
        //
    }
    
    func onRoomMessageRead(message : QMessage){
        //
    }
    
    func onChatRoomCleared(roomId : String){
        self.loadFromLocal()
    }
    
    func onRoomMessageDeleted(room: QChatRoom, message: QMessage) {
        //
    }
    
    func gotNew(room: QChatRoom) {
        // add not if exist
        loadFromLocal(refresh: false)
        self.viewPresenter?.updateRooms(data: room)
    }
    
    func onRoom(deleted room: QChatRoom) {
        self.loadFromLocal()
    }
    func onRoom(update room: QChatRoom) {
        self.loadFromLocal()
    }
    
    //this func was deprecated
    func onRoomDidChangeComment(comment: QMessage, changeStatus status: QMessageStatus) {
        print("check commentDidChange = \(comment.message) status = \(status.rawValue)")
    }
}
