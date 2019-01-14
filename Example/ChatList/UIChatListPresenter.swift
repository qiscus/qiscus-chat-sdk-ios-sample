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
        QiscusCore.shared.isOnline(true)
    }
    
    func detachView() {
        viewPresenter = nil
    }
    
    func loadChat() {
        if self.rooms.isEmpty {
            self.loadFromServer()
        }
        self.loadFromLocal()
    }
    
    func reLoadChat() {
       self.loadFromServer()
    }
    
    private func loadFromLocal(refresh: Bool = true) {
        // get from local
        self.rooms = QiscusCore.database.room.all()
        if refresh {
            self.viewPresenter?.didFinishLoadChat(rooms: self.rooms)
        }
    }
    
    private func loadFromServer() {
        // check update from server
        QiscusCore.shared.getAllRoom(limit: 50, page: 1, onSuccess: { (results, meta) in
            self.rooms = results
            self.viewPresenter?.didFinishLoadChat(rooms: results)
            self.loadFromLocal() // load from local without refresh, improve tableview move
        }) { (error) in
            self.viewPresenter?.setEmptyData(message: "")
        }
    }
    
}

extension UIChatListPresenter : QiscusCoreDelegate {
    func onRoom(deleted room: RoomModel) {
        //
    }
    func onRoom(update room: RoomModel) {
        //
    }
    
    func onChange(user: MemberModel, isOnline online: Bool, at time: Date) {
        //
    }
    
    func onRoom(_ room: RoomModel, didDeleteComment comment: CommentModel) {
        //
    }
    
    func onRoom(_ room: RoomModel, gotNewComment comment: CommentModel) {
        // show in app notification
        print("got new comment: \(comment.message)")
        self.viewPresenter?.updateRooms(data: room)
        // MARK: TODO check room already exist?
        if !rooms.contains(where: { $0.id == room.id}) {
            loadFromServer()
        }else {
            loadFromLocal(refresh: false)
        }
        
    }
    
    func onRoom(_ room: RoomModel, didChangeComment comment: CommentModel, changeStatus status: CommentStatus) {
        //
    }
    
    func onRoom(_ room: RoomModel, thisParticipant user: MemberModel, isTyping typing: Bool) {
        self.viewPresenter?.didUpdate(user: user, isTyping: typing, in: room)
    }
    
    func gotNew(room: RoomModel) {
        // add not if exist
    }

    func remove(room: RoomModel) {
        //
    }
}
