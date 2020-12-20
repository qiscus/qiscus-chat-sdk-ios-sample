//
//  ChatAndCustomerInfoVC.swift
//  Example
//
//  Created by Qiscus on 02/12/20.
//  Copyright © 2020 Qiscus. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import QiscusCore

class ChatAndCustomerInfoVC: UIViewController {
    
    @IBOutlet weak var bottomTableViewCons: NSLayoutConstraint!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewNotes: UIView!
    @IBOutlet weak var bgViewNotes: UIView!
    @IBOutlet weak var tvNotes: UITextView!
    @IBOutlet weak var btSaveNotes: UIButton!
    @IBOutlet weak var btCancelNotes: UIButton!
    
    var room : RoomModel? = nil
    var agents : [AgentModel]? = nil
    var broadCastHistory = [BroadCastHistoryModel]()
    var additionalInformationCount = 0
    var broadcastHistoryCount = 0
    var channelTypeString = ""
    var lbChannelName = ""
    var userID = ""
    var customerName = ""
    var avatarURL = "https://"
    var task = "Complete"
    var notes = "No Notes"
    var roomOption = [String: Any]()
    var dataAddtionalInformation = [AdditionalInformationModel]()
    var isCreateTags = true
    var isTypeWA :Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadingIndicator.isHidden = false
        self.loadingIndicator.startAnimating()
        if let userType = UserDefaults.standard.getUserType(){
            if userType == 2 {
                //agent
                getListConfig()
            }else{
                
            }
        }
       
        //success
        QiscusCore.shared.getChatRoomWithMessages(roomId: self.room?.id ?? "", onSuccess: { (roomModel, comments) in
            self.room = roomModel
            self.setupRoomInfo()
        }) { (error) in
            self.setupRoomInfo()
        }
    }
    
    @IBAction func saveNotesAction(_ sender: Any) {
        self.viewNotes.alpha = 0
        var data = roomOption
        
        let json = JSON(roomOption)
        let is_resolved = json["is_resolved"].bool ?? false
        
        if is_resolved == false {
            data["is_resolved"] = false
            data["notes"] = self.tvNotes.text ?? ""
            //call api
            self.saveNotes(roomID: self.room?.id ?? "", roomOption: data)
        } else {
            data["is_resolved"] = true
            
            if is_resolved == true {
                if let userType = UserDefaults.standard.getUserType(){
                    if userType == 2 {
                        //agent
                        return
                    } else {
                        data["notes"] = self.tvNotes.text ?? ""
                        //call api
                        self.saveNotes(roomID: self.room?.id ?? "", roomOption: data)
                    }
                }
            }
        }
    }
    
    @IBAction func cancelNotesAction(_ sender: Any) {
        self.viewNotes.alpha = 0
    }
    
    func setupUI(){
        NotificationCenter.default.addObserver(self, selector: #selector(ChatAndCustomerInfoVC.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatAndCustomerInfoVC.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //setup navigationBar
        self.title = "Chat & Customer Info"
        let backButton = self.backButton(self, action: #selector(ChatAndCustomerInfoVC.goBack))
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.leftBarButtonItems = [backButton]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barTintColor = ColorConfiguration.defaultColorTosca
        
        //table view
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UINib(nibName: "CustomerInfoCell", bundle: nil), forCellReuseIdentifier: "CustomerInfoCellIdentifire")
        self.tableView.register(UINib(nibName: "CompleteTaskCell", bundle: nil), forCellReuseIdentifier: "CompleteTaskCellIdentifire")
        self.tableView.register(UINib(nibName: "AdditionalInformationCell", bundle: nil), forCellReuseIdentifier: "AdditionalInformationCellIdentifire")
        self.tableView.register(UINib(nibName: "NotesCell", bundle: nil), forCellReuseIdentifier: "NotesCellIdentifire")
        self.tableView.register(UINib(nibName: "TagsCustomerInfoCell", bundle: nil), forCellReuseIdentifier: "TagsCustomerInfoCellIdentifire")
        self.tableView.register(UINib(nibName: "AgentCustomerInfoCell", bundle: nil), forCellReuseIdentifier: "AgentCustomerInfoCellIdentifire")
         self.tableView.register(UINib(nibName: "BroadcastHistoryCell", bundle: nil), forCellReuseIdentifier: "BroadcastHistoryCellIdentifire")
        
        
        self.tableView.tableFooterView = UIView()
        
        //setup notes
        self.btSaveNotes.layer.cornerRadius = self.btSaveNotes.frame.height / 2
        self.btCancelNotes.layer.cornerRadius = self.btCancelNotes.frame.height / 2
        
        self.btCancelNotes.layer.borderWidth = 2
        self.btCancelNotes.layer.borderColor = ColorConfiguration.defaultColorTosca.cgColor
        
        self.bgViewNotes.layer.cornerRadius = 8
        self.tvNotes.layer.cornerRadius = 8
        self.tvNotes.layer.borderWidth = 1
        self.tvNotes.layer.borderColor = UIColor.lightGray.cgColor
        
    }
    
    // MARK: - Keyboard Methode
    @objc func keyboardWillHide(_ notification: Notification){
        let info: NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        
        let animateDuration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        self.bottomTableViewCons.constant = 0
        UIView.animate(withDuration: animateDuration, delay: 0, options: UIView.AnimationOptions(), animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification){
        let info:NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let keyboardSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let keyboardHeight: CGFloat = keyboardSize.height
        let animateDuration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        
        self.bottomTableViewCons.constant = 0 + keyboardHeight
        UIView.animate(withDuration: animateDuration, delay: 0, options: UIView.AnimationOptions(), animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
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
    
    func saveNotes(roomID: String, roomOption : [String : Any]){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        
        var param = [String : Any]()
        param["room_id"] = roomID
        param["room_options"] = roomOption
        
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v1/update_room_info", method: .post, parameters: param, encoding: JSONEncoding.default, headers: header as! HTTPHeaders).responseJSON { (response) in
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //error
                    
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.saveNotes(roomID : roomID, roomOption: roomOption)
                            } else {
                                return
                            }
                        }
                    }
                    
                } else {
                    //success
                    QiscusCore.shared.getChatRoomWithMessages(roomId: roomID, onSuccess: { (roomModel, comments) in
                        self.room = roomModel
                        self.setupRoomInfo()
                    }) { (error) in
                        
                    }
                    
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
            } else {
                //failed
            }
        }
    }
    
    func getListConfig(){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        let param = ["show_all": true
            ] as [String : Any]
        
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v2/app/configs", method: .get, parameters: param, headers: header as! HTTPHeaders).responseJSON { (response) in
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //error
                    
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.getListConfig()
                            } else {
                                return
                            }
                        }
                    }
                    
                } else {
                    //success
                    let payload = JSON(response.result.value)
                    let isCreateTagsEnabled = payload["data"]["configs"]["is_create_tags_enabled"].bool ?? false
                    self.isCreateTags = isCreateTagsEnabled
                    
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
            } else {
                //failed
            }
        }
    }
    
    
    
    func getListAgents(roomID : String){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        let param = ["room_id": roomID,
                     "is_available_in_room": true,
            ] as [String : Any]
        
        var dataRole = "admin"
        if let userType = UserDefaults.standard.getUserType(){
            if userType == 2 {
                //agent
                dataRole = "agent"
            } else if userType == 1 {
                 dataRole = "admin"
            } else {
                dataRole = "spv"
            }
        }
        
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v2/\(dataRole)/service/available_agents", method: .get, parameters: param, headers: header as! HTTPHeaders).responseJSON { (response) in
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //error
                    
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.getListAgents(roomID : roomID)
                            } else {
                                return
                            }
                        }
                    }
                    
                } else {
                    //success
                    let payload = JSON(response.result.value)
                    if let agentsData = payload["data"]["agents"].array {
                        var results = [AgentModel]()
                        for agentData in agentsData {
                            let data = AgentModel(json: agentData)
                            results.append(data)
                        }
                        self.agents = results
                        
                        self.tableView.reloadData()
                    }
                    
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
            } else {
                //failed
            }
        }
    }
    
    func getListBroadCastHistory(roomID : String){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        let param = ["page": 1,
                     "limit": 10,
            ] as [String : Any]
        //https://multichannel.qiscus.com/api/v2/customer_rooms/32299400/broadcast_history?page&limit
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v2/customer_rooms/\(roomID)/broadcast_history", method: .get, parameters: param, headers: header as! HTTPHeaders).responseJSON { (response) in
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //error
                    
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.getListBroadCastHistory(roomID: roomID)
                            } else {
                                return
                            }
                        }
                    }
                    
                } else {
                    //success
                    let payload = JSON(response.result.value)
                    if let broadCastHistory = payload["data"]["broadcast_logs"].array {
                        var results = [BroadCastHistoryModel]()
                        for dataBroadcast in broadCastHistory {
                            let data = BroadCastHistoryModel(json: dataBroadcast)
                            results.append(data)
                        }
                        self.broadCastHistory = results
                       
                    }
                    
                    let total = payload["meta"]["total"].int ?? 1
                    
                    self.broadcastHistoryCount = total
                    
//                    self.tableView.reloadData()
                    
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
            } else {
                //failed
            }
        }
    }
    
    func setupRoomInfo(){
        
        if let room = self.room{
            //always check from local db
            if let room = QiscusCore.database.room.find(id: room.id){
                self.customerName = room.name
                
                if let avatar = room.avatarUrl {
                    if avatar.absoluteString.contains("https://image.flaticon.com/icons/svg/145/145867.svg") == true{
                        self.avatarURL = "https://d1edrlpyc25xu0.cloudfront.net/ziv-nqsjtf0zdqf6kfk7s/image/upload/w_320,h_320,c_limit/r7byw7m9e4/default-wa.png"
                    }else{
                        self.avatarURL =  room.avatarUrl?.absoluteString ?? "http://"
                    }
                }else{
                    self.avatarURL = room.avatarUrl?.absoluteString ?? "http://"
                }
                
            }
            
            if !room.options!.isEmpty{
                let json = JSON.init(parseJSON: room.options!)
                let channelType = json["channel"].string ?? "qiscus"
                if channelType.lowercased() == "qiscus"{
                    self.channelTypeString = "Qiscus Widget"
                }else if channelType.lowercased() == "telegram"{
                    self.channelTypeString = "Telegram"
                }else if channelType.lowercased() == "line"{
                   self.channelTypeString = "Line"
                }else if channelType.lowercased() == "fb"{
                    self.channelTypeString = "Facebook"
                }else if channelType.lowercased() == "wa"{
                    self.channelTypeString = "WhatsApp"
                }else{
                    self.channelTypeString = "Qiscus Widget"
                }
                
                let notesData = json["notes"].string ?? ""
                self.notes = notesData
                
                self.roomOption = json.dictionaryObject ?? [String : Any]()
                
            }
            
            self.getListAgents(roomID: room.id)
            self.getListBroadCastHistory(roomID: room.id)
            self.getCustomerInfo()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                 self.tableView.isHidden = false
                 self.tableView.reloadData()
                
                 self.loadingIndicator.stopAnimating()
                 self.loadingIndicator.isHidden = true
            }
        }
    }
    
    func getCustomerInfo(){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v1/qiscus/room/\(room!.id)/user_info", method: .get, parameters: nil, headers: header as! HTTPHeaders).responseJSON { (response) in
            print("response call \(response)")
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //failed
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.getCustomerInfo()
                            } else {
                                return
                            }
                        }
                    }
                } else {
                    //success
                    let json = JSON(response.result.value)
                    print("response.result.value =\(json)")
                    var data = json["data"]["extras"].dictionary
                    var userID = json["data"]["user_id"].string ?? ""
                    var channelName = json["data"]["channel_name"].string ?? ""
                    
                    if let userType = UserDefaults.standard.getUserType(){
                        self.userID = userID
                    }
                    
                    if !channelName.isEmpty && !self.channelTypeString.isEmpty {
                        self.lbChannelName = "\(self.channelTypeString) - \(channelName)"
                    }
                    
                    if let dataUser = data {
                        let userProperties = dataUser["user_properties"]?.array
                        var count = 0
                        if let countAdditional = userProperties{
                            count = countAdditional.count
                        }
                        
                        if count != 0 {
                            var results = [AdditionalInformationModel]()
                            for additonalInformation in userProperties! {
                                let data = AdditionalInformationModel(json: additonalInformation)
                                results.append(data)
                            }
                            self.dataAddtionalInformation = results
                        }
                        
                        
                        self.additionalInformationCount = count
                    } else {
                        self.dataAddtionalInformation.removeAll()
                        self.additionalInformationCount = 0
                    }
                    
                    print("response.result.value2 =\(data)")
                    
                   
                    
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
            } else {
                //failed
            }
        }
    }
    
    func pushToAdditonalInformation(){
        let vc = AdditionalInformationVC()
        vc.roomID = self.room?.id ?? ""
        vc.dataAddtionalInformation = self.dataAddtionalInformation
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func pushToBroadcastHistory(){
        let vc = BroadcastHistoryVC()
        vc.roomID = self.room?.id ?? ""
        vc.totalBroadCastHistory = self.broadcastHistoryCount
        vc.dataBroadCastHistory = self.broadCastHistory
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func showNotes(sender: UIButton){
        self.showForNotes()
    }
    
    func showForNotes(){
        if (self.notes == "No Notes") || self.notes.isEmpty == true {
            
        }else{
            self.tvNotes.text = self.notes
        }
        
        let json = JSON(roomOption)
        let is_resolved = json["is_resolved"].bool ?? false
        
        if is_resolved == true {
            if let userType = UserDefaults.standard.getUserType(){
                if userType == 2{
                    //agent
                    self.tvNotes.isEditable = false
                    self.tvNotes.backgroundColor = UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1)
                } else {
                    self.tvNotes.isEditable = true
                }
            }else{
                self.tvNotes.isEditable = false
            }
        }
        
        self.viewNotes.alpha = 1
    }

}

extension ChatAndCustomerInfoVC: UITableViewDataSource, UITableViewDelegate {
    private func customerInfoCell(indexPath: IndexPath)-> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerInfoCellIdentifire", for: indexPath) as! CustomerInfoCell
        cell.lbName.text        = self.customerName
        cell.lbEmail.text       = self.userID
        cell.lbChannelName.text = self.lbChannelName
        cell.ivAvatarCusomer.af_setImage(withURL: URL(string: self.avatarURL)!)
        return cell
    }
    
    private func completeTaskCell(indexPath: IndexPath)-> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "CompleteTaskCellIdentifire", for: indexPath) as! CompleteTaskCell
        cell.lbTask.text = task
        return cell
    }
    
    private func additionalInformationCell(indexPath: IndexPath)-> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "AdditionalInformationCellIdentifire", for: indexPath) as! AdditionalInformationCell
        cell.lbCountAdditionalInformation.text = "\(self.additionalInformationCount)"
        return cell
    }
    
    private func noteCell(indexPath: IndexPath)-> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotesCellIdentifire", for: indexPath) as! NotesCell
        cell.lbNotes.text = self.notes
        cell.btIcon.addTarget(self, action:#selector(showNotes(sender:)), for: .touchUpInside)
        return cell
    }
    
    private func customerTagsInfoCell(indexPath: IndexPath)-> UITableViewCell{
       let cell = tableView.dequeueReusableCell(withIdentifier: "TagsCustomerInfoCellIdentifire", for: indexPath) as! TagsCustomerInfoCell
        cell.indexPath = indexPath
        cell.roomID = self.room?.id ?? ""
        cell.viewController = self
        cell.isCreateTags = self.isCreateTags
        if cell.firstLoad == false {
            cell.getListTags()
        }
        
        return cell
    }
    
    private func agentCustomerInfoCell(indexPath: IndexPath)-> UITableViewCell{
       let cell = tableView.dequeueReusableCell(withIdentifier: "AgentCustomerInfoCellIdentifire", for: indexPath) as! AgentCustomerInfoCell
        cell.viewController = self
        cell.setupData(participants: self.agents)
        
        return cell
    }
    
    private func broadcastHistoryCell(indexPath: IndexPath)-> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "BroadcastHistoryCellIdentifire", for: indexPath) as! BroadcastHistoryCell
        cell.lbCountBroadcastHistory.text = "\(self.broadcastHistoryCount)"
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isTypeWA == true {
            return 7
        } else {
            return 6
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isTypeWA == true {
            if indexPath.row == 0 {
                return customerInfoCell(indexPath: indexPath)
            } else if indexPath.row == 1 {
                return completeTaskCell(indexPath: indexPath)
            } else if indexPath.row == 2 {
                return additionalInformationCell(indexPath: indexPath)
            }  else if indexPath.row == 3 {
                return broadcastHistoryCell(indexPath: indexPath)
            } else if indexPath.row == 4 {
                return noteCell(indexPath: indexPath)
            } else if indexPath.row == 5 {
                return customerTagsInfoCell(indexPath: indexPath)
            } else if indexPath.row == 6 {
                return agentCustomerInfoCell(indexPath: indexPath)
            }
        } else {
            if indexPath.row == 0 {
                return customerInfoCell(indexPath: indexPath)
            } else if indexPath.row == 1 {
                return completeTaskCell(indexPath: indexPath)
            } else if indexPath.row == 2 {
                return additionalInformationCell(indexPath: indexPath)
            } else if indexPath.row == 3 {
                return noteCell(indexPath: indexPath)
            } else if indexPath.row == 4 {
                return customerTagsInfoCell(indexPath: indexPath)
            } else if indexPath.row == 5 {
                return agentCustomerInfoCell(indexPath: indexPath)
            }
        }
        return UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isTypeWA == true {
            if indexPath.row == 2 {
                self.tableView.deselectRow(at: indexPath, animated: true)
                self.pushToAdditonalInformation()
            } else if indexPath.row == 3 {
                self.tableView.deselectRow(at: indexPath, animated: true)
                self.pushToBroadcastHistory()
            }else if indexPath.row == 4 {
                self.showForNotes()
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
        } else {
            if indexPath.row == 2 {
                self.tableView.deselectRow(at: indexPath, animated: true)
                self.pushToAdditonalInformation()
            }else if indexPath.row == 3 {
                self.showForNotes()
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
}

