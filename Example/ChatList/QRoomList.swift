//
//  ListChatViewController.swift
//  example
//
//  Created by Qiscus on 30/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import UIKit
import QiscusUI
import QiscusCore

open class QRoomList: UIChatListViewController {

    override open func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Chat List"
        self.delegate = self
        
        self.registerCell(nib: QRoomListDefaultCell.nib, forCellWithReuseIdentifier: QRoomListDefaultCell.identifier)
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let room = self.rooms[indexPath.row]
        self.chat(withRoom: room)
    }
    
    open func chat(withRoom room: RoomModel){
        let target = QiscusChatVC()
        target.room = room
        self.navigationController?.pushViewController(target, animated: true)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
}

extension QRoomList: UIChatListViewDelegate {
    public func uiChatList(tableView: UITableView, cellForRoom room: RoomModel, atIndexPath indexpath: IndexPath) -> BaseChatListCell? {

        return tableView.dequeueReusableCell(withIdentifier: QRoomListDefaultCell.identifier, for: indexpath) as? BaseChatListCell
    }
    
}


