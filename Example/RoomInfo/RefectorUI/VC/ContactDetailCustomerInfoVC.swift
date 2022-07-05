//
//  ContactDetailCustomerInfoVC.swift
//  Example
//
//  Created by arief nur putranto on 06/12/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AlamofireImage
import QiscusCore

class ContactDetailCustomerInfoVC: UIViewController {
    @IBOutlet weak var ivBadgeChannel: UIImageView!
    @IBOutlet weak var ivContact: UIImageView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbChannel: UILabel!
    @IBOutlet weak var btResolved: UIButton!
    @IBOutlet weak var btOngoing: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stactView: UIStackView!
    var contactID = 0
    var channelID = 0
    var channelName = ""
    var channelType = ""
    var channelTypeString = ""
    var dataCustomerRooms = [CustomerRoom]()
    var isTabActive = 1 //1 onGoing, 2 resolved
    var loadFirstPageUnResolved = true
    var loadFirstPageResolved = true
    var cursorAfterUnresolved = ""
    var cursorAfterResolved = ""
    var stillLoad = false
    
    var room : RoomModel? = nil
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupAPIContact()
        self.setupAPIRoomsUnresolved()
    }
    
    func setupUI(){
        self.title = "Customer Details"
        let backButton = self.backButton(self, action: #selector(ContactDetailCustomerInfoVC.goBack))
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.leftBarButtonItems = [backButton]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barTintColor = ColorConfiguration.defaultColorTosca
        
        let detailButton = self.detailCustomerButton(self, action: #selector(ContactDetailCustomerInfoVC.goDetailCustomerContact))
        self.navigationItem.rightBarButtonItems = [detailButton]
        
        //tableView
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UINib(nibName: "ListRoomContactCell", bundle: nil), forCellReuseIdentifier: "ListRoomContactCellIdentifire")
        
        //
        if channelType.lowercased() == "qiscus"{
            self.ivBadgeChannel.image = UIImage(named: "ic_qiscus")
        }else if channelType.lowercased() == "telegram"{
            self.ivBadgeChannel.image = UIImage(named: "ic_telegram")
        }else if channelType.lowercased() == "line"{
            self.ivBadgeChannel.image = UIImage(named: "ic_line")
        }else if channelType.lowercased() == "fb"{
            self.ivBadgeChannel.image = UIImage(named: "ic_fb")
        }else if channelType.lowercased() == "wa"{
            self.ivBadgeChannel.image = UIImage(named: "ic_wa")
        }else if channelType.lowercased() == "twitter"{
            self.ivBadgeChannel.image = UIImage(named: "ic_custom_channel")
        }else if channelType.lowercased() == "custom"{
            self.ivBadgeChannel.image = UIImage(named: "ic_custom_channel")
        }else if channelType.lowercased() == "ig"{
            self.ivBadgeChannel.image = UIImage(named: "ic_ig")
        }else{
            self.ivBadgeChannel.image = UIImage(named: "ic_custom_channel")
        }
        
        if let room = room {
            if let option = room.options {
                if !option.isEmpty {
                    let json = JSON.init(parseJSON: option)
                    let badgeURL = json["room_badge"].string ?? ""
                    
                    if !badgeURL.isEmpty && !badgeURL.contains(".svg") && badgeURL != "<null>" && badgeURL != "null"{
                        self.ivBadgeChannel.af_setImage(withURL: URL(string:badgeURL)!)
                        self.ivBadgeChannel.layer.cornerRadius = ivBadgeChannel.layer.frame.size.height / 2
                    }
                    
                 }
            }
        }
        
        
        
        self.ivContact.image = UIImage(named: "ic_default_contact")
        self.ivContact.layer.cornerRadius = self.ivContact.frame.size.height / 2
        
        self.btOngoing.addBorderBottom(size: 1, color: ColorConfiguration.defaultColorTosca)
        self.btResolved.addBorderBottom(size: 1, color: UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1))
    }
    
    private func backButton(_ target: UIViewController, action: Selector) -> UIBarButtonItem{
        let backIcon = UIImageView()
        backIcon.contentMode = .scaleAspectFit
        
        let image = UIImage(named: "ic_back")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        backIcon.image = image
        backIcon.tintColor = UIColor.white
        
        if UIApplication.shared.userInterfaceLayoutDirection == .leftToRight {
            backIcon.frame = CGRect(x: 0,y: 11,width: 30,height: 25)
        }else{
            backIcon.frame = CGRect(x: 22,y: 11,width: 30,height: 25)
        }
        
        let backButton = UIButton(frame:CGRect(x: 0,y: 0,width: 30,height: 44))
        backButton.addSubview(backIcon)
        backButton.addTarget(target, action: action, for: UIControl.Event.touchUpInside)
        return UIBarButtonItem(customView: backButton)
    }
    
    @objc func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func detailCustomerButton(_ target: UIViewController, action: Selector) -> UIBarButtonItem{
        let backIcon = UIImageView()
        backIcon.contentMode = .scaleAspectFit
        
        let image = UIImage(named: "ic_detail_customer_contact")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        backIcon.image = image
        backIcon.tintColor = UIColor.white
        
        if UIApplication.shared.userInterfaceLayoutDirection == .leftToRight {
            backIcon.frame = CGRect(x: 0,y: 11,width: 30,height: 25)
        }else{
            backIcon.frame = CGRect(x: 22,y: 11,width: 30,height: 25)
        }
        
        let button = UIButton(frame:CGRect(x: 0,y: 0,width: 30,height: 44))
        button.addSubview(backIcon)
        button.addTarget(target, action: action, for: UIControl.Event.touchUpInside)
        return UIBarButtonItem(customView: button)
    }
    
    @objc func goDetailCustomerContact() {
        let vc = DetailCustomerInformationContactVC()
        vc.contactID = self.contactID
        if channelName.isEmpty == true {
            vc.channelName = self.channelTypeString
        }else{
            vc.channelName = self.channelName
        }
        
        vc.channelID = self.channelID
        vc.ivBadgeChannel = self.ivBadgeChannel.image ?? UIImage()
        vc.avatarName = self.ivContact.image ?? UIImage()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setupAPIContact(){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v2/contacts/\(self.contactID)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: header as! HTTPHeaders).responseJSON { (response) in
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //error
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.setupAPIContact()
                            } else {
                                return
                            }
                        }
                    }
                    
                } else {
                    //success
                    let payload = JSON(response.result.value)
                    let name = payload["data"]["contact"]["name"].string ?? ""
                    
                    self.lbName.text = name
                    if self.channelName.isEmpty == true {
                        self.lbChannel.text = self.channelTypeString
                    } else {
                        self.lbChannel.text = self.channelName
                    }
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
            } else {
                //failed
            }
        }
    }
    
    func setupAPIRoomsUnresolved(cursorAfter : String = ""){
        self.stillLoad = true
        self.cursorAfterResolved = ""
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        var url = "\(QiscusHelper.getBaseURL())/api/v2/contacts/\(self.contactID)/conversations?status=unresolved"
        if !cursorAfter.isEmpty {
            url = "\(QiscusHelper.getBaseURL())/api/v2/contacts/\(self.contactID)/conversations?status=unresolved&cursor_after=\(cursorAfter)"
        }
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: header as! HTTPHeaders).responseJSON { (response) in
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //error
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.setupAPIRoomsUnresolved()
                            } else {
                                return
                            }
                        }
                    }
                    self.stillLoad = false
                } else {
                    //success
                    let payload = JSON(response.result.value)
                    let customerRooms = payload["data"]["customer_rooms"].array
                    let loadMore = payload["meta"]["cursor_after"].string ?? ""
                    
                    if self.loadFirstPageUnResolved == true {
                        self.loadFirstPageUnResolved = false
                        self.dataCustomerRooms.removeAll()
                    }
                    
                    self.cursorAfterUnresolved = loadMore
                    
                    if customerRooms?.count != 0 {
                        for data in customerRooms! {
                            var room = CustomerRoom(json: data)
                            self.dataCustomerRooms.append(room)
                        }
                        
                        self.tableView.reloadData()
                    }else{
                        self.tableView.reloadData()
                    }
                    
                    self.stillLoad = false
                    
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
                self.stillLoad = false
            } else {
                //failed
                self.stillLoad = false
            }
        }
    }
    
    func setupAPIRoomsResolved(cursorAfter : String = ""){
        self.stillLoad = true
        self.cursorAfterUnresolved = ""
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        
        var url = "\(QiscusHelper.getBaseURL())/api/v2/contacts/\(self.contactID)/conversations?status=resolved"
        if !cursorAfter.isEmpty {
            url = "\(QiscusHelper.getBaseURL())/api/v2/contacts/\(self.contactID)/conversations?status=resolved&cursor_after=\(cursorAfter)"
        }
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: header as! HTTPHeaders).responseJSON { (response) in
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //error
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.setupAPIRoomsResolved()
                            } else {
                                return
                            }
                        }
                    }
                    
                    self.stillLoad = false
                    
                } else {
                    //success
                    let payload = JSON(response.result.value)
                    let customerRooms = payload["data"]["customer_rooms"].array
                    let loadMore = payload["meta"]["cursor_after"].string ?? ""
                    if self.loadFirstPageResolved == true {
                        self.loadFirstPageResolved = false
                        self.dataCustomerRooms.removeAll()
                    }
                    
                    self.cursorAfterResolved = loadMore
                    
                    if customerRooms?.count != 0 {
                        for data in customerRooms! {
                            var room = CustomerRoom(json: data)
                            self.dataCustomerRooms.append(room)
                        }
                        
                        self.tableView.reloadData()
                    }else{
                        self.tableView.reloadData()
                    }
                    
                    self.stillLoad = false
                    
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
                self.stillLoad = false
            } else {
                //failed
                self.stillLoad = false
            }
        }
    }
    
    @IBAction func onGoingTab(_ sender: Any) {
        self.btOngoing.addBorderBottom(size: 1, color: ColorConfiguration.defaultColorTosca)
        self.btResolved.addBorderBottom(size: 1, color: UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1))
        
        self.isTabActive = 1
        self.loadFirstPageUnResolved = true
        self.setupAPIRoomsUnresolved()
    }
    
    @IBAction func resolvedTab(_ sender: Any) {
        
        self.btResolved.addBorderBottom(size: 1, color: ColorConfiguration.defaultColorTosca)
        self.btOngoing.addBorderBottom(size: 1, color: UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1))
        
        self.isTabActive = 2
        self.loadFirstPageResolved = true
        self.setupAPIRoomsResolved()
    }
    
}

extension ContactDetailCustomerInfoVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataCustomerRooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListRoomContactCellIdentifire", for: indexPath) as! ListRoomContactCell
        let data = self.dataCustomerRooms[indexPath.row]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"
        dateFormatter.timeZone = .current
        if let date = dateFormatter.date(from: data.lastCustomerTimestamp) {
            let dateFormatter2 = DateFormatter()
            dateFormatter2.dateFormat = "dd/MM/yy"
            let dateString = dateFormatter2.string(from: date)
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            let timeString = timeFormatter.string(from: date)
            
            if Calendar.current.isDateInToday(date){
                cell.lbDate.text = "Today"
            }else if Calendar.current.isDateInYesterday(date) {
                cell.lbDate.text = "Yesterday"
            }else{
                cell.lbDate.text = "\(dateString)"
            }
            
            cell.lbTime.text = "\(timeString)"
        }else{
            cell.lbDate.text = ""
            cell.lbTime.text = ""
        }
        
        cell.lbLastMessage.text = data.lastComment
        cell.ivRoom.layer.cornerRadius = cell.ivRoom.layer.frame.height / 2
        cell.ivRoom.image = self.ivBadgeChannel.image
      
        if channelName.isEmpty {
            cell.lbRoomName.text = self.channelTypeString
        }else{
            cell.lbRoomName.text = self.channelName
        }
        
        if indexPath.row == self.dataCustomerRooms.count - 1 { // last cell
            if self.isTabActive == 1 {
                if !self.cursorAfterUnresolved.isEmpty{
                    //loadMore
                    if self.stillLoad == false{
                        self.setupAPIRoomsUnresolved(cursorAfter: self.cursorAfterUnresolved)
                    }
                }
            }else{
                if !self.cursorAfterResolved.isEmpty{
                    //loadMore
                    if self.stillLoad == false{
                        self.setupAPIRoomsResolved(cursorAfter: self.cursorAfterResolved)
                    }
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = dataCustomerRooms[indexPath.row]
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = DetailConversationChatRoomVC()
        if let image = self.ivBadgeChannel.image {
            vc.avatarChannel = image
        }
        if channelName.isEmpty {
            vc.channelName = self.channelTypeString
        }else{
            vc.channelName = self.channelName
        }
        
        vc.customerRoom = data
        vc.contactID = self.contactID
        if isTabActive == 1 {
            vc.titleText = "Ongoing Conversations"
            vc.isOngoing = true
        }else{
            vc.titleText = "Resolved Conversations"
            vc.isOngoing = false
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
