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
import Alamofire

protocol UIChatListView {
    func setEmptyData(message: String)
    func didFinishLoadChat(rooms : [RoomModel])
    func updateRooms(data: RoomModel)
    func didUpdate(user: MemberModel, isTyping typing: Bool, in room: RoomModel)
}

public enum typeTab: String {
    case ALL = "ALL"
    case ONGOING = "ONGOING"
    case RESOLVED = "RESOLVED"
    
    static let all = [ALL,ONGOING,RESOLVED]
}

class UIChatListPresenter {
    
    private var viewPresenter : UIChatListView?
    var typeTabAll: Bool = true
    var typeTab: typeTab = .ALL
    var rooms : [RoomModel] = [RoomModel]()
    var page : Int = 1
    init() {
        QiscusCore.delegate = self
    }
    
//    func attachView(view : UIChatListView, typeTabAll : Bool = true){
//        self.typeTabAll = typeTabAll
//        viewPresenter = view
//    }
    
    func attachView(view : UIChatListView, typeTab : typeTab){
        self.typeTab = typeTab
        viewPresenter = view
    }
    
    func setDelegate(){
        QiscusCore.delegate = self
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
//        var localdb = QiscusCore.database.room.all()
//
//        var roomsDB : [RoomModel] = [RoomModel]()
//
//        for (index, db) in localdb.enumerated(){
//            if localdb[index].id != ""{
//                roomsDB.append(db)
//            }
//        }
//
//        self.rooms = roomsDB
//        self.rooms = filterRoom(data:  self.rooms)
//
//        if typeTab == .ALL {
//            //no action
//        }else if typeTab == .ONGOING {
//            self.rooms = filterTypeOnGoing(data:  self.rooms)
//        }else if typeTab == .RESOLVED {
//            self.rooms = filterTypeResolved(data:  self.rooms)
//        }
//

        loadFromServer()
        
    }
    
    
    func filterRoom(data: [RoomModel]) -> [RoomModel] {
        var source = data
        
        source = source.filter({ (room) -> Bool in
            if room.name.contains("notifications"){
                return false
            } else {
                return true
            }
            
        })
        
        source.sort { (room1, room2) -> Bool in
            if let comment1 = room1.lastComment, let comment2 = room2.lastComment {
                return comment1.unixTimestamp > comment2.unixTimestamp
            }else {
                return false
            }
        }
        
        return source
    }
    
    func filterTypeResolved(data: [RoomModel])-> [RoomModel]{
        var source = data
        
        source = source.filter({ (room) -> Bool in
            if let option = room.options{
                if !option.isEmpty{
                    let json = JSON.init(parseJSON: option)
                    let is_resolved = json["is_resolved"].bool ?? false
                    
                    if is_resolved == false {
                        return false
                    }else{
                        return true
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
    
    func filterTypeOnGoing(data: [RoomModel])-> [RoomModel]{
        var source = data
        
        source = source.filter({ (room) -> Bool in
            if let option = room.options{
                if !option.isEmpty{
                    let json = JSON.init(parseJSON: option)
                    let is_resolved = json["is_resolved"].bool ?? false
                    
                    if is_resolved == false {
                        return true
                    }else{
                        return false
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
        QiscusCore.shared.getAllRoom(limit: 50, page: 1, showEmpty: false, onSuccess: { (results, meta) in
                self.page = 1
                self.rooms = self.filterRoom(data: results)
                if self.typeTab == .ALL {
                //no action
                }else if self.typeTab == .ONGOING {
                    self.rooms = self.filterTypeOnGoing(data:  self.rooms)
                }else if self.typeTab == .RESOLVED {
                    self.rooms = self.filterTypeResolved(data:  self.rooms)
                }
                
                self.viewPresenter?.didFinishLoadChat(rooms: self.rooms)
        }) { (error) in
            self.viewPresenter?.setEmptyData(message: "")
        }
    }
    
    public func loadMoreFromServer() {
        if self.page == 1 {
            self.page = 2
        }
        QiscusCore.shared.getAllRoom(limit: 50, page: self.page, showEmpty: false, onSuccess: { (results, meta) in
            if results.count != 0 {
                self.page += 1
                self.rooms.append(contentsOf: results)
                
                self.rooms = self.filterRoom(data: self.rooms)
                if self.typeTab == .ALL {
                    //no action
                }else if self.typeTab == .ONGOING {
                    self.rooms = self.filterTypeOnGoing(data:  self.rooms)
                }else if self.typeTab == .RESOLVED {
                    self.rooms = self.filterTypeResolved(data:  self.rooms)
                }
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                  self.viewPresenter?.didFinishLoadChat(rooms: self.rooms)
                }
                

            }else{
                if self.typeTab == .ALL {
                    //no action
                }else if self.typeTab == .ONGOING {
                    self.rooms = self.filterTypeOnGoing(data:  self.rooms)
                }else if self.typeTab == .RESOLVED {
                    self.rooms = self.filterTypeResolved(data:  self.rooms)
                }
                
                self.viewPresenter?.didFinishLoadChat(rooms: self.rooms)
            }
            
           
        }) { (error) in
            self.viewPresenter?.setEmptyData(message: "")
        }
    }
    
}

extension UIChatListPresenter : QiscusCoreDelegate {
    func onRoomMessageUpdated(_ room: RoomModel, message: CommentModel) {
        
    }
    func onRoomMessageReceived(_ room: RoomModel, message: CommentModel) {
        // show in app notification
        print("got new comment: \(message.message)")
        
        
        let checkRoom = self.rooms.filter{ $0.id == room.id }
        
        if checkRoom.count == 0 {
            self.rooms.append(room)
        }else{
            self.rooms = self.rooms.map { (roomArray) -> RoomModel in
                var roomData = roomArray
                if roomData.id == room.id {
                    roomData = room
                }
                return roomData
            }
        }
        
        self.rooms = self.filterRoom(data: self.rooms)
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "reloadCell"), object: nil)
        
        self.checkRoomOption(room: room, comment: message)
    }
    
    func onRoomMessageDeleted(room: RoomModel, message: CommentModel) {
         self.loadFromLocal()
    }
    
    func onRoomMessageDelivered(message: CommentModel) {
        
    }
    
    func onRoomMessageRead(message: CommentModel) {
        
    }
    
    func onChatRoomCleared(roomId: String) {
        
    }
    
    func onRoomDidChangeComment(comment: CommentModel, changeStatus status: CommentStatus) {
        print("check commentDidChange = \(comment.message) status = \(status.rawValue)")
    }
    
    func onRoom(deleted room: RoomModel) {
        self.loadFromLocal()
    }
    func onRoom(update room: RoomModel) {
        self.loadFromLocal()
    }

    func gotNew(room: RoomModel) {
        // add not if exist
        self.loadFromLocal(refresh: true)
    }

    func remove(room: RoomModel) {
        //
    }
    
    func checkRoomOption(room : RoomModel, comment: CommentModel){
        if let room = QiscusCore.database.room.find(id: room.id){
            if let option = room.options{
                if !option.isEmpty{
                    var json = JSON.init(parseJSON: option)
                    let channelType = json["channel"].string ?? "qiscus"
                    if channelType.lowercased() == "wa"{
                        let lastCustommerTimestamp = json["last_customer_message_timestamp"].string ?? ""
                        if comment.username.lowercased() == room.name{
                            //update db
                            json["last_customer_message_timestamp"] = JSON(lastCustommerTimestamp)
                            
                            if let rawData = json.rawString() {
                                let room = room
                                room.options = rawData
                                QiscusCore.database.room.save([room])
                            }
                        }else{
                            var customerEmail = ""
                            //check again, maybe roomName was changed
                            if let participants = room.participants {
                                for participant in participants.enumerated(){
                                    if participant.element.extras != nil {
                                        let dataJson = JSON(participant.element.extras)
                                        let customer = dataJson["is_customer"].bool ?? false
                                        if customer == true {
                                            customerEmail = participant.element.email
                                        }
                                    }
                                }
                                
                                if comment.userEmail.lowercased() == customerEmail{
                                    json["last_customer_message_timestamp"] = JSON(lastCustommerTimestamp)
                                    if let rawData = json.rawString() {
                                        let room = room
                                        room.options = rawData
                                        QiscusCore.database.room.save([room])
                                    }else{
                                        if comment.userExtras?.isEmpty == true {
                                            //update db
                                            json["last_customer_message_timestamp"] = JSON(lastCustommerTimestamp)
                                            
                                            if let rawData = json.rawString() {
                                                let room = room
                                                room.options = rawData
                                                QiscusCore.database.room.save([room])
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
}
