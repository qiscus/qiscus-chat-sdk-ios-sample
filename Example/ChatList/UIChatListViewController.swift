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
    
    let defaults = UserDefaults.standard
    public var labelProfile = UILabel()
    private let presenter : UIChatListPresenter = UIChatListPresenter()
    private let refreshControl = UIRefreshControl()
    var isLoadingLoadMore : Bool = false
    var lastRoomCount: Int = 0
    var needReloadApi: Bool = false
    var rooms : [RoomModel] {
        get {
            return presenter.rooms
        }
    }
    
    // MARK: - IndicatorInfoProvider
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        if let userType = UserDefaults.standard.getUserType(){
            if userType == 2 {
                return IndicatorInfo(title: "Ongoing")
            }else{
                 return IndicatorInfo(title: "ALL")
            }
        }else{
             return IndicatorInfo(title: "ALL")
        }
    }
    
    fileprivate var activityIndicator: LoadMoreActivityIndicator!
    
    //UnStableConnection
    @IBOutlet weak var viewUnstableConnection: UIView!
    @IBOutlet weak var heightViewUnstableConnectionConst: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.presenter.loadFromServer()
        
        NotificationCenter.default.addObserver(self, selector: #selector(UIChatListViewController.reloadData(_:)), name: NSNotification.Name(rawValue: "reloadListRoom"), object: nil)
    }
    
    @objc func onDidReceiveData(_ notification:Notification) {
        self.tableView.reloadData()
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
        
        activityIndicator = LoadMoreActivityIndicator(scrollView: tableView, spacingFromLastCell: 10, spacingFromLastCellWhenLoadMoreActionStart: 60)
        
        NotificationCenter.default.addObserver(self, selector: #selector(isChangeTabs(_:)), name: NSNotification.Name(rawValue: "reloadTabs"), object: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter.setDelegate()
        if let userType = UserDefaults.standard.getUserType(){
            if userType == 2 {
                 self.presenter.attachView(view: self,typeTab: .ONGOING)
            }else{
                self.presenter.attachView(view: self,typeTab: .ALL)
            }
        }else{
             self.presenter.attachView(view: self, typeTab: .ALL)
        }
        
        self.tabBarController?.tabBar.isHidden = false
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: NSNotification.Name(rawValue: "reloadCell"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(hideUnstableConnection(_:)), name: NSNotification.Name(rawValue: "stableConnection"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showUnstableConnection(_:)), name: NSNotification.Name(rawValue: "unStableConnection"), object: nil)
        

        if needReloadApi == true{
            self.presenter.loadFromServer()
            self.needReloadApi = false
        }
        self.setupReachability()
        
        if defaults.bool(forKey: "isFromFilterVC") == false{
            defaults.setValue(0, forKey: "lastTab")
        }else{
            defaults.setValue(false, forKey: "isFromFilterVC")
        }
        
        if let row = defaults.string(forKey: "lastSelectedListRoom") {
            if !row.isEmpty{
                let indexPath = IndexPath(item: Int(row) ?? 0, section: 0)
                let isVisible = self.tableView.indexPathsForVisibleRows?.contains{$0 == indexPath}
                if let v = isVisible, v == true {
                    tableView.reloadRows(at: [indexPath], with: .none)
                    self.defaults.removeObject(forKey: "lastSelectedListRoom")
                }
               
            }
        }
    }
    
    func setupReachability(){
        let hasInternet = defaults.bool(forKey: "hasInternet")
        if hasInternet == true {
            self.stableConnection()
        }else{
            self.unStableConnection()
        }
    }
    
    @objc func showUnstableConnection(_ notification: Notification){
        self.unStableConnection()
    }
    
    func unStableConnection(){
        DispatchQueue.main.async(execute: {
            self.viewUnstableConnection.alpha = 1
            self.heightViewUnstableConnectionConst.constant = 45
        })
    }
       
    
    @objc func hideUnstableConnection(_ notification: Notification){
        self.stableConnection()
    }
    
    func stableConnection(){
        DispatchQueue.main.async(execute: {
            self.viewUnstableConnection.alpha = 0
            self.heightViewUnstableConnectionConst.constant = 0
        })
    }
    
    @objc private func isChangeTabs(_ sender: Any) {
        self.needReloadApi = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
       // self.presenter.detachView()
//         NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "reloadCell"), object: nil)
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
        cell.setupUI(data: data)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let room = self.rooms[indexPath.row]
        
        defaults.setValue(indexPath.row, forKey: "lastSelectedListRoom")
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isBouncingBottom == true && isLoadingLoadMore == false {
            activityIndicator.start {
                //loadMore
                self.isLoadingLoadMore = true
                self.presenter.loadMoreFromServer()
            }
        }
        
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
            
            self.isLoadingLoadMore = false
            self.activityIndicator.stop()
            // 1st time load data
            self.tableView.reloadData()
            
            //for room in rooms {
//                DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
//                    QiscusCore.shared.subscribeTyping(roomID: room.id) { (roomTyping) in
//                        if let room = QiscusCore.database.room.find(id: roomTyping.roomID){
//                            self.didUpdate(user: roomTyping.user, isTyping: roomTyping.typing, in: room)
//                        }
//                    }
//                })
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
        if rooms.count == 0 {
            //
            self.emptyRoomView.isHidden = false
            self.tableView.isHidden = true
        }
        self.refreshControl.endRefreshing()
        self.isLoadingLoadMore = false
        self.activityIndicator.stop()
    }
}

extension UIScrollView {
    var isBouncing: Bool {
        return isBouncingTop || isBouncingLeft || isBouncingBottom || isBouncingRight
    }
    var isBouncingTop: Bool {
        return contentOffset.y < -contentInset.top
    }
    var isBouncingLeft: Bool {
        return contentOffset.x < -contentInset.left
    }
    var isBouncingBottom: Bool {
        let contentFillsScrollEdges = contentSize.height + contentInset.top + contentInset.bottom >= bounds.height
        return contentFillsScrollEdges && contentOffset.y > contentSize.height - bounds.height + contentInset.bottom
    }
    var isBouncingRight: Bool {
        let contentFillsScrollEdges = contentSize.width + contentInset.left + contentInset.right >= bounds.width
        return contentFillsScrollEdges && contentOffset.x > contentSize.width - bounds.width + contentInset.right
    }
}
