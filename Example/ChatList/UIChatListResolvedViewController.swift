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

class UIChatListResolvedViewController: UIViewController, IndicatorInfoProvider {
    @IBOutlet weak var btStartChat: UIButton!
    @IBOutlet weak var emptyRoomView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    public var labelProfile = UILabel()
    var isLoadingLoadMore : Bool = false
    private let refreshControl = UIRefreshControl()
    
    var customerRooms = [CustomerRoom]()
    var metaAfter :String? = nil
    var firstPage : Bool = false
    // MARK: - IndicatorInfoProvider
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
         return IndicatorInfo(title: "Resolved")
    }
    
    fileprivate var activityIndicator: LoadMoreActivityIndicator!
    
    //UnStableConnection
    @IBOutlet weak var viewUnstableConnection: UIView!
    @IBOutlet weak var heightViewUnstableConnectionConst: NSLayoutConstraint!
    var defaults = UserDefaults.standard
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(isChangeTabs(_:)), name: NSNotification.Name(rawValue: "reloadTabs"), object: nil)
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(hideUnstableConnection(_:)), name: NSNotification.Name(rawValue: "stableConnection"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showUnstableConnection(_:)), name: NSNotification.Name(rawValue: "unStableConnection"), object: nil)
        
        self.setupReachability()
        
        if let userType = UserDefaults.standard.getUserType(){
            if userType == 1  {
                //admin
                defaults.setValue(3, forKey: "lastTab")
            }else if userType == 2{
                //agent
                defaults.setValue(1, forKey: "lastTab")
            }else{
                //spv
                defaults.setValue(3, forKey: "lastTab")
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

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
    
    @objc private func reloadData(_ sender: Any) {
        self.throttleGetList()
    }
    
    @objc private func isChangeTabs(_ sender: Any) {
        self.metaAfter = nil
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
    
    func filterRoom(data: [CustomerRoom]) -> [CustomerRoom] {
        var source = data
        
        source.sort { (room1, room2) -> Bool in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"
            dateFormatter.timeZone = .current
            guard let date = dateFormatter.date(from: room1.lastCommentTimestamp) else {
                return false
            }
            
            let dateFormatter2 = DateFormatter()
            dateFormatter2.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"
            dateFormatter2.timeZone = .current
            guard let date2 = dateFormatter2.date(from: room2.lastCommentTimestamp) else {
                return false
            }
            
            let timeInterval = date.timeIntervalSince1970
            let timeInterval2 = date2.timeIntervalSince1970

            // convert to Integer
            let timeInterInt = Int(timeInterval)
            let timeInterInt2 = Int(timeInterval2)

            return timeInterInt > timeInterInt2
        }
        
        return source
    }
    
    func convertToDictionary(text: String) -> [[String: Any]]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    @objc func getList(){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        var param = ["status": "resolved",
                     "limit": "50",
                    ] as [String : Any]
        
        if let meta = metaAfter {
            if self.firstPage == false {
                param["cursor_after"] = meta
            }
        }
        
        if let hasFilterAgent = defaults.array(forKey: "filterAgent"){
            param["user_ids"] = hasFilterAgent
        }
        
        if let hasFilterTag = defaults.string(forKey: "filterTag"){
            if let dict = convertToDictionary(text: hasFilterTag){
                var array = [Int]()
                if dict.count != 0 {
                    for i in dict{
                        let json = JSON(i)
                        array.append(json["id"].int ?? 0)
                    }
                    param["tag_ids"] = array
                }
            }
        }
        
        if let hasFilterChannel = defaults.string(forKey: "filter"){
            let dict = convertToDictionary(text: hasFilterChannel)
            if dict?.count != 0 {
                param["channels"] = dict
                var countNotWA = 0
                var countWA = 0
                if let filterSelectedTypeWA = defaults.string(forKey: "filterSelectedTypeWA"){
                    if !filterSelectedTypeWA.isEmpty{
                        if let dict = dict {
                            
                            var arrayALL = [[String: Any]]()
                            var arrayWA = [[String: Any]]()
                            var arrayNotWA = [[String: Any]]()
                            for data in dict{
                                let jsonSource = JSON(data)
                                let source = jsonSource["source"].string ?? "empty"
                                if source.lowercased() == "wa".lowercased(){
                                    arrayWA.append(data)
                                    countWA += 1
                                }else{
                                    countNotWA += 1
                                    arrayNotWA.append(data)
                                }
                            }
                            
                            if filterSelectedTypeWA.lowercased() == "almost_expired".lowercased(){
                                if countWA >= 1 && countNotWA == 0 {
                                    self.emptyRoomView.isHidden = false
                                    self.customerRooms.removeAll()
                                    self.tableView.reloadData()
                                    self.tableView.isHidden = true
                                    self.isLoadingLoadMore = false
                                    self.activityIndicator.stop()
                                    return
                                }else{
                                    param["channels"] = arrayNotWA
                                }
                            }else if filterSelectedTypeWA.lowercased() == "expired".lowercased(){
                                if countWA >= 1 && countNotWA == 0 {
                                    self.emptyRoomView.isHidden = false
                                    self.customerRooms.removeAll()
                                    self.tableView.reloadData()
                                    self.tableView.isHidden = true
                                    self.isLoadingLoadMore = false
                                    self.activityIndicator.stop()
                                    return
                                }else{
                                    param["channels"] = arrayNotWA
                                }
                            }
                            
                        }
                    }
                }
            }else{
                self.emptyRoomView.isHidden = false
                self.customerRooms.removeAll()
                self.tableView.reloadData()
                self.tableView.isHidden = true
                self.isLoadingLoadMore = false
                self.activityIndicator.stop()
                return
            }
           
        }
        
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v2/customer_rooms", method: .post, parameters: param, encoding: JSONEncoding.default, headers: header as! HTTPHeaders).responseJSON { (response) in
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
                    
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.getList()
                            } else {
                                return
                            }
                        }
                    }
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
                                if self.firstPage == true {
                                    //merge data
                                    for i in results {
                                        let checkRoom = self.customerRooms.filter{ $0.id == i.id }
                                        
                                        if checkRoom.count == 0 {
                                            // data not found from last array and next step to append data
                                            self.customerRooms.append(i)
                                        }else{
                                            self.customerRooms = self.customerRooms.map { (room) -> CustomerRoom in
                                                var room = room
                                                if room.id == i.id {
                                                    room = i                                                }
                                                return room
                                            }
                                        }
                                    }
                                } else {
                                    self.customerRooms.append(contentsOf: results)
                                }
                            }else{
                                 self.customerRooms = results
                            }
                            
                            self.customerRooms = self.filterRoom(data:  self.customerRooms)
                        }
                    }
                    
                    if let meta = payload["meta"]["cursor_after"].string{
                        self.metaAfter = meta
                    }
                    
                    if let meta = payload["meta"]["cursor_after"].int{
                        self.metaAfter = "\(meta)"
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

extension UIChatListResolvedViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.customerRooms.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.customerRooms[safe: indexPath.row] != nil{
            let data = self.customerRooms[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: UIChatListViewCell.identifier, for: indexPath) as! UIChatListViewCell
            cell.setupUICustomerRoom(data: data)
            return cell
        }else{
            return UITableViewCell()
        }
       
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.customerRooms[safe: indexPath.row] != nil{
            let customerRoom = self.customerRooms[indexPath.row]
            
            QiscusCore.shared.getChatRoomWithMessages(roomId: customerRoom.roomId, onSuccess: { (room, comments) in
                self.chat(withRoom: room)
            }) { (error) in
                //error
            }
        }else{
            self.tableView.reloadData()
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
        self.firstPage = firstPage
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.getList), object: nil)
        perform(#selector(self.getList), with: nil, afterDelay: 1)
    }
}

extension UIChatListResolvedViewController : QiscusCoreDelegate {
    func onRoomMessageUpdated(_ room: RoomModel, message: CommentModel) {
        
    }
    
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
