//
//  UIChatListViewController.swift
//  QiscusUI
//
//  Created by Qiscus on 30/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import UIKit
import QiscusCore

public protocol UIChatListViewDelegate {
    func uiChatList(tableView: UITableView, cellForRoom room: RoomModel, atIndexPath indexpath: IndexPath) -> BaseChatListCell?
}

open class UIChatListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private let presenter : UIChatListPresenter = UIChatListPresenter()
    private let refreshControl = UIRefreshControl()
    public var delegate: UIChatListViewDelegate? = nil
    
    public var rooms : [RoomModel] {
        get {
            return presenter.rooms
        }
    }
    public init() {
        super.init(nibName: "UIChatListViewController", bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.loadChat()
        self.tableView.delegate = self
        self.tableView.dataSource = self
//        self.tableView.estimatedRowHeight = UITableViewAutomaticDimension
        self.registerCell(nib: UIChatListViewCell.nib, forCellWithReuseIdentifier: UIChatListViewCell.identifier)
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(reloadData(_:)), for: .valueChanged)
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter.attachView(view: self)
        self.presenter.loadChat()
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.presenter.detachView()
    }
    
    @objc private func reloadData(_ sender: Any) {
        self.presenter.reLoadChat()
    }
    
    // MARK: public open method
    public func registerCell(nib: UINib?, forCellWithReuseIdentifier reuseIdentifier: String) {
        self.tableView.register(nib, forCellReuseIdentifier: reuseIdentifier)
    }
    
    public func registerCell(cellClass: AnyClass?, forCellWithReuseIdentifier reuseIdentifier: String) {
        self.tableView.register(cellClass, forCellReuseIdentifier: reuseIdentifier)
    }
    
    public func reusableCell(withIdentifier identifier: String, for indexpath: IndexPath) -> BaseChatListCell? {
        return self.tableView.dequeueReusableCell(withIdentifier: identifier, for: indexpath) as? BaseChatListCell
    }
}

extension UIChatListViewController : UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = self.rooms[indexPath.row]
        var cell = tableView.dequeueReusableCell(withIdentifier: UIChatListViewCell.identifier, for: indexPath) as! BaseChatListCell
        
        if let customCell = delegate?.uiChatList(tableView: tableView, cellForRoom: data, atIndexPath: indexPath) {
            cell = customCell
        }
        
        cell.data = data
        return cell
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatView = UIChatViewController()
        chatView.room = self.rooms[indexPath.row]
        self.navigationController?.pushViewController(chatView, animated: true)
    }
    
    open func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {

    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
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
            self.tableView.reloadRows(at: [index], with: UITableView.RowAnimation.none)
        }
    }
    
    func updateRooms(data: RoomModel) {
        self.tableView.reloadData()
        // improve only reload for new cell with room data
//        let indexPath = getIndexpath(byRoom: data)
//        let isVisible = self.tableView.indexPathsForVisibleRows?.contains{$0 == indexPath}
//        if let v = isVisible, let index = indexPath, v == true {
//            let newIndex = IndexPath(row: 0, section: 0)
//            self.tableView.reloadRows(at: [index], with: UITableViewRowAnimation.none)
//            self.tableView.moveRow(at: index, to: newIndex)
//        }
    }
    
    func didFinishLoadChat(rooms: [RoomModel]) {
        // 1st time load data
        self.refreshControl.endRefreshing()
        self.tableView.reloadData()
    }
    
    func startLoading(message: String) {
        //
    }
    
    func finishLoading(message: String) {
        //
    }
    
    func setEmptyData(message: String) {
        //
        self.refreshControl.endRefreshing()
    }
}
