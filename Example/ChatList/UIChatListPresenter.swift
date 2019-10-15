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
    func didFinishLoadChat(rooms : [RoomModel])
    func updateRooms(data: RoomModel)
    func didUpdate(user: MemberModel, isTyping typing: Bool, in room: RoomModel)
}

class UIChatListPresenter {
    
    private var viewPresenter : UIChatListView?
    var rooms : [RoomModel] = [RoomModel]()
    
    init() {
        QiscusCore.delegate = self
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
        let localdb = QiscusCore.database.room.all()
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
    func filterRoom(data: [RoomModel]) -> [RoomModel] {
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
        QiscusCore.shared.getAllChatRooms(showParticipant: true, showRemoved: false, showEmpty: true, page: 1, limit: 100, onSuccess: { (results, meta) in
            self.rooms = self.filterRoom(data: results)
            self.viewPresenter?.didFinishLoadChat(rooms: self.rooms)
        }, onError: { (error) in
            self.viewPresenter?.setEmptyData(message: "")
        })
        
    }
    
}

extension UIChatListPresenter : QiscusCoreDelegate {
    func onRoomMessageReceived(_ room: RoomModel, message: CommentModel){
        // show in app notification
        print("got new comment: \(message.message)")
        self.viewPresenter?.updateRooms(data: room)
        if !rooms.contains(where: { $0.id == room.id}) {
            loadFromServer()
        }else {
            loadFromLocal(refresh: false)
        }
        
    }
    
    func onRoomMessageDelivered(message : CommentModel){
        //
    }
    
    func onRoomMessageRead(message : CommentModel){
        //
    }
    
    func onChatRoomCleared(roomId : String){
        self.loadFromLocal()
    }
    
    func onRoomMessageDeleted(room: RoomModel, message: CommentModel) {
        //
    }
    
    func gotNew(room: RoomModel) {
        // add not if exist
        loadFromLocal(refresh: true)
    }
    
    func onRoom(deleted room: RoomModel) {
        self.loadFromLocal()
    }
    func onRoom(update room: RoomModel) {
        self.loadFromLocal()
    }
    
    //this func was deprecated
    func onRoomDidChangeComment(comment: CommentModel, changeStatus status: CommentStatus) {
        print("check commentDidChange = \(comment.message) status = \(status.rawValue)")
    }
}
