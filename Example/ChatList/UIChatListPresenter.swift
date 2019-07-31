//
//  UIChatListPresenter.swift
//  QiscusUI
//
//  Created by Qiscus on 30/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import Foundation
import QiscusCore
import SwiftyJSON

protocol UIChatListView {
    func setEmptyData(message: String)
    func didFinishLoadChat(rooms : [RoomModel])
    func updateRooms(data: RoomModel)
    func didUpdate(user: MemberModel, isTyping typing: Bool, in room: RoomModel)
}

class UIChatListPresenter {
    
    private var viewPresenter : UIChatListView?
    var typeTabAll: Bool = true
    var rooms : [RoomModel] = [RoomModel]()
    var page : Int = 1
    init() {
        QiscusCore.delegate = self
    }
    
    func attachView(view : UIChatListView, typeTabAll : Bool = true){
        self.typeTabAll = typeTabAll
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
        var localdb = QiscusCore.database.room.all()
        
        var roomsDB : [RoomModel] = [RoomModel]()
        
        for (index, db) in localdb.enumerated(){
            if localdb[index].id != ""{
                roomsDB.append(db)
            }
        }
        
        self.rooms = roomsDB
        self.rooms = filterRoom(data:  self.rooms)
        self.rooms = filterTypeChannel(data:  self.rooms)
        
        if refresh {
            self.viewPresenter?.didFinishLoadChat(rooms:self.rooms)
        }
    }
    
    
    func filterRoom(data: [RoomModel]) -> [RoomModel] {
        var source = data
        source.sort { (room1, room2) -> Bool in
            if let comment1 = room1.lastComment, let comment2 = room2.lastComment {
                return comment1.unixTimestamp > comment2.unixTimestamp
            }else {
                return false
            }
        }
        return source
    }
    
    func filterTypeChannel(data: [RoomModel])-> [RoomModel]{
        var source = data
        source = source.filter({ (room) -> Bool in
            if let option = room.options{
                if !option.isEmpty{
                    let json = JSON.init(parseJSON: option)
                    let is_resolved = json["is_resolved"].bool ?? false
                    
                    if typeTabAll{
                        if is_resolved == true {
                            return false
                        }else{
                            return true
                        }
                    }else{
                        if is_resolved == true {
                            return true
                        }else{
                            return false
                        }
                    }
                    
                }else{
                    return false
                }
            }else{
                return false
            }
           
        })
        
        return source
    }
    
    public func loadFromServer() {
        // check update from server
        QiscusCore.shared.getAllRoom(limit: 100, page: 1, showEmpty: false, onSuccess: { (results, meta) in
                self.rooms = self.filterRoom(data: results)
                self.rooms = self.filterTypeChannel(data: self.rooms)
                
                self.viewPresenter?.didFinishLoadChat(rooms: self.rooms)
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
        //patch hack, something presenter not working
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "reloadCell"), object: nil)
    }

    func gotNew(room: RoomModel) {
        // add not if exist
        self.loadFromLocal(refresh: true)
    }

    func remove(room: RoomModel) {
        //
    }
}
