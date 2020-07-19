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

class UIChatListUnservedViewController: UIViewController, IndicatorInfoProvider {
    @IBOutlet weak var btStartChat: UIButton!
    @IBOutlet weak var emptyRoomView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    
    public var labelProfile = UILabel()
    var isLoadingLoadMore : Bool = false
    private let refreshControl = UIRefreshControl()
    
    var customerRooms = [CustomerRoom]()
    var metaAfter :String? = nil
    // MARK: - IndicatorInfoProvider
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
         return IndicatorInfo(title: "Unserved")
    }
    
    fileprivate var activityIndicator: LoadMoreActivityIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
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
        QiscusCore.delegate = self
        self.throttleGetList()
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
    @objc private func reloadData(_ sender: Any) {
        self.throttleGetList()
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
    
    @objc func getList(){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        let header = ["Authorization": token] as [String : String]
        var param = ["serve_status": "unserved",
                     "limit": "15",
                    ] as [String : String]
        
        if let meta = metaAfter {
            param["cursor_after"] = meta
        }
        
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
                        if results.count != 0 {
                            if self.metaAfter != nil {
                                self.customerRooms.append(contentsOf: results)
                            }else{
                                 self.customerRooms = results
                            }
                        }
                        
                    }
                    
                    if let meta = payload["meta"]["cursor_after"].string{
                        self.metaAfter = meta
                    }else{
                        self.metaAfter = nil
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

extension UIChatListUnservedViewController : UITableViewDelegate, UITableViewDataSource {
    
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
    
    private func getIndexpath(byRoom data: CustomerRoom) -> IndexPath? {
        // get current index
        for (i,r) in self.customerRooms.enumerated() {
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
                self.throttleGetList(firstPage: false)
            }
        }else if self.customerRooms.count <= 6 && isLoadingLoadMore == false{
            //loadMore
            self.isLoadingLoadMore = true
            self.throttleGetList(firstPage: false)
        }
    }
    
    func throttleGetList(firstPage : Bool = true) {
        if firstPage == true{
            self.metaAfter = nil
        }
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.getList), object: nil)
        perform(#selector(self.getList), with: nil, afterDelay: 1)
    }
}

extension UIChatListUnservedViewController : QiscusCoreDelegate {
    func onRoomMessageReceived(_ room: RoomModel, message: CommentModel) {
        // show in app notification
        print("got new comment: \(message.message)")
        self.throttleGetList()
    }
    
    func onRoomMessageDeleted(room: RoomModel, message: CommentModel) {
         
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
        
    }
    func onRoom(update room: RoomModel) {
        
    }

    func gotNew(room: RoomModel) {
        
    }

    func remove(room: RoomModel) {
        //
    }
}
