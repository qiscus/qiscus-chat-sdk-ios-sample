//
//  NewOpenChatSessionWAVC.swift
//  Example
//
//  Created by arief nur putranto on 01/03/22.
//  Copyright © 2022 Qiscus. All rights reserved.
//

import UIKit
import QiscusCore
import SwiftyJSON
import Alamofire

class NewOpenChatSessionWAVC: UIViewController {

    @IBOutlet weak var viewButton: UIView!
    @IBOutlet weak var btCancel: UIButton!
    @IBOutlet weak var btSend: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var bottomTableViewConstant: NSLayoutConstraint!
    
    var chargedCredit = "0 credits"
    var channelID : Int = 0
    var roomId : String = "0"
    var dataLanguage = [String]()
    var dataHSMTemplate = [HSMTemplateModel]()
    var dataHSMBroadCastTemplate = [BroadcastTemplateModel]()
    var dataHSMBroadCastTemplateFromSearch = [BroadcastTemplateModel]()
    var isHidePopup = false
    var lbtitle = "Open Session Chat"
    var showErrorAlert = false
    var showErrorAlertMessage = ""
    var messageTypeID = 0 //0 default, 1 hsm, 2 broadcast
    
    //dataSelected
    var dataSMTLSelected = ""
    var dataBroadcastTemplateSelected = ""
    
    //searchTemplate
    var isSearchTemplateActive : Bool = false
    
    //reset template
    var resetTemplate : Bool = false
    
    //tabSelectedButton
    var tabSelectedButton : Int = 1
    
    
    //language
    var dataBroadCastLanguageSelected : String = ""
    
    //dataHeaderBodyButton
    var dataHeader = [String]()
    var dataBody = [String]()
    var dataButton =  [String]()
    var isReloadTableViewFromHeaderBodyButton = true
    var isFirstTimeLoadListHeaderBodyButton = true
    
    var isReloadTableViewFromTemplatePreview = true
    
    var userID : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupData()
    }
    
    func setupUI(){
        self.title = lbtitle
        if let room = QiscusCore.database.room.find(id: roomId){
            let lastComment = room.lastComment?.message
            
            if lastComment?.lowercased() == "Business Initiate session started".lowercased(){
                self.title = "Follow Up Customer"
            }
        }
        
        self.btCancel.layer.borderWidth = 1
        self.btCancel.layer.borderColor = ColorConfiguration.defaultColorTosca.cgColor
        self.btCancel.layer.cornerRadius = self.btCancel.layer.frame.size.height / 2
       
        
        self.btSend.layer.cornerRadius = self.btSend.layer.frame.size.height / 2
        
        self.btSend.backgroundColor = UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha:1.0)
        self.btSend.setTitleColor(UIColor(red: 196/255.0, green: 196/255.0, blue: 196/255.0, alpha:1.0), for: .normal)
        self.btSend.isEnabled = false
        
        let backButton = self.backButton(self, action: #selector(OpenChatSessionWAVC.goBack))
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.leftBarButtonItems = [backButton]
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UINib(nibName: "HeaderChatSessionCell", bundle: nil), forCellReuseIdentifier: "HeaderChatSessionCellIdentifire")
        self.tableView.register(UINib(nibName: "MessageTypeChatSessionCell", bundle: nil), forCellReuseIdentifier: "MessageTypeChatSessionCellIdentifire")
        self.tableView.register(UINib(nibName: "AlertMessageChatSessionCell", bundle: nil), forCellReuseIdentifier: "AlertMessageChatSessionCellIdentifire")
        self.tableView.register(UINib(nibName: "SMTLChatSessionCell", bundle: nil), forCellReuseIdentifier: "SMTLChatSessionCellIdentifire")
        self.tableView.register(UINib(nibName: "Content24HSMChatSessionCell", bundle: nil), forCellReuseIdentifier: "Content24HSMChatSessionCellIdentifire")
        self.tableView.register(UINib(nibName: "TemplateNameChatSessionCell", bundle: nil), forCellReuseIdentifier: "TemplateNameChatSessionCellIdentifire")
        self.tableView.register(UINib(nibName: "HeaderBodyButtonChatSessionCell", bundle: nil), forCellReuseIdentifier: "HeaderBodyButtonChatSessionCellIdentifire")
        self.tableView.register(UINib(nibName: "BroadcastLanguageChatSessionCell", bundle: nil), forCellReuseIdentifier: "BroadcastLanguageChatSessionCellIdentifire")
        self.tableView.register(UINib(nibName: "PreviewTemplateChatSessionCell", bundle: nil), forCellReuseIdentifier: "PreviewTemplateChatSessionCellIdentifire")
        
        
    }
    
    func setupData(){
        self.getCustomerInfo()
        self.getTemplateHSM(channelID: self.channelID)
        
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func sendAction(_ sender: Any) {
        if messageTypeID == 1 {
            //sendHSM
            send24HSM()
        }else{
            //broadcast
            sendBroadcast()
        }
    }
    
    func checkDataCanSend(){
        var canSendButton = false
        var canSendHeader = false
        var canSendBody = false
        
        if self.dataButton.count != 0 {
            let checkEmpty = self.dataButton.filter { $0.isEmpty == true }
            
            if checkEmpty.count == 0 {
                canSendButton = true
            }else{
                canSendButton = false
            }
        }else{
            //without add data button
            canSendButton = true
        }
        
        if self.dataHeader.count != 0 {
            let checkEmpty = self.dataHeader.filter { $0.isEmpty == true }
            
            if checkEmpty.count == 0 {
                canSendHeader = true
            }else{
                canSendHeader = false
            }
        }else{
            //without add data header
            canSendHeader = true
        }
        
        if self.dataBody.count != 0 {
            let checkEmpty = self.dataBody.filter { $0.isEmpty == true }
            
            if checkEmpty.count == 0 {
                canSendBody = true
            }else{
                canSendBody = false
            }
        }else{
            //without add data body
            canSendBody = true
        }
        
        if canSendBody == true && canSendHeader == true && canSendButton == true {
            self.btSend.backgroundColor = ColorConfiguration.defaultColorTosca
            self.btSend.setTitleColor(UIColor.white, for: .normal)
            self.btSend.isEnabled = true
        }else{
            self.btSend.backgroundColor = UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha:1.0)
            self.btSend.setTitleColor(UIColor(red: 196/255.0, green: 196/255.0, blue: 196/255.0, alpha:1.0), for: .normal)
            self.btSend.isEnabled = false
        }
        
    }
    
    func getCustomerInfo(){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v1/qiscus/room/\(roomId)/user_info", method: .get, parameters: nil, headers: header as! HTTPHeaders).responseJSON { (response) in
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
                    var userID = json["data"]["user_id"].string ?? ""
                    self.userID = userID
                   
                    
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
            } else {
                //failed
            }
        }
    }
    
    func sendBroadcast(){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        let data = self.dataHSMBroadCastTemplate.filter { $0.name.lowercased() == self.dataBroadcastTemplateSelected.lowercased() }
        
        let dataPreview = data.first?.hsmDetails.first { $0.language.lowercased() == self.dataBroadCastLanguageSelected.lowercased() }
        
        if dataPreview == nil {
            return
        }
        
        var name = ""
        
        if let room = QiscusCore.database.room.find(id: roomId){
           name = room.name
            
        }
        
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        
        var param = [
            "template_detail_id": dataPreview?.id ?? 0,
            "phone_number" : self.userID
        ] as
        [String: Any]
        
        if !name.isEmpty{
            param["name"] = name
        }
        
        if self.dataHeader.count != 0 {
            var dictio = [String : Any]()
            dictio = ["type" : dataPreview?.headerType ?? "text", "text" : self.dataHeader.first]
            param["header_value"] = dictio
        }
        
        if self.dataButton.count != 0 {
            var arrayDictio = [[String : Any]]()
            for (index, element) in self.dataButton.enumerated() {
                for (indexDua, element) in dataPreview!.buttons.enumerated() {
                    if dataPreview?.buttons[indexDua].type.lowercased() == "url".lowercased() {
                        var dictio = [String : Any]()
                        dictio = ["type" : "url", "values" : self.dataButton[index], "index" : indexDua]
                        arrayDictio.append(dictio)
                    }
                }
            }
            
            param["button_params"] = arrayDictio
            
        }
        
        if self.dataBody.count != 0 {
            param["variables"] = self.dataBody
        }
        
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
        
        let json = JSON(param)
        print("check param ini =\(param)")
        print("check param ini2 =\(json)")
        
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v3/\(dataRole)/broadcast/client", method: .post, parameters: param, encoding: JSONEncoding.default, headers: header as! HTTPHeaders).responseJSON { (response) in
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //error
                    
                        if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.sendBroadcast()
                            } else {
                                return
                            }
                        }
                    }else{
                        let json = JSON(response.result.value)
                        var dataMessage = json["error"].string ?? ""
                        print("response.result.value =\(json)")
                        
                        var errorMessage = json["errors"]["message"].string ?? ""
                        
                        if errorMessage.isEmpty == false && dataMessage.isEmpty == true{
                            dataMessage = errorMessage
                        }
                        
                        let vc = AlertFailedSubmitWAOpenSession()
                        vc.modalPresentationStyle = .overFullScreen
                        vc.message = dataMessage

                        self.navigationController?.present(vc, animated: false, completion: {

                        })
                        
                        self.navigationController?.popViewController(animated: false)
                    }
                    
                } else {
                    //success
                    
                    let json = JSON(response.result.value)
                    var dataMessage = json["error"].string ?? ""
                    print("response.result.value =\(json)")
                    
                    let broadcastLog = json["data"]["broadcast_logs"].array
                    
                    let status = broadcastLog?.first?["status"].string ?? "failed"
                    let message = broadcastLog?.first?["notes"].string ?? "failed"
                    
                    if status.lowercased() == "failed".lowercased() {
                        let vc = AlertFailedSubmitWAOpenSession()
                        vc.modalPresentationStyle = .overFullScreen
                        vc.message = message

                        self.navigationController?.present(vc, animated: false, completion: {

                        })
                    } else {
                        let vc = AlertSuccessSubmitWAOpenSession()
                        vc.modalPresentationStyle = .overFullScreen
                        vc.message = "Successfully send broadcast template message."

                        self.navigationController?.present(vc, animated: false, completion: {

                        })
                    }
                    
                    self.navigationController?.popViewController(animated: false)
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
            } else {
                //failed
            }
        }
    }
    
    func send24HSM(){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        let filterData = self.dataHSMTemplate.filter{ $0.countryName.lowercased() == dataSMTLSelected.lowercased() }
        
        var templateID = 0
        if let data = filterData.first{
            templateID = data.id
        }else{
            return
        }
        
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        
        var param = [
            "room_id": self.roomId,
            "template_detail_id" : templateID
        ] as
        [String: Any]
        
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
                                self.send24HSM()
                            } else {
                                return
                            }
                        }
                    }else{
                        let json = JSON(response.result.value)
                        var dataMessage = json["error"].string ?? ""
                        print("response.result.value =\(json)")
                        
                        if dataMessage.contains("phone_number is invalid or don't have WA")  {
                            dataMessage = "phone number is invalid or don't have WA"
                        }
                        
                        let errorMessage = json["errors"]["message"].string ?? ""
                        
                        if errorMessage.isEmpty == false && dataMessage.isEmpty == true{
                            dataMessage = errorMessage
                        }
                        
                        let vc = AlertFailedSubmitWAOpenSession()
                        vc.modalPresentationStyle = .overFullScreen
                        vc.message = dataMessage

                        self.navigationController?.present(vc, animated: false, completion: {

                        })
                        
                    }
                    
                } else {
                    //success
                    self.navigationController?.popViewController(animated: false)
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
            } else {
                //failed
            }
        }
    }
    
    func reloadTableView(){
        self.tableView.reloadData()
    }
    
    @objc func goBack() {
        self.navigationController?.popViewController(animated: true)
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
    
    func getTemplateHSMBroadcasts(search : String = ""){
        self.showErrorAlert = false
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        
        
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v3/hsm?name=\(search)&page=1&limit=100&approved=true", method: .get, parameters: nil, headers: header as! HTTPHeaders).responseJSON { (response) in
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //error
                    
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.getTemplateHSMBroadcasts()
                            } else {
                                return
                            }
                        }
                    } else if response.response?.statusCode == 400 {
                        let json = JSON(response.result.value)
                        print("check result ini bro =\(json)")
                    }
                    
                } else {
                    //success
                    let payload = JSON(response.result.value)
                    let arrayTemplate = payload["data"]["hsm_templates"].array
                    let hsmQuota = payload["data"]["hsm_quota"].int ?? 0
                    
                    print("arief check jsoin ini =\(payload)")
                    
                    if arrayTemplate?.count == 0 {
                        if !search.isEmpty {
                            self.dataHSMBroadCastTemplateFromSearch.removeAll()
                        }else{
                            self.showErrorAlert = true
                            self.showErrorAlertMessage = "You don't have any Broadcast Messages Template."
                            
                            if let userType = UserDefaults.standard.getUserType(){
                                if userType == 2 {
                                    //agent
                                    self.showErrorAlertMessage = "You don't have any Broadcast Messages Template. Please notify your admin"
                                }
                            }
                        }
                        
                    }else{
                        if let templates = arrayTemplate{
                            self.dataHSMBroadCastTemplateFromSearch.removeAll()
                            
                            for i in templates{
                                let detail = BroadcastTemplateModel(json: i)
                                if !search.isEmpty {
                                    self.dataHSMBroadCastTemplateFromSearch.append(detail)
                                }else{
                                    self.dataHSMBroadCastTemplate.append(detail)
                                }
                                
                            }
                        }
                        
                        var  data = [BroadcastTemplateModel]()
                        
                        
                        if !search.isEmpty {
                            data = self.dataHSMBroadCastTemplateFromSearch.filter { $0.channelId == self.channelID }
                        }else{
                            data = self.dataHSMBroadCastTemplate.filter { $0.channelId == self.channelID }
                        }
                       
                        
                        if data.count == 0 {
                            if !search.isEmpty {
                                self.dataHSMBroadCastTemplateFromSearch.removeAll()
                                self.reloadTableView()
                                
                            }else{
                                self.showErrorAlert = true
                                self.showErrorAlertMessage = "You don't have any Broadcast Messages Template."
                                
                                if let userType = UserDefaults.standard.getUserType(){
                                    if userType == 2 {
                                        //agent
                                        self.showErrorAlertMessage = "You don't have any Broadcast Messages Template. Please notify your admin"
                                    }
                                }
                                
                            }
                           
                        }else{
                            if !search.isEmpty {
                                self.dataHSMBroadCastTemplateFromSearch = data
                            }else{
                                self.dataHSMBroadCastTemplate = data
                            }
                            
                        }
                        
                    }
                    
                    self.reloadTableView()
                  
                    
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
            } else {
                //failed
            }
        }
    }
    
    func getTemplateHSM(channelID: Int){
        self.showErrorAlert = false
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        let param = ["channel_id": channelID,
                     "approved" : true
        ] as [String : Any]
        
        
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v2/admin/hsm_24?channel_id=\(channelID)&approved=true", method: .get, parameters: nil, headers: header as! HTTPHeaders).responseJSON { (response) in
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
                    } else if response.response?.statusCode == 400 {
                        let json = JSON(response.result.value)
                        print("check result ini bro =\(json)")
                        if json.rawString()?.contains("No approved 24 Hours Message Template found") == true {
                            
                           
                            var message = "You don't have any 24 Hours Messages Template."
                            if let userType = UserDefaults.standard.getUserType(){
                                if userType == 2 {
                                    message = "You don't have any 24 Hours Messages Template. Please notify your admin"
                                }else{
                                    message = "You don't have any 24 Hours Messages Template."
                                }
                            }
                            self.showErrorAlert = true
                            self.showErrorAlertMessage = message
                            
                            self.reloadTableView()
                            
                        }
                    }
                    
                } else {
                    //success
                    let payload = JSON(response.result.value)
                    let arrayTemplate = payload["data"]["hsm_template"]["hsm_details"].array
                    let enableSendHSM = payload["data"]["enabled"].bool ?? false
                    let hsmQuota = payload["data"]["hsm_quota"].int ?? 0
                    let enabled = payload["data"]["enabled"].bool ?? false
                    print("arief check jsoin ini =\(payload)")
                    
                    
                    if enabled == false {
                        var message = "Your 24 Hours Messages Template is disabled."
                        if let userType = UserDefaults.standard.getUserType(){
                            if userType == 2 {
                                message = "Your 24 Hours Messages Template is disabled. Please notify your admin"
                            }else{
                                message = "Your 24 Hours Messages Template is disabled."
                            }
                        }
                        
                        self.showErrorAlert = true
                        self.showErrorAlertMessage = message
                        
                        self.reloadTableView()
                    }else{
                        self.showErrorAlert = false
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
                                self.dataSMTLSelected = self.dataLanguage.first ?? ""
                            }
                            
                            self.reloadTableView()
                            
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
    

}

extension NewOpenChatSessionWAVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if messageTypeID == 0 {
            //ui default
            if isHidePopup == true{
                return 1
            }else{
                return 2
            }
        }else if messageTypeID == 1{
            //ui hsm24
            if isHidePopup == true{
                if showErrorAlert == true{
                    return 2
                }else{
                    return 3
                }
            }else{
                if showErrorAlert == true{
                    return 3
                }else{
                    return 4
                }
            }
        }else{
            //ui broadcast
            if isHidePopup == true{
                if showErrorAlert == true{
                    return 2
                }else{
                    return 5
                }
            }else{
                if showErrorAlert == true{
                    return 3
                }else{
                    return 6
                }
            }
        }
        
    }
    
    func messageType(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTypeChatSessionCellIdentifire", for: indexPath) as! MessageTypeChatSessionCell
        cell.vc = self
        return cell
    }
    
    func alertMessage(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlertMessageChatSessionCellIdentifire", for: indexPath) as! AlertMessageChatSessionCell
        cell.setup(message: self.showErrorAlertMessage)
        return cell
    }
    
    func headerMessage(indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderChatSessionCellIdentifire", for: indexPath) as! HeaderChatSessionCell
        cell.lbMessage.text = "To start this business initiate session, the free session will be reduced or charged \(self.chargedCredit)."
        return cell
    }
    
    func SMTL(indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "SMTLChatSessionCellIdentifire", for: indexPath) as! SMTLChatSessionCell
        cell.vc = self
        cell.dataLanguage = self.dataLanguage
        if dataSMTLSelected.isEmpty == true {
            cell.tfSMTL.text = self.dataLanguage.first
        }else{
            cell.tfSMTL.text = dataSMTLSelected
        }
        
        
        self.btSend.backgroundColor = ColorConfiguration.defaultColorTosca
        self.btSend.setTitleColor(UIColor.white, for: .normal)
        self.btSend.isEnabled = true
        return cell
    }
    
    func content24HSM(indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "Content24HSMChatSessionCellIdentifire", for: indexPath) as! Content24HSMChatSessionCell
        
        
        let filterData = self.dataHSMTemplate.filter{ $0.countryName.lowercased() == self.dataSMTLSelected.lowercased() }
        
        if let data = filterData.first{
            cell.setupData(message: data.content)
        }else{
            cell.setupData(message: "")
        }
        
        return cell
        
    }
    
    //boardcast
    
    func templateNameBroadcast(indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "TemplateNameChatSessionCellIdentifire", for: indexPath) as! TemplateNameChatSessionCell
        
        cell.vc = self
        
        if self.resetTemplate == true{
            cell.resetTemplate()
            self.resetTemplate = false
        }
        
        if self.isSearchTemplateActive == true{
            cell.setupData(data: self.dataHSMBroadCastTemplateFromSearch, selectedTemplate: self.dataBroadcastTemplateSelected)
        }else{
            cell.setupData(data: self.dataHSMBroadCastTemplate, selectedTemplate: self.dataBroadcastTemplateSelected)
        }
        
        return cell
        
    }
    
    func headerBodyButtonBroadcast(indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderBodyButtonChatSessionCellIdentifire", for: indexPath) as! HeaderBodyButtonChatSessionCell
        
        let data = self.dataHSMBroadCastTemplate.filter { $0.name.lowercased() == self.dataBroadcastTemplateSelected.lowercased() }
        
        cell.vc = self
        cell.data = data
        cell.setupButton(isClick: self.tabSelectedButton, isFirstTime: true)
        
        if self.isReloadTableViewFromHeaderBodyButton == true{
            cell.setupHeightTableView()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if self.isFirstTimeLoadListHeaderBodyButton == true {
                self.isFirstTimeLoadListHeaderBodyButton = false
                cell.headerActionClick(cell.btHeader)
            }
            
        }
        
        
        return cell
        
    }
    
    func broadcastLanguage(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BroadcastLanguageChatSessionCellIdentifire", for: indexPath) as! BroadcastLanguageChatSessionCell
        let data = self.dataHSMBroadCastTemplate.filter { $0.name.lowercased() == self.dataBroadcastTemplateSelected.lowercased() }
        
        cell.vc = self
        cell.setup(data : data)
        return cell
    }
    
    func previewTemplate(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PreviewTemplateChatSessionCellIdentifire", for: indexPath) as! PreviewTemplateChatSessionCell
        let data = self.dataHSMBroadCastTemplate.filter { $0.name.lowercased() == self.dataBroadcastTemplateSelected.lowercased() }
        
        let dataPreview = data.first?.hsmDetails.first { $0.language.lowercased() == self.dataBroadCastLanguageSelected.lowercased() }
        
        cell.vc = self
        cell.setup(data : dataPreview)
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if messageTypeID == 0 {
            //ui default
            if isHidePopup == true{
                return messageType(indexPath: indexPath)
            }else{
                if indexPath.row == 0{
                    return headerMessage(indexPath: indexPath)
                }else{
                    return messageType(indexPath: indexPath)
                }
            }
        }else if messageTypeID == 1{
            //ui hsm24
            if isHidePopup == true{
                if showErrorAlert == true{
                    if indexPath.row == 0{
                        return messageType(indexPath: indexPath)
                    }else{
                        return alertMessage(indexPath: indexPath)
                    }
                }else{
                    if indexPath.row == 0{
                        return messageType(indexPath: indexPath)
                    }else if indexPath.row == 1 {
                        //UI Select Message Template Language
                        return SMTL(indexPath: indexPath)
                    }else {
                        // ui content
                        return content24HSM(indexPath: indexPath)
                    }
                }
            }else{
                if showErrorAlert == true{
                    if indexPath.row == 0{
                        return headerMessage(indexPath: indexPath)
                    }else if indexPath.row == 1 {
                        return messageType(indexPath: indexPath)
                    }else {
                        return alertMessage(indexPath: indexPath)
                    }
                }else{
                    if indexPath.row == 0{
                        return headerMessage(indexPath: indexPath)
                    }else if indexPath.row == 1 {
                        return messageType(indexPath: indexPath)
                    }else if indexPath.row == 2 {
                        //UI Select Message Template Language
                        return SMTL(indexPath: indexPath)
                    }else {
                        // ui content
                        return content24HSM(indexPath: indexPath)
                    }
                }
            }
        }else{
            //ui broadcast
            
            if isHidePopup == true{
                if showErrorAlert == true{
                    if indexPath.row == 0{
                        return messageType(indexPath: indexPath)
                    }else{
                        return alertMessage(indexPath: indexPath)
                    }
                }else{
                    if indexPath.row == 0{
                        return messageType(indexPath: indexPath)
                    }else if indexPath.row == 1 {
                        //UI Template Name
                        return templateNameBroadcast(indexPath: indexPath)
                    }else if indexPath.row == 2 {
                        // ui language
                        return broadcastLanguage(indexPath: indexPath)
                    }else if indexPath.row == 3{
                        // ui preview
                        return previewTemplate(indexPath: indexPath)
                    }else {
                        // ui tab
                        return headerBodyButtonBroadcast(indexPath: indexPath)
                    }
                }
            }else{
                if showErrorAlert == true{
                    if indexPath.row == 0{
                        return headerMessage(indexPath: indexPath)
                    }else if indexPath.row == 1{
                        return messageType(indexPath: indexPath)
                    }else{
                        return alertMessage(indexPath: indexPath)
                    }
                }else{
                    if indexPath.row == 0{
                        return headerMessage(indexPath: indexPath)
                    }else if indexPath.row == 1{
                        return messageType(indexPath: indexPath)
                    }else if indexPath.row == 2 {
                        //UI Template Name
                        return templateNameBroadcast(indexPath: indexPath)
                    }else if indexPath.row == 3 {
                        // ui language
                        return broadcastLanguage(indexPath: indexPath)
                    }else if indexPath.row == 4{
                        // ui preview
                        return previewTemplate(indexPath: indexPath)
                    }else {
                        // ui tab
                        return headerBodyButtonBroadcast(indexPath: indexPath)
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
    }
    
}
