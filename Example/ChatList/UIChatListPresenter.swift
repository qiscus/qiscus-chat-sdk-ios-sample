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
        
        if self.rooms.isEmpty {
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
        QiscusCore.shared.getAllRoom(limit: 100, page: 1, showEmpty: false, onSuccess: { (results, meta) in
            self.rooms = results
            self.viewPresenter?.didFinishLoadChat(rooms: results)
        }) { (error) in
            self.viewPresenter?.setEmptyData(message: "")
        }
    }
    
}

extension UIChatListPresenter : QiscusCoreDelegate {
    func onRoomDidChangeComment(comment: CommentModel, changeStatus status: CommentStatus) {
        print("check commentDidChange = \(comment.message) status = \(status.rawValue)")
    }
    
    func onRoom(deleted room: RoomModel) {
        self.loadFromLocal()
    }
    func onRoom(update room: RoomModel) {
        self.loadFromLocal()
    }
    
    func onRoom(_ room: RoomModel, didDeleteComment comment: CommentModel) {
        //
    }
    
    func onRoom(_ room: RoomModel, gotNewComment comment: CommentModel) {
        // show in app notification
        print("got new comment: \(comment.message)")
        self.viewPresenter?.updateRooms(data: room)
        if !rooms.contains(where: { $0.id == room.id}) {
            loadFromServer()
        }else {
            loadFromLocal(refresh: false)
        }
        
    }

    func gotNew(room: RoomModel) {
        // add not if exist
        loadFromLocal(refresh: true)
    }

    func remove(room: RoomModel) {
        //
    }
}
