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

class ChatListViewController: UIChatListViewController {

    override open func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Chat List"
        self.delegate = self
        
        self.registerCell(nib: CustomChatListCell.nib, forCellWithReuseIdentifier: CustomChatListCell.identifier)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "💬", style: .plain, target: self, action: #selector(chatBot))
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @objc func chatBot() {
        let alert = UIAlertController(title: "Chat with user", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Qiscus User or email"
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            if let name = alert.textFields?.first?.text {
                QiscusCore.shared.getRoom(withUser: name, onSuccess: { (room, comments) in
                    self.chat(withRoom: room)
                }) { (error) in
                    print("error chat: \(error.message)")
                }
            }
        }))
        
        self.present(alert, animated: true)
        
    }
    
    @objc func logout() {
        QiscusCore.logout { (error) in
            let local = UserDefaults.standard
            local.removeObject(forKey: "AppID")
            local.synchronize()
            let app = UIApplication.shared.delegate as! AppDelegate
            app.auth()
        }
    }
    
    func chat(withRoom room: RoomModel){
        let target = ChatViewController()
        target.room = room
        self.navigationController?.pushViewController(target, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let room = self.rooms[indexPath.row]
        self.chat(withRoom: room)
    }
}

extension ChatListViewController: UIChatListViewDelegate {
    func uiChatList(tableView: UITableView, cellForRoom room: RoomModel, atIndexPath indexpath: IndexPath) -> BaseChatListCell? {

        return tableView.dequeueReusableCell(withIdentifier: CustomChatListCell.identifier, for: indexpath) as? CustomChatListCell
    }
    
}


