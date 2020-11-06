//
//  ForwardViewController.swift
//  Example
//
//  Created by Qiscus on 04/11/20.
//  Copyright © 2020 Qiscus. All rights reserved.
//

import UIKit
import QiscusCore

class ForwardViewController: UIViewController {
    
    var selectedMessage : [CommentModel] = [CommentModel]()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewSelected: UIView!
    @IBOutlet weak var collectionSelected: UICollectionView!
    @IBOutlet weak var lblContact: UILabel!
    @IBOutlet weak var heightViewSelected: NSLayoutConstraint!
    @IBOutlet weak var actIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    var rooms: [RoomModel] = []
    var roomsSelected: [RoomModel] = []
    
    var searchActive : Bool = false
    var keywordSearch : String? = nil
    var page : Int = 1
    var userOnline : [RoomModel] = [RoomModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        setupTableView()
        setupSearchBar()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func setupData() {
        self.getRooms()
        self.actIndicator.stopAnimating()
        selectedViewState()
    }
    
    func sortRoom(data: [RoomModel]) -> [RoomModel] {
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
    
    func filterRoom(query: String, data: [RoomModel]) -> [RoomModel] {
        var source = data
        source = source.filter({ ($0.name.lowercased().contains(query.lowercased())) })
        return source
    }
    
    func sortRoomSingle(data: [RoomModel]) -> [RoomModel] {
        var source = data
        source = source.filter({ ($0.type == .single) })
        return source
    }
    
    func setupTableView() {
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.register(UINib(nibName: "ForwardAddCell", bundle:nil), forCellReuseIdentifier: "forwardAddCell")
    }
    
    
    func setupSearchBar(){
        //setup search
        searchBar.delegate = self
        searchBar.backgroundImage = UIImage()
        searchBar.showsCancelButton = false
    }
    
    func setupCollectionView() {
        self.collectionSelected.delegate = self
        self.collectionSelected.dataSource = self
        
        self.collectionSelected.register(UINib(nibName: "ForwardSelectedCell", bundle:nil), forCellWithReuseIdentifier: "forwardSelectedCell")
        
    }
    
    private func selectedViewState() {
        if roomsSelected.isEmpty {
            self.viewSelected.isHidden = true
            self.heightViewSelected.constant = 0
        } else {
            self.viewSelected.isHidden = false
            self.heightViewSelected.constant = 120
        }
    }
    
    @IBAction func onBackClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func onRoomSelect(room: RoomModel?) {
        guard let room =  room else {
            return
        }
        
        isSelected(room: room, completion: { isSelect, position in
            if isSelect {
                self.roomsSelected.remove(at: position)
            } else {
                self.roomsSelected.append(room)
            }
            
            self.collectionSelected.reloadData()
            self.selectedViewState()
        })
        
    }
    
    func isSelected(room: RoomModel, completion: @escaping (_ isSelect: Bool, _ position: Int) -> ()) {
        var isSelected = false
        var pos = 0
        for c in roomsSelected {
            if c.id == room.id {
                isSelected = true
                break
            }
            pos += 1
        }
        completion(isSelected, pos)
    }
    @IBAction func addContactAction(_ sender: Any) {
        if self.roomsSelected.count == 0 {
            return
        }else{
            for room in self.roomsSelected{
                for comment in selectedMessage {
                    let forwardComment = CommentModel()
                    forwardComment.roomId = room.id
                    forwardComment.message = comment.message
                    if comment.type == "reply"{
                        forwardComment.type    = "text"
                    }else{
                        forwardComment.type    = comment.type
                        forwardComment.payload = comment.payload
                    }
                   
                    QiscusCore.shared.sendMessage(message: forwardComment, onSuccess: { (comment) in
                        //success
                    }, onError: { (error) in
                       //failed
                    })
                }
            }
            
           self.navigationController?.popViewController(animated: true)
            
        }
    }
    
    @objc func getRooms(){
        if let isSearch = self.keywordSearch {
            
            if isSearch == "" {
                //searchActive but empty query
                let localdb = QiscusCore.database.room.all()
                self.rooms = self.sortRoom(data: localdb)
                
                self.sortRoomUserPresence()
                self.tableView.reloadData()
            }else{
                //searchActive
                let localdb = QiscusCore.database.room.all()
                self.rooms = self.filterRoom(query: isSearch, data: localdb)
                self.rooms = self.sortRoom(data: self.rooms)
                
                self.sortRoomUserPresence()
                self.tableView.reloadData()
            }
            
        }else{
            //searchNotActive
            let localdb = QiscusCore.database.room.all()
            self.rooms = self.sortRoom(data: localdb)
            
            self.sortRoomUserPresence()
            self.tableView.reloadData()
        }
    }
    
    func sortRoomUserPresence(){
        self.userOnline.removeAll()
        let singleRoom = self.sortRoomSingle(data: self.rooms)
        let arrayRooms = singleRoom.chunked(by: 19)
        for newRooms in arrayRooms{
            getUserPresence(rooms: newRooms)
        }
    }
    
    func getUserPresence(rooms:  [RoomModel]){
        guard let email = QiscusCore.getUserData()?.email else {
            return
        }
        var participantIDs = [String]()
        for room in rooms {
            guard let participants = room.participants else {return}
            guard participants.count > 0 else {return}
            
            let participant = room.participants!.filter{$0.email != email}.first!
            
            participantIDs.append(participant.email)
        }
        
        if participantIDs.count == 0 {
            return
        }
        
        QiscusCore.shared.getUserPresence(userIds: participantIDs, onSuccess: { (users) in
            for user in users {
                guard let userdb = QiscusCore.database.member.find(byUserId: user.userId) else {return}
                for (index, roomData) in  self.rooms.enumerated() {
                    if roomData.type == .single{
                        for participant in roomData.participants!{
                            if participant.id == user.userId {
                                let room = self.rooms[index]
                                if user.status == true {
                                    //check already in array or not
                                    let checkOnline = self.userOnline.filter{roomData in
                                       return room.id == roomData.id
                                    }
                                    
                                    if checkOnline.count == 1{
                                        //no action already in array self.userOnline
                                    }else{
                                        self.userOnline.append(room)
                                    }
                                    
                                }else{
                                    //if already online and update from backend is offline, remove from array
                                    for (index, userOnline) in  self.userOnline.enumerated() {
                                       let checkRoom = userOnline.participants?.filter{member in
                                            return member.email == userdb.email
                                        }
                                        if checkRoom?.count == 1 {
                                            self.userOnline.remove(at: index)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
             self.tableView.reloadData()
        }) { (error) in
             self.tableView.reloadData()
        }
    }
    
}

extension ForwardViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = self.rooms[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "forwardAddCell", for: indexPath) as! ForwardAddCell
        
        let userOnline = self.userOnline
        if userOnline.count != 0 {
            let filteredUsers = userOnline.filter{($0.id == data.id )}
            if filteredUsers.count != 0 {
                cell.isOnline = true
            }else{
               cell.isOnline = false
            }
        }else{
            cell.isOnline = false
        }
        
        
        cell.data = data
        cell.onSelected = ({ room in
            self.onRoomSelect(room: room)
        })
        isSelected(room: data, completion: { isSelect, position in
            cell.checked = isSelect
        })
        
        return cell
    }
    
}

extension ForwardViewController: UITableViewDelegate {
    
}

extension ForwardViewController: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return roomsSelected.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = roomsSelected[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "forwardSelectedCell", for: indexPath) as! ForwardSelectedCell
        
        cell.data = data
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: 80.0, height: 80.0)
    }
}

extension ForwardViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.text = ""
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false
        self.rooms.removeAll()
        self.tableView.reloadData()
        self.keywordSearch = nil
        self.page = 1
        self.getRooms()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
    func searchBar(_ owsearchBar: UISearchBar, textDidChange searchText: String) {
        self.keywordSearch = searchText
        self.page = 1
        self.rooms.removeAll()
        self.tableView.reloadData()
        NSObject.cancelPreviousPerformRequests(withTarget: self,
                                               selector: #selector(self.getRooms),
                                               object: nil)
        
        perform(#selector(self.getRooms),
                with: nil, afterDelay: 0.5)
        
    }
}

