//
//  UIChatListViewController.swift
//  QiscusUI
//
//  Created by Qiscus on 30/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import UIKit
import QiscusCore
import XLPagerTabStrip

class UIChatListViewController: UIViewController, IndicatorInfoProvider {
    @IBOutlet weak var btStartChat: UIButton!
    @IBOutlet weak var emptyRoomView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    
    public var labelProfile = UILabel()
    private let presenter : UIChatListPresenter = UIChatListPresenter()
    private let refreshControl = UIRefreshControl()
    var lastRoomCount: Int = 0
    var rooms : [RoomModel] {
        get {
            return presenter.rooms
        }
    }
    
    // MARK: - IndicatorInfoProvider
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "ALL")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.presenter.loadFromServer()
        
        NotificationCenter.default.addObserver(self, selector: #selector(UIChatListViewController.reloadData(_:)), name: NSNotification.Name(rawValue: "reloadListRoom"), object: nil)
    }
    
    @objc func onDidReceiveData(_ notification:Notification) {
        self.presenter.loadChat()
    }
    
    func setupUI(){
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UIChatListViewCell.nib, forCellReuseIdentifier: UIChatListViewCell.identifier)
        
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(reloadData(_:)), for: .valueChanged)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter.attachView(view: self,typeTabAll: true)
        self.presenter.loadChat()
        self.tabBarController?.tabBar.isHidden = false
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: NSNotification.Name(rawValue: "reloadCell"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.presenter.detachView()
         NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "reloadCell"), object: nil)
    }
    
    @objc private func reloadData(_ sender: Any) {
        self.presenter.reLoadChat()
    }
    
    @objc func profileButtonPressed() {
        let vc = ProfileVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func startChatButtonPressed() {
        let vc = NewConversationVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func chat(withRoom room: RoomModel){
        let target = UIChatViewController()
        target.room = room
        self.navigationController?.pushViewController(target, animated: true)
    }
}

extension UIChatListViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = self.rooms[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: UIChatListViewCell.identifier, for: indexPath) as! UIChatListViewCell
        cell.data = data
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let room = self.rooms[indexPath.row]
        self.chat(withRoom: room)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    private func getIndexpath(byRoom data: RoomModel) -> IndexPath? {
        // get current index
        for (i,r) in self.rooms.enumerated() {
            if r.id == data.id {
                return IndexPath(row: i, section: 0)
            }
        }
        return nil
    }
}

extension UIChatListViewController : UIChatListView {
    func didUpdate(user: MemberModel, isTyping typing: Bool, in room: RoomModel) {
        let indexPath = getIndexpath(byRoom: room)
        let isVisible = self.tableView.indexPathsForVisibleRows?.contains{$0 == indexPath}
        if let v = isVisible, let index = indexPath, v == true {
            if let cell: UIChatListViewCell = self.tableView.cellForRow(at: index) as? UIChatListViewCell{
                if typing == true{
                    if(room.type == .group){
                        cell.labelLastMessage.text = "\(user.username) isTyping..."
                    }else{
                         cell.labelLastMessage.text = "isTyping..."
                    }
                }else{
                    cell.labelLastMessage.text = room.lastComment?.message
                }
            }
        }
    }
    
    func updateRooms(data: RoomModel) {
        self.tableView.reloadData()
    }
    
    func didFinishLoadChat(rooms: [RoomModel]) {
        if rooms.count == 0 {
            self.emptyRoomView.isHidden = false
            self.tableView.isHidden = true
        }else{
            self.emptyRoomView.isHidden = true
            self.tableView.isHidden = false
            self.refreshControl.endRefreshing()
            
            // 1st time load data
            self.tableView.reloadData()
            
            //for room in rooms {
            //    DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
            //        QiscusCore.shared.subscribeTyping(roomID: room.id) { (roomTyping) in
            //            if let room = QiscusCore.database.room.find(id: roomTyping.roomID){
            //                self.didUpdate(user: roomTyping.user, isTyping: roomTyping.typing, in: room)
            //            }
            //        }
            //    })
            //}
           
        }
       
    }
    
    func startLoading(message: String) {
        //
    }
    
    func finishLoading(message: String) {
        //
    }
    
    func setEmptyData(message: String) {
        //
        self.emptyRoomView.isHidden = false
        self.tableView.isHidden = true
        self.refreshControl.endRefreshing()
    }
}
