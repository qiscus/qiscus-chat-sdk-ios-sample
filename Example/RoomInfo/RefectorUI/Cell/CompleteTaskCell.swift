//
//  CompleteTaskCell.swift
//  Example
//
//  Created by Qiscus on 02/12/20.
//  Copyright © 2020 Qiscus. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import QiscusCore

class CompleteTaskCell: UITableViewCell {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var heightTableViewCompleteTaskCell: NSLayoutConstraint!
    var viewController : ChatAndCustomerInfoVC? = nil
    var submitTicketModel : [SubmitTicketModel]? = nil
    var roomID : Int = 0
    var additionalInfo: [AdditionalInformationModel]? = nil
    //var customerProperties : [CustomerProperty]? = nil
    var tags : [TagsModel]? = nil
    var notes : String = ""
    var agentData : Agent? = nil
    var customerData : Customer? = nil
    var channelName: String = ""
    var roomName : String = ""
    var channelID: Int = 0
    var channelType: String = ""
    var avatarURL = "https://"
    var stillProgressSubmit = false
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        getData()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupUI(){
        //table view
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView()
        self.tableView.register(SubmitTicketCell.nib, forCellReuseIdentifier: SubmitTicketCell.identifier)
        self.tableView.register(UINib(nibName: "SubmitTicketCell", bundle: nil), forCellReuseIdentifier: "SubmitTicketCellIdentifire")
    }
    
    func setupData(submitTicketModel : [SubmitTicketModel]? = nil){
        self.submitTicketModel = submitTicketModel
        if let ticketModel = submitTicketModel {
            if ticketModel.count == 0 {
                heightTableViewCompleteTaskCell.constant = 0
            }else{
                heightTableViewCompleteTaskCell.constant = CGFloat(ticketModel.count * 65)
                self.tableView.reloadData()
                
            }
        } else {
            heightTableViewCompleteTaskCell.constant = 0
        }
    }
    
    func getData(){
        
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.replacingOccurrences(of: "\n", with: "\\n").data(using: String.Encoding.utf8) {
            do {
               let a = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String: Any]
               return a
            } catch {
                print(String(describing: error))
                return nil
            }
        }
        return nil
    }
    
    func getCustomerInfo(roomID : String){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v1/qiscus/room/\(roomID)/user_info", method: .get, parameters: nil, headers: header as! HTTPHeaders).responseJSON { (response) in
            print("response call \(response)")
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //failed
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.getCustomerInfo(roomID: roomID)
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
                    self.customerData = Customer(avatar: self.avatarURL, name: self.roomName, userID: userID)
                    self.channelName = channelName
                    self.channelID = channelID
                   
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
                            self.additionalInfo = results
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
                        self.tags = results
                    }
                   
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
            } else {
                //failed
            }
        }
    }
    
    func getNotes(roomID : String){
        //always check from local db
        if let room = QiscusCore.database.room.find(id: roomID){
            if !room.options!.isEmpty{
                let json = JSON.init(parseJSON: room.options!)
                var channelType = json["channel"].string ?? "Qiscus Widget"
                if channelType.lowercased() == "ig" {
                    channelType = "Instagram"
                }
                
                if channelType.lowercased() == "custom" {
                    channelType = "Custom Channel"
                }
                
                if channelType.lowercased() == "qiscus" {
                    channelType = "Qiscus Widget"
                }
                self.channelType = channelType
                let notesData = json["notes"].string ?? ""
                self.notes = notesData
            }
            
            if let avatar = room.avatarUrl {
                self.avatarURL = avatar.absoluteString
            }else{
                self.avatarURL = room.avatarUrl?.absoluteString ?? "http://"
            }
            
            self.roomName = room.name
        }
    }
    
    func getProfileAdmin(){
         
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v1/admin/get_profile", method: .get, parameters: nil, headers: header as! HTTPHeaders).responseJSON { (response) in
            print("response call \(response)")
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //failed
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.getProfileAdmin()
                            } else {
                               
                                return
                            }
                        }
                    }
                } else {
                    //success
                    let json = JSON(response.result.value)
                    let dataName = json["data"]["name"].string ?? ""
                    let dataEmailAdress = json["data"]["email_address"].string ?? ""
                    
                    self.agentData = Agent(email: dataEmailAdress, name: dataName, type: "Admin")
                }
            }
        }
    }
    
    func getProfileSPV(){
         
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v1/agent/get_profile", method: .get, parameters: nil, headers: header as! HTTPHeaders).responseJSON { (response) in
            print("response call \(response)")
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //failed
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.getProfileSPV()
                            } else {
                               
                                return
                            }
                        }
                    }
                } else {
                    //success
                    let json = JSON(response.result.value)
                    let dataName = json["data"]["name"].string ?? ""
                    let dataEmailAdress = json["data"]["email"].string ?? ""
                    
                    self.agentData = Agent(email: dataEmailAdress, name: dataName, type: "admin")
                }
            }
        }
    }
    
    func getProfileAgent(){
         
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v1/agent/get_profile", method: .get, parameters: nil, headers: header as! HTTPHeaders).responseJSON { (response) in
            print("response call \(response)")
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //failed
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.getProfileAgent()
                            } else {
                               
                                return
                            }
                        }
                    }
                } else {
                    //success
                    let json = JSON(response.result.value)
                    let dataName = json["data"]["name"].string ?? ""
                    let dataEmailAdress = json["data"]["email"].string ?? ""
                    
                    self.agentData = Agent(email: dataEmailAdress, name: dataName, type: "Agent")
                }
            }
        }
    }
    
    
    @objc func submitTicket(sender: UIButton){
        submitTicket(id : sender.tag)
    }
    
    func submitTicket(id : Int){
        if stillProgressSubmit == false {
            self.viewController?.viewLoading.isHidden = false
            self.viewController?.loadingIndicator.isHidden = false
            self.viewController?.loadingIndicator.startAnimating()
           stillProgressSubmit = true
            
            self.getListTags(roomID: "\(self.roomID)")
            self.getNotes(roomID: "\(self.roomID)")
            self.getCustomerInfo(roomID: "\(self.roomID)")
            
            if let userType = UserDefaults.standard.getUserType(){
                if userType == 1  {
                   //admin
                    self.getProfileAdmin()
                }else if userType == 2{
                    //agent
                    self.getProfileAgent()
                }else{
                    //spv
                    self.getProfileSPV()
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.submit(id : id)
            }
        }
    }
    
    func submit(id : Int){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        
        
        var params = [String: Any]()
        
        if let additionals = self.additionalInfo{
            var array = [[String : Any]]()
            
            for additional in additionals{
                array.append(additional.dictio)
            }
            params["additional_info"] = array
        }
        
        if let tags = self.tags{
            var array = [[String : Any]]()

            for tag in tags{
                array.append(tag.completeDict)
            }


            params["tags"] = array
        }

        if let agent = agentData{
            params["agent"] = ["email" : agent.email, "name": agent.name, "type": agent.type]
        }

        if let customer = customerData{
            params["customer"] = ["avatar" : customer.avatar, "name" : customer.name, "user_id" : customer.userID]
        }

        params["notes"] = "\(self.notes)"

        params["channel_name"] = "\(self.channelName)"

        params["channel_type"] = "\(channelType)"

        params["channel_id"] = "\(channelID)"

        params["room_id"] = "\(roomID)"

        var AllParams :  [String : Any] = ["id" : id, "ticket_payload" : params]
       
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v2/ticketing/submit", method: .post, parameters: AllParams, encoding: JSONEncoding.default , headers: header as! HTTPHeaders).responseJSON { (response) in
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //error

                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.submit(id: id)
                            } else {
                                self.viewController?.viewLoading.isHidden = true
                                self.viewController?.loadingIndicator.isHidden = true
                                self.viewController?.loadingIndicator.stopAnimating()
                                self.stillProgressSubmit = false
                                return
                            }
                        }
                    }else{
                        self.viewController?.viewLoading.isHidden = true
                        self.viewController?.loadingIndicator.isHidden = true
                        self.viewController?.loadingIndicator.stopAnimating()
                        self.stillProgressSubmit = false

                        let vc = AlertFailedSubmitTicket()
                        vc.modalPresentationStyle = .overFullScreen

                        self.viewController?.navigationController?.present(vc, animated: false, completion: {

                        })
                    }

                } else {
                    //success
                    self.stillProgressSubmit = false
                    let payload = JSON(response.result.value)
                    self.viewController?.viewLoading.isHidden = true
                    self.viewController?.loadingIndicator.isHidden = true
                    self.viewController?.loadingIndicator.stopAnimating()

                    let vc = AlertSuccessSubmitTicket()
                    vc.dataLabel = payload["status"].string ?? "Successfully Submit Ticket"
                    vc.modalPresentationStyle = .overFullScreen

                    self.viewController?.navigationController?.present(vc, animated: false, completion: {

                    })
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
                self.viewController?.viewLoading.isHidden = true
                self.viewController?.loadingIndicator.isHidden = true
                self.viewController?.loadingIndicator.stopAnimating()
                self.stillProgressSubmit = false
            } else {
                //failed
                self.viewController?.viewLoading.isHidden = true
                self.viewController?.loadingIndicator.isHidden = true
                self.viewController?.loadingIndicator.stopAnimating()
                self.stillProgressSubmit = false
            }
        }
    }
}

extension CompleteTaskCell: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let ticketModel = self.submitTicketModel {
            return ticketModel.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let ticketModel = self.submitTicketModel {
            if ticketModel.count == 0 {
                //no action
            } else {
                let data = ticketModel[indexPath.row]
                let cell = tableView.dequeueReusableCell(withIdentifier: SubmitTicketCell.identifier, for: indexPath) as! SubmitTicketCell
                cell.setupData(data: data)
                cell.buttonSubmitTicket.addTarget(self, action:#selector(self.submitTicket(sender:)), for: .touchUpInside)
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let ticketModel = self.submitTicketModel {
            if ticketModel.count == 0 {
                
            }else{
                let data = ticketModel[indexPath.row]
                self.submitTicket(id: data.id)
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
    
}
