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
import Alamofire
import SwiftyJSON

class UIChatListOngoingViewController: UIViewController, IndicatorInfoProvider {
    @IBOutlet weak var btStartChat: UIButton!
    @IBOutlet weak var emptyRoomView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    
    public var labelProfile = UILabel()
    var isLoadingLoadMore : Bool = false
    private let presenter : UIChatListPresenter = UIChatListPresenter()
    private let refreshControl = UIRefreshControl()
    var lastRoomCount: Int = 0
    var rooms : [RoomModel] {
        get {
            return presenter.rooms
        }
    }
    
    var customerRooms = [CustomerRoom]()
    
    // MARK: - IndicatorInfoProvider
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        if let userType = UserDefaults.standard.getUserType(){
            if userType == 2 {
                return IndicatorInfo(title: "RESOLVED")
            }else{
                return IndicatorInfo(title: "ONGOING")
            }
        }else{
            return IndicatorInfo(title: "ONGOING")
        }
    }
    
    fileprivate var activityIndicator: LoadMoreActivityIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        //self.presenter.loadFromServer()
    }
    
    @objc func onDidReceiveData(_ notification:Notification) {
        //self.presenter.loadChat()
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
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let userType = UserDefaults.standard.getUserType(){
            if userType == 2 {
                self.presenter.attachView(view: self,typeTab: .RESOLVED)
            }else{
                self.presenter.attachView(view: self,typeTab: .ONGOING)
            }
        }else{
            self.presenter.attachView(view: self, typeTab: .ONGOING)
        }
        //self.presenter.loadChat()
        self.getList()
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: NSNotification.Name(rawValue: "reloadCell"), object: nil)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.presenter.detachView()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "reloadCell"), object: nil)

    }
    
    @objc private func reloadData(_ sender: Any) {
       // self.presenter.reLoadChat()
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
    
    func getList(roleAdmin : Bool = true){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        let header = ["Authorization": token] as [String : String]
        let param = ["status": "resolved",
                     "limit": "15",
                    ] as [String : String]
        
        Alamofire.request("https://multichannel.qiscus.com/api/v2/customer_rooms", method: .post, parameters: param, headers: header as! HTTPHeaders).responseJSON { (response) in
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //error
                    if self.customerRooms.count == 0 {
                        self.emptyRoomView.isHidden = false
                        self.tableView.isHidden = true
                    }else{
                        self.emptyRoomView.isHidden = true
                        self.tableView.isHidden = false
                        
                        // 1st time load data
                        self.refreshControl.endRefreshing()
                        self.tableView.reloadData()
                    }
                    
                    self.isLoadingLoadMore = false
                    self.activityIndicator.stop()
                } else {
                    //success
                    let payload = JSON(response.result.value)
                    if let customerRooms = payload["data"]["customer_rooms"].array {
                        var results = [CustomerRoom]()
                        for room in customerRooms {
                            let data = CustomerRoom(json: room)
                            results.append(data)
                        }
                        self.customerRooms = results
                    }
                    
                    if self.customerRooms.count == 0 {
                        self.emptyRoomView.isHidden = false
                        self.tableView.isHidden = true
                    }else{
                        self.emptyRoomView.isHidden = true
                        self.tableView.isHidden = false
                        
                        // 1st time load data
                        self.refreshControl.endRefreshing()
                        self.tableView.reloadData()
                    }
                    
                    self.isLoadingLoadMore = false
                    self.activityIndicator.stop()
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
                if self.customerRooms.count == 0 {
                    self.emptyRoomView.isHidden = false
                    self.tableView.isHidden = true
                }else{
                    self.emptyRoomView.isHidden = true
                    self.tableView.isHidden = false
                    
                    // 1st time load data
                    self.refreshControl.endRefreshing()
                    self.tableView.reloadData()
                }
                
                self.isLoadingLoadMore = false
                self.activityIndicator.stop()
            } else {
                //failed
                if self.customerRooms.count == 0 {
                    self.emptyRoomView.isHidden = false
                    self.tableView.isHidden = true
                }else{
                    self.emptyRoomView.isHidden = true
                    self.tableView.isHidden = false
                    
                    // 1st time load data
                    self.refreshControl.endRefreshing()
                    self.tableView.reloadData()
                }
                
                self.isLoadingLoadMore = false
                self.activityIndicator.stop()
            }
        }
    }
    
}

extension UIChatListOngoingViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.customerRooms.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = self.customerRooms[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: UIChatListViewCell.identifier, for: indexPath) as! UIChatListViewCell
        cell.setupUICustomerRoom(data: data)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let customerRoom = self.customerRooms[indexPath.row]
        
        QiscusCore.shared.getChatRoomWithMessages(roomId: customerRoom.roomId, onSuccess: { (room, comments) in
            self.chat(withRoom: room)
        }) { (error) in
            //error
        }
        
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
                //self.presenter.loadMoreFromServer()
            }
        }
    }
}

extension UIChatListOngoingViewController : UIChatListView {
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

            // 1st time load data
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
            lastRoomCount = self.rooms.count
        }

        self.isLoadingLoadMore = false
        self.activityIndicator.stop()

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
