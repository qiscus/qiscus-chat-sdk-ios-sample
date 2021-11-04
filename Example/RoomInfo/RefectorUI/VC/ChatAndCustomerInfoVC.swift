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

class ChatAndCustomerInfoVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
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
    var tagsData : [TagsModel]? = nil //for submit ticket
    var submitTicketModel : [SubmitTicketModel]? = nil //for submit ticket
    var broadCastHistory = [BroadCastHistoryModel]()
    var dataHSMTemplate = [HSMTemplateModel]()
    var additionalInformationCount = 0
    var broadcastHistoryCount = 0
    var channelTypeString = ""
    var channelType = "" //for submit ticket
    var channelName = "" //for submit ticket
    var channelID = 0 //for submit ticket
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
    var isWAExpired : Bool = false //expired after 24 hours
    var isWAWillExpired : Bool = false //will expire after 16 hours
    var lastCommentCustomerDate : Date? = nil
    
   
    
    //template 24 hsm
    @IBOutlet weak var viewBGTemplateHSM: UIView!
    @IBOutlet weak var viewTemplateHSM: UIView!
    @IBOutlet weak var textViewContentTemplateHSM: UITextView!
    @IBOutlet weak var tfSelectTemplateLanguage: UITextField!
    @IBOutlet weak var btSendTemplateHSM: UIButton!
    @IBOutlet weak var btCancelTemplateHSM: UIButton!
    var hsmQuota = 0
    var enableHSM = false
    var dataLanguage = [String]()
    var isWaBlocked : Bool = false
    
    //alert failed send hsm 24
    @IBOutlet weak var bgViewFailedSendHSM: UIView!
    @IBOutlet weak var alertViewFailedSendHSM: UIView!
    @IBOutlet weak var btOKFailedSendHSM: UIButton!
    
    @IBOutlet weak var viewLoading: UIView!
    
    //UnStableConnection
    @IBOutlet weak var viewUnstableConnection: UIView!
    @IBOutlet weak var heightViewUnstableConnectionConst: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.loadMoreIFtypeWa()
    }
    
    func loadMoreIFtypeWa(){
       
        if let room = self.room {
            if let comments = QiscusCore.database.comment.find(roomId: room.id){
                if !room.options!.isEmpty{
                    let json = JSON.init(parseJSON: room.options!)
                    let channelType = json["channel"].string ?? "qiscus"
                   
                    if channelType.lowercased() == "wa"{
                        QiscusCore.shared.loadMore(roomID: room.id, lastCommentID: comments.last!.id, limit: 100) { (comments) in
                            if comments.count == 0 {
                                return
                            }
                        } onError: { (error) in
                            
                        }
                    }
                }
            }
        }
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewLoading.isHidden = false
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
            self.getCustomerRoom()
            self.setupRoomInfo()
        }) { (error) in
            self.getCustomerRoom()
            self.setupRoomInfo()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(hideUnstableConnection(_:)), name: NSNotification.Name(rawValue: "stableConnection"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showUnstableConnection(_:)), name: NSNotification.Name(rawValue: "unStableConnection"), object: nil)
        
        self.setupReachability()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isTypeWA == true && isWAWillExpired == true {
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name("invalidateCounter"), object: nil)
        }
    }
    
    func setupReachability(){
        let defaults = UserDefaults.standard
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
        self.viewUnstableConnection.alpha = 1
        self.heightViewUnstableConnectionConst.constant = 45
    }
    
    @objc func hideUnstableConnection(_ notification: Notification){
        self.stableConnection()
    }
    
    func stableConnection(){
        self.viewUnstableConnection.alpha = 0
        self.heightViewUnstableConnectionConst.constant = 0
    }
    
    @objc func buttonSendWaTemplate(sender: UIButton!) {
        self.viewBGTemplateHSM.alpha = 1
    }
    
    @objc func buttonWAInfoAction(sender: UIButton!) {
        let popupVC = BottomAlertInfoHSM()
        popupVC.enableHSM = self.enableHSM
        popupVC.isExpired = self.isWAExpired
        popupVC.width = self.view.frame.size.width
        popupVC.topCornerRadius = 15
        popupVC.presentDuration = 0.30
        popupVC.dismissDuration = 0.30
        popupVC.shouldDismissInteractivelty = true
        self.present(popupVC, animated: true, completion: nil)
    }
    
    @objc func buttonWAInfoWillExpireAction(sender: UIButton!) {
        let popupVC = BottomAlertInfoHSM()
        popupVC.isExpired = self.isWAExpired
        popupVC.width = self.view.frame.size.width
        popupVC.topCornerRadius = 15
        popupVC.presentDuration = 0.30
        popupVC.dismissDuration = 0.30
        popupVC.shouldDismissInteractivelty = true
        self.present(popupVC, animated: true, completion: nil)
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
        self.tableView.register(UINib(nibName: "HSMCell", bundle: nil), forCellReuseIdentifier: "HSMCellIdentifire")
        self.tableView.register(UINib(nibName: "HSMWillExpireSoonCell", bundle: nil), forCellReuseIdentifier: "HSMWillExpireSoonCellIdentifire")
        self.tableView.register(UINib(nibName: "WABlockedCell", bundle: nil), forCellReuseIdentifier: "WABlockedCellIdentifire")
        
        
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
        
        
        //setup template HSM
        self.btSendTemplateHSM.layer.cornerRadius = self.btSendTemplateHSM.frame.height / 2
        self.btCancelTemplateHSM.layer.cornerRadius = self.btCancelTemplateHSM.frame.height / 2
        
        self.btCancelTemplateHSM.layer.borderWidth = 2
        self.btCancelTemplateHSM.layer.borderColor = ColorConfiguration.defaultColorTosca.cgColor
        
        self.viewTemplateHSM.layer.cornerRadius = 8
        
        let pickerView = UIPickerView()
        pickerView.delegate = self
        
        tfSelectTemplateLanguage.inputView = pickerView
        
        //setup alert send hsm
        self.btOKFailedSendHSM.layer.cornerRadius = self.btOKFailedSendHSM.frame.height / 2
        self.alertViewFailedSendHSM.layer.cornerRadius = 8
    }
    
    //alert ok success block unbloc contact
    @IBAction func btOKFailedSendHSM(_ sender: Any) {
        self.bgViewFailedSendHSM.isHidden = true
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
                        self.viewLoading.isHidden = false
                        self.loadingIndicator.isHidden = false
                        self.loadingIndicator.startAnimating()
                        self.getCustomerRoom()
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
    
    func getTemplateHSM(channelID: Int){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        let param = ["channel_id": channelID,
                     "approved" : true
        ] as [String : Any]
        
        
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v2/admin/hsm_24", method: .get, parameters: param, headers: header as! HTTPHeaders).responseJSON { (response) in
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //error
                    
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.getTemplateHSM(channelID: channelID)
                            } else {
                                return
                            }
                        }
                    }
                    
                } else {
                    //success
                    let payload = JSON(response.result.value)
                    let arrayTemplate = payload["data"]["hsm_template"]["hsm_details"].array
                    let enableSendHSM = payload["data"]["enabled"].bool ?? false
                    let hsmQuotaData = payload["data"]["hsm_quota"].int ?? 0
                    
                    self.hsmQuota = hsmQuotaData
                    self.enableHSM = enableSendHSM
                    
                    if arrayTemplate?.count != 0 {
                        var results = [HSMTemplateModel]()
                        for dataTemplate in arrayTemplate! {
                            let data = HSMTemplateModel(json: dataTemplate)
                            results.append(data)
                        }
                        self.dataHSMTemplate = results
                        self.dataLanguage.removeAll()
                        for i in results {
                            
                            if !i.countryName.isEmpty{
                                self.dataLanguage.append(i.countryName)
                            }
                        }
                        
                        if self.dataLanguage.count != 0 {
                            self.tfSelectTemplateLanguage.text = self.dataLanguage.first
                            
                            let filterData = self.dataHSMTemplate.filter{ $0.countryName.lowercased() == self.dataLanguage.first!.lowercased() }
                            
                            if let data = filterData.first{
                                self.textViewContentTemplateHSM.text = data.content
                            }else{
                                self.textViewContentTemplateHSM.text = ""
                            }
                            
                        }
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
    
    func getListSubmitTicket(){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v2/app/config/ticketing", method: .get, parameters: nil, headers: header as! HTTPHeaders).responseJSON { (response) in
            if response.result.value != nil {
                print("check status code \(response.response?.statusCode)")
                print("check error \(response.result.error)")
                if (response.response?.statusCode)! >= 300 {
                    //error
                    
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.getListSubmitTicket()
                            } else {
                                return
                            }
                        }
                    }
                    
                } else {
                    //success
                    let payload = JSON(response.result.value)
                    if let dataModels = payload["data"]["configs"].array {
                        var results = [SubmitTicketModel]()
                        for data in dataModels {
                            let model = SubmitTicketModel(json: data)
                            if model.enabled == true {
                                results.append(model)
                            }
                            
                        }
                        self.submitTicketModel = results
                        
                        
                    }
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
            } else {
                //failed
            }
        }
    }
    
    func getListTags(roomID : String){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v2/room_tags/\(roomID)", method: .get, parameters: nil, headers: header as! HTTPHeaders).responseJSON { (response) in
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //error
                    
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.getListTags(roomID : roomID)
                            } else {
                                return
                            }
                        }
                    }
                    
                } else {
                    //success
                    let payload = JSON(response.result.value)
                    if let tags = payload["data"].array {
                        var results = [TagsModel]()
                        for tag in tags {
                            let data = TagsModel(json: tag)
                            results.append(data)
                        }
                        self.tagsData = results
                    }
                   
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
                    if avatar.absoluteString.contains("https://image.flaticon.com/icons/svg/145/145867.svg") == true || avatar.absoluteString.contains("https://latest-multichannel.qiscus.com/img/default_avatar.svg"){
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
                self.channelType = channelType
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
                }else if channelType.lowercased() == "twitter" {
                    self.channelTypeString = "Custom Channel"
                }else if channelType.lowercased() == "custom" {
                    self.channelTypeString = "Custom Channel"
                }else{
                    self.channelTypeString = "Custom Channel"
                }
                
                let notesData = json["notes"].string ?? ""
                self.notes = notesData
                
                self.roomOption = json.dictionaryObject ?? [String : Any]()
                
            }
            
            self.getListTags(roomID: room.id)
            self.getListAgents(roomID: room.id)
            self.getListBroadCastHistory(roomID: room.id)
            self.getCustomerInfo()
            if let statusFeatureSubmitTicket = UserDefaults.standard.getStatusFeatureSubmitTicket() {
                if  statusFeatureSubmitTicket == 1{
                    self.getListSubmitTicket()
                }
            }
           
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                 self.tableView.isHidden = false
                 self.tableView.reloadData()
                 self.viewLoading.isHidden = true
                 self.loadingIndicator.stopAnimating()
                 self.loadingIndicator.isHidden = true
            }
        }
    }
    
    func getCustomerRoom(){
        if self.isTypeWA {
            if var room = QiscusCore.database.room.find(id: self.room!.id){
                if var option = room.options{
                    if !option.isEmpty{
                        var json = JSON.init(parseJSON: option)
                        let lastCustommerTimestamp = json["last_customer_message_timestamp"].string ?? ""
                        
                        if lastCustommerTimestamp.isEmpty == true {
                            guard let token = UserDefaults.standard.getAuthenticationToken() else {
                                return
                            }
                            
                            let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
                            
                            Alamofire.request("\(QiscusHelper.getBaseURL())/api/v2/customer_rooms/\(room.id)", method: .get, parameters: nil, headers: header as! HTTPHeaders).responseJSON { (response) in
                                if response.result.value != nil {
                                    if (response.response?.statusCode)! >= 300 {
                                        //error
                                        
                                        if response.response?.statusCode == 401 {
                                            RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                                                if success == true {
                                                    self.getCustomerRoom()
                                                } else {
                                                   return
                                                }
                                            }
                                        }
                                    } else {
                                        //success
                                        let payload = JSON(response.result.value)
                            
                                        let lastCustomerTimestamp  = payload["data"]["customer_room"]["last_customer_timestamp"].string ??
                                            ""
                                        
                                        var json = JSON.init(parseJSON: option)
                                        json["last_customer_message_timestamp"] = JSON(lastCustomerTimestamp)
                                        
                                        if let rawData = json.rawString() {
                                            let room = room
                                            room.options = rawData
                                            QiscusCore.database.room.save([room])
                                        }
                                        
                                        let date = self.getDate(timestamp: lastCustomerTimestamp)
                                        let diff = date.differentTime()

                                        if diff >= 16 && diff <= 23 {
                                            self.isWAWillExpired = true
                                        } else if diff >= 24 {
                                            self.isWAExpired = true
                                        } else {
                                            self.isWAWillExpired = false
                                            self.isWAExpired = false
                                        }
                                        
                                        self.lastCommentCustomerDate = date
                                    }
                                } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                                    //failed
                                    self.isWAWillExpired = false
                                    self.isWAExpired = false
                                } else {
                                    //failed
                                    self.isWAWillExpired = false
                                    self.isWAExpired = false
                                }
                            }
                        }else{
                            
                        }
                    }
                }
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
                    var channelID = json["data"]["channel_id"].int ?? 0
                    let enableSendHSM = json["data"]["enabled"].bool ?? false
                    var isWaBlocked = json["data"]["is_blocked"].bool ?? false
                    self.isWaBlocked = isWaBlocked
                    self.channelName = channelName
                    self.channelID = channelID
                    if let userType = UserDefaults.standard.getUserType(){
                        self.userID = userID
                        if channelID != 0 {
                            self.getTemplateHSM(channelID: channelID)
                        }
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
    
    func getDate(timestamp : String) -> Date {
        //let timezone = TimeZone.current.identifier
        let formatter = DateFormatter()
        formatter.dateFormat    = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.timeZone = .current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let date = formatter.date(from: timestamp)
        return date ?? Date()
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
    
    //template 24 HSM
    
    // Sets number of columns in picker view
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Sets the number of rows in the picker view
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return self.dataLanguage.count
    }
    
    // This function sets the text of the picker view to the content of the "salutations" array
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.dataLanguage[row]
    }
    
    // When user selects an option, this function will set the text of the text field to reflect
    // the selected option.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        tfSelectTemplateLanguage.text = dataLanguage[row]
        
        let filterData = self.dataHSMTemplate.filter{ $0.countryName.lowercased() == tfSelectTemplateLanguage.text?.lowercased() }
        
        if let data = filterData.first{
            self.textViewContentTemplateHSM.text = data.content
        }else{
            self.textViewContentTemplateHSM.text = ""
        }
    }
    
    @IBAction func sendTemplateHSM(_ sender: Any) {
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        let filterData = self.dataHSMTemplate.filter{ $0.countryName.lowercased() == tfSelectTemplateLanguage.text?.lowercased() }
        
        var templateID = 0
        if let data = filterData.first{
            templateID = data.id
        }else{
            return
        }
        
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        
        var param: [String: Any] = [
            "room_id": self.room?.id,
            "template_detail_id" : templateID
        ]
        
        var dataRole = "admin"
        if let userType = UserDefaults.standard.getUserType(){
            if userType == 2 {
                //agent
                dataRole = "agent"
            } else if userType == 1 {
                 dataRole = "admin"
            } else {
                dataRole = "admin"
            }
        }
        
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v2/\(dataRole)/broadcast/send_hsm24", method: .post, parameters: param, encoding: JSONEncoding.default, headers: header as! HTTPHeaders).responseJSON { (response) in
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //error
                    
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.sendTemplateHSM(sender)
                            } else {
                                return
                            }
                        }
                    }else if response.response?.statusCode == 400 {
                        self.viewBGTemplateHSM.alpha = 0
                        //show error send hsm, maybe wa is blocked
                        self.bgViewFailedSendHSM.isHidden = false
                    }
                    
                } else {
                    //success
                    self.navigationController?.popViewController(animated: true)
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
                self.viewBGTemplateHSM.alpha = 0
            } else {
                //failed
                self.viewBGTemplateHSM.alpha = 0
            }
        }
    }
    
    @IBAction func cancelTemplateHSM(_ sender: Any) {
        self.viewBGTemplateHSM.alpha = 0
    }
}

extension ChatAndCustomerInfoVC: UITableViewDataSource, UITableViewDelegate {
    private func waBlockedCell(indexPath: IndexPath)-> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "WABlockedCellIdentifire", for: indexPath) as! WABlockedCell
        return cell
    }
    
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
        cell.viewController = self
        cell.setupData(submitTicketModel: self.submitTicketModel)
        if let room = self.room{
            cell.roomID = Int(room.id)!
        }
        
        //cell.tags = self.tagsData
        cell.notes = self.notes
        cell.channelName = self.channelName
        cell.channelID = self.channelID
        //cell.channelType = self.channelType
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
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
    
    private func HSMCell(indexPath: IndexPath)-> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "HSMCellIdentifire", for: indexPath) as! HSMCell
        cell.btShowAlertInfo.addTarget(self, action: #selector(buttonWAInfoAction), for: .touchUpInside)
        cell.btSendMessageTemplate.addTarget(self, action: #selector(buttonSendWaTemplate), for: .touchUpInside)
        
        if self.enableHSM == false || self.hsmQuota == 0 {
            cell.btSendMessageTemplateHeightCons.constant = 0
            cell.topButtonSendMessageTemplateCons.constant = 0
            cell.btSendMessageTemplate.isHidden = true
        }else{
            cell.btSendMessageTemplateHeightCons.constant = 40
            cell.topButtonSendMessageTemplateCons.constant = 20
            cell.btSendMessageTemplate.isHidden = false
        }
        
        return cell
    }
    
    private func HSMWillExpireSoonCell(indexPath: IndexPath)-> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "HSMWillExpireSoonCellIdentifire", for: indexPath) as! HSMWillExpireSoonCell
        cell.setupData(lastCommentCustomerDate: self.lastCommentCustomerDate)
        cell.btAlertInfoExpireSoon.addTarget(self, action: #selector(buttonWAInfoWillExpireAction), for: .touchUpInside)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isTypeWA == true {
            if isWAExpired == true {
                if isWaBlocked == true {
                    return 9
                } else {
                    return 8
                }
            } else if isWAWillExpired == true {
                if isWaBlocked == true {
                    return 9
                } else {
                    return 8
                }
            } else {
                if isWaBlocked == true {
                    return 8
                }else{
                    return 7
                }
            }
        } else {
            return 6
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isTypeWA == true {
            if isWAExpired == true {
                if isWaBlocked == true {
                    if indexPath.row == 0 {
                        return customerInfoCell(indexPath: indexPath)
                    } else if indexPath.row == 1 {
                        return waBlockedCell(indexPath: indexPath)
                    } else if indexPath.row == 2 {
                        return HSMCell(indexPath: indexPath)
                    } else if indexPath.row == 3 {
                        return completeTaskCell(indexPath: indexPath)
                    } else if indexPath.row == 4 {
                        return additionalInformationCell(indexPath: indexPath)
                    }  else if indexPath.row == 5 {
                        return broadcastHistoryCell(indexPath: indexPath)
                    } else if indexPath.row == 6 {
                        return noteCell(indexPath: indexPath)
                    } else if indexPath.row == 7 {
                        return customerTagsInfoCell(indexPath: indexPath)
                    } else if indexPath.row == 8 {
                        return agentCustomerInfoCell(indexPath: indexPath)
                    }
                }else{
                    if indexPath.row == 0 {
                        return customerInfoCell(indexPath: indexPath)
                    } else if indexPath.row == 1 {
                        return HSMCell(indexPath: indexPath)
                    } else if indexPath.row == 2 {
                        return completeTaskCell(indexPath: indexPath)
                    } else if indexPath.row == 3 {
                        return additionalInformationCell(indexPath: indexPath)
                    }  else if indexPath.row == 4 {
                        return broadcastHistoryCell(indexPath: indexPath)
                    } else if indexPath.row == 5 {
                        return noteCell(indexPath: indexPath)
                    } else if indexPath.row == 6 {
                        return customerTagsInfoCell(indexPath: indexPath)
                    } else if indexPath.row == 7 {
                        return agentCustomerInfoCell(indexPath: indexPath)
                    }
                }
                
            }else if isWAWillExpired == true {
                if isWaBlocked == true {
                    if indexPath.row == 0 {
                        return customerInfoCell(indexPath: indexPath)
                    } else if indexPath.row == 1 {
                        return waBlockedCell(indexPath: indexPath)
                    } else if indexPath.row == 2 {
                        return HSMWillExpireSoonCell(indexPath: indexPath)
                    } else if indexPath.row == 3 {
                        return completeTaskCell(indexPath: indexPath)
                    } else if indexPath.row == 4 {
                        return additionalInformationCell(indexPath: indexPath)
                    }  else if indexPath.row == 5 {
                        return broadcastHistoryCell(indexPath: indexPath)
                    } else if indexPath.row == 6 {
                        return noteCell(indexPath: indexPath)
                    } else if indexPath.row == 7 {
                        return customerTagsInfoCell(indexPath: indexPath)
                    } else if indexPath.row == 8 {
                        return agentCustomerInfoCell(indexPath: indexPath)
                    }
                }else{
                    if indexPath.row == 0 {
                        return customerInfoCell(indexPath: indexPath)
                    } else if indexPath.row == 1 {
                        return HSMWillExpireSoonCell(indexPath: indexPath)
                    } else if indexPath.row == 2 {
                        return completeTaskCell(indexPath: indexPath)
                    } else if indexPath.row == 3 {
                        return additionalInformationCell(indexPath: indexPath)
                    }  else if indexPath.row == 4 {
                        return broadcastHistoryCell(indexPath: indexPath)
                    } else if indexPath.row == 5 {
                        return noteCell(indexPath: indexPath)
                    } else if indexPath.row == 6 {
                        return customerTagsInfoCell(indexPath: indexPath)
                    } else if indexPath.row == 7 {
                        return agentCustomerInfoCell(indexPath: indexPath)
                    }
                }
            } else {
                if isWaBlocked == true {
                    if indexPath.row == 0 {
                        return customerInfoCell(indexPath: indexPath)
                    } else if indexPath.row == 1 {
                        return waBlockedCell(indexPath: indexPath)
                    } else if indexPath.row == 2 {
                        return completeTaskCell(indexPath: indexPath)
                    } else if indexPath.row == 3 {
                        return additionalInformationCell(indexPath: indexPath)
                    }  else if indexPath.row == 4 {
                        return broadcastHistoryCell(indexPath: indexPath)
                    } else if indexPath.row == 5 {
                        return noteCell(indexPath: indexPath)
                    } else if indexPath.row == 6 {
                        return customerTagsInfoCell(indexPath: indexPath)
                    } else if indexPath.row == 7 {
                        return agentCustomerInfoCell(indexPath: indexPath)
                    }
                }else{
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
                }
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
            if isWAExpired == true {
                if isWaBlocked == true {
                    if indexPath.row == 4 {
                        self.tableView.deselectRow(at: indexPath, animated: true)
                        self.pushToAdditonalInformation()
                    } else if indexPath.row == 5 {
                        self.tableView.deselectRow(at: indexPath, animated: true)
                        self.pushToBroadcastHistory()
                    }else if indexPath.row == 6 {
                        self.showForNotes()
                        self.tableView.deselectRow(at: indexPath, animated: true)
                    }
                }else{
                    if indexPath.row == 3 {
                        self.tableView.deselectRow(at: indexPath, animated: true)
                        self.pushToAdditonalInformation()
                    } else if indexPath.row == 4 {
                        self.tableView.deselectRow(at: indexPath, animated: true)
                        self.pushToBroadcastHistory()
                    }else if indexPath.row == 5 {
                        self.showForNotes()
                        self.tableView.deselectRow(at: indexPath, animated: true)
                    }
                }
            } else if isWAWillExpired == true {
                if isWaBlocked == true {
                    if indexPath.row == 4 {
                        self.tableView.deselectRow(at: indexPath, animated: true)
                        self.pushToAdditonalInformation()
                    } else if indexPath.row == 5 {
                        self.tableView.deselectRow(at: indexPath, animated: true)
                        self.pushToBroadcastHistory()
                    }else if indexPath.row == 6 {
                        self.showForNotes()
                        self.tableView.deselectRow(at: indexPath, animated: true)
                    }
                }else{
                    if indexPath.row == 3 {
                        self.tableView.deselectRow(at: indexPath, animated: true)
                        self.pushToAdditonalInformation()
                    } else if indexPath.row == 4 {
                        self.tableView.deselectRow(at: indexPath, animated: true)
                        self.pushToBroadcastHistory()
                    }else if indexPath.row == 5 {
                        self.showForNotes()
                        self.tableView.deselectRow(at: indexPath, animated: true)
                    }
                }
                
            } else {
                if isWaBlocked == true {
                    if indexPath.row == 3 {
                        self.tableView.deselectRow(at: indexPath, animated: true)
                        self.pushToAdditonalInformation()
                    } else if indexPath.row == 4 {
                        self.tableView.deselectRow(at: indexPath, animated: true)
                        self.pushToBroadcastHistory()
                    }else if indexPath.row == 5 {
                        self.showForNotes()
                        self.tableView.deselectRow(at: indexPath, animated: true)
                    }
                }else{
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
                }
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

