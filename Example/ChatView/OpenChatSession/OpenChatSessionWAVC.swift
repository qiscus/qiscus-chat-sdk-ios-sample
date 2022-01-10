//
//  OpenChatSessionWAVC.swift
//  Example
//
//  Created by arief nur putranto on 29/12/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class OpenChatSessionWAVC: UIViewController {

    @IBOutlet weak var lbContent: UILabel!
    @IBOutlet weak var lbAlertHSM: UILabel!
    @IBOutlet weak var viewAlertHSM: UIView!
    @IBOutlet weak var heightTabelViewMessageType: NSLayoutConstraint!
    @IBOutlet weak var heightTableViewSMTL: NSLayoutConstraint!
    @IBOutlet weak var lbMessageAlert: UILabel!
    @IBOutlet weak var tableViewSMTL: UITableView!
    @IBOutlet weak var tableViewMessageType: UITableView!
    @IBOutlet weak var tfMessageType: UITextField!
    @IBOutlet weak var tfSMTL: UITextField!
    @IBOutlet weak var viewAlert: UIView!
    @IBOutlet weak var tvContent: UITextView!
    @IBOutlet weak var btCancel: UIButton!
    @IBOutlet weak var btSend: UIButton!
    var chargedCredit = "0 credits"
    var channelID : Int = 0
    var roomId : String = "0"
    var dataLanguage = [String]()
    var dataHSMTemplate = [HSMTemplateModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Open Session Chat"
        let backButton = self.backButton(self, action: #selector(OpenChatSessionWAVC.goBack))
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.leftBarButtonItems = [backButton]
        
        self.getTemplateHSM(channelID: self.channelID)
        
        self.lbMessageAlert.text = "To start this business initiate session, the free session will be reduced or charged \(chargedCredit)."
        
        self.viewAlert.layer.cornerRadius = 8
        
        self.btCancel.layer.borderWidth = 1
        self.btCancel.layer.borderColor = ColorConfiguration.defaultColorTosca.cgColor
        self.btCancel.layer.cornerRadius = self.btCancel.layer.frame.size.height / 2
       
        
        self.btSend.layer.cornerRadius = self.btSend.layer.frame.size.height / 2
        
        self.btSend.backgroundColor = UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha:1.0)
        self.btSend.setTitleColor(UIColor(red: 196/255.0, green: 196/255.0, blue: 196/255.0, alpha:1.0), for: .normal)
        self.btSend.isEnabled = false
        
        
        self.tfMessageType.rightViewMode = UITextField.ViewMode.always
        let imageView = UIImageView(frame: CGRect(x: -15, y: -15, width: 20, height: 20))
        let image = UIImage(named: "ic_drop_down")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        imageView.image = image
        imageView.tintColor = UIColor.lightGray
        self.tfMessageType.rightView = imageView
        
       
        //tableView
        self.tableViewSMTL.dataSource = self
        self.tableViewSMTL.delegate = self
        self.tableViewSMTL.tableFooterView = UIView()
        self.tableViewSMTL.register(UINib(nibName: "OpenSessionWACell", bundle: nil), forCellReuseIdentifier: "OpenSessionWACellIdentifire")
        
        self.tableViewMessageType.dataSource = self
        self.tableViewMessageType.delegate = self
        self.tableViewMessageType.tableFooterView = UIView()
        self.tableViewMessageType.register(UINib(nibName: "OpenSessionWACell", bundle: nil), forCellReuseIdentifier: "OpenSessionWACellIdentifire")
        
        self.tfMessageType.text = "24 Hours Message Template"

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

    @IBAction func cancelAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func sendAction(_ sender: Any) {
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        let filterData = self.dataHSMTemplate.filter{ $0.countryName.lowercased() == tfSMTL.text?.lowercased() }
        
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
                                self.sendAction(sender)
                            } else {
                                return
                            }
                        }
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
    
    @IBAction func messageTypeClick(_ sender: Any) {
        if heightTabelViewMessageType.constant == 60 {
            self.heightTabelViewMessageType.constant = 0
            self.heightTableViewSMTL.constant = 0
        }else{
            self.heightTabelViewMessageType.constant = 60
            self.heightTableViewSMTL.constant = 0
        }
        
        
    }
    @IBAction func messageSMTLClick(_ sender: Any) {
        if self.heightTableViewSMTL.constant == CGFloat(self.dataLanguage.count * 60) {
            self.heightTabelViewMessageType.constant = 0
            self.heightTableViewSMTL.constant = 0
        }else{
            self.heightTableViewSMTL.constant = CGFloat(self.dataLanguage.count * 60)
            self.heightTabelViewMessageType.constant = 0
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
        
        
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v2/admin/hsm_24?channel_id=\(channelID)&approved=true", method: .get, parameters: nil, headers: header as! HTTPHeaders).responseJSON { (response) in
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //error
                    
                    self.viewAlertHSM.layer.cornerRadius = 8
                    
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
                            
                            self.viewAlertHSM.isHidden = false
                            var message = "You dont have any 24 Hours Messages Template."
                            if let userType = UserDefaults.standard.getUserType(){
                                if userType == 2 {
                                    message = "You dont have any 24 Hours Messages Template. Please notify your admin"
                                }else{
                                    message = "You dont have any 24 Hours Messages Template."
                                }
                            }
                            
                            self.tfSMTL.isHidden = true
                            self.lbContent.isHidden = true
                            self.lbAlertHSM.text = message
                            
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
                        self.viewAlertHSM.layer.cornerRadius = 8
                        self.viewAlertHSM.isHidden = false
                        var message = "Your 24 Hours Messages Template is disabled."
                        if let userType = UserDefaults.standard.getUserType(){
                            if userType == 2 {
                                message = "Your 24 Hours Messages Template is disabled. Please notify your admin"
                            }else{
                                message = "Your 24 Hours Messages Template is disabled."
                            }
                        }
                        
                        self.tfSMTL.isHidden = true
                        self.lbContent.isHidden = true
                        self.lbAlertHSM.text = message
                        
                        
                    }else{
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
                                self.tfSMTL.text = self.dataLanguage.first
                                
                                let filterData = self.dataHSMTemplate.filter{ $0.countryName.lowercased() == self.dataLanguage.first!.lowercased() }
                                
                                if let data = filterData.first{
                                    self.tvContent.text = data.content
                                }else{
                                    self.tvContent.text = ""
                                }
                                
                                self.btSend.backgroundColor = ColorConfiguration.defaultColorTosca
                                self.btSend.setTitleColor(UIColor.white, for: .normal)
                                self.btSend.isEnabled = true
                                
                            }
                            
                            self.tfSMTL.rightViewMode = UITextField.ViewMode.always
                            let imageViewtfSMTL = UIImageView(frame: CGRect(x: 0, y: 10, width: 20, height: 20))
                            let imagetfSMTL = UIImage(named: "ic_drop_down")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                            imageViewtfSMTL.image = imagetfSMTL
                            imageViewtfSMTL.tintColor = UIColor.lightGray
                            self.tfSMTL.rightView = imageViewtfSMTL
                         
                            self.tableViewSMTL.reloadData()
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

extension OpenChatSessionWAVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableViewMessageType {
            return 1
        }else{
            return dataLanguage.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableViewMessageType {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OpenSessionWACellIdentifire", for: indexPath) as! OpenSessionWACell
            cell.lbMessage.text = "24 Hours Message Template"
            
            cell.viewShadow.layer.shadowColor = UIColor.black.cgColor
            cell.viewShadow.layer.shadowOffset = CGSize(width: 1, height: 1)
            cell.viewShadow.layer.shadowOpacity = 0.3
            cell.viewShadow.layer.shadowRadius = 1.5
            cell.viewShadow.layer.cornerRadius = 8
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "OpenSessionWACellIdentifire", for: indexPath) as! OpenSessionWACell
            let data = self.dataLanguage[indexPath.row]
            cell.viewShadow.layer.shadowColor = UIColor.black.cgColor
            cell.viewShadow.layer.shadowOffset = CGSize(width: 1, height: 1)
            cell.viewShadow.layer.shadowOpacity = 0.3
            cell.viewShadow.layer.shadowRadius = 1.5
            cell.viewShadow.layer.cornerRadius = 8
            
            cell.lbMessage.text = data
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableViewMessageType {
            self.tfMessageType.text = "24 Hours Message Template"
            self.heightTabelViewMessageType.constant = 0
        }else{
            self.tfSMTL.text = self.dataLanguage[indexPath.row]
            self.heightTableViewSMTL.constant = 0
        }
    }
    
}

