//
//  DetailCustomerInformationContactVC.swift
//  Example
//
//  Created by arief nur putranto on 09/12/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON

class DetailCustomerInformationContactVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var contactID = 0
    var channelID = 0
    var channelName = "-"
    var channelType = ""
    var avatarChannel = UIImage()
    var ivBadgeChannel = UIImage()
    var avatarName = UIImage()
    var name = "-"
    var email = "-"
    var phoneNumber = "-"
    var lastConversation = ""
    var customerProperties = [CustomerProperties]()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupAPIContactProperties()
        self.setupAPIContact()
    }
    
    func setupUI(){
        self.title = "Customer Information"
        let backButton = self.backButton(self, action: #selector(DetailCustomerInformationContactVC.goBack))
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.leftBarButtonItems = [backButton]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barTintColor = ColorConfiguration.defaultColorTosca
        
        
        
        //tableView
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UINib(nibName: "DCIContactAvatarNameCell", bundle: nil), forCellReuseIdentifier: "DCIContactAvatarNameCellIdentifire")
        self.tableView.register(UINib(nibName: "DCIContactLastConversationCell", bundle: nil), forCellReuseIdentifier: "DCIContactLastConversationCellIdentifire")
        self.tableView.register(UINib(nibName: "HDCIContactEmailAndPhoneCell", bundle: nil), forCellReuseIdentifier: "HDCIContactEmailAndPhoneCellIdentifire")
        self.tableView.register(UINib(nibName: "HDCIContactChannelCell", bundle: nil), forCellReuseIdentifier: "HDCIContactChannelCellIdentifire")
        self.tableView.register(UINib(nibName: "HDCIContactCustomerPropertisCell", bundle: nil), forCellReuseIdentifier: "HDCIContactCustomerPropertisCellIdentifire")
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
    
    func setupAPIContactProperties(){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v2/contacts/properties/\(self.contactID)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: header as! HTTPHeaders).responseJSON { (response) in
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
                    let customerProperties = payload["data"]["customer_properties"].array
                    
                    if customerProperties?.count != 0 {
                        for data in customerProperties! {
                            var properties = CustomerProperties(json: data)
                            self.customerProperties.append(properties)
                        }
                    }
                    
                    self.tableView.reloadData()
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
            } else {
                //failed
            }
        }
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
                    let name = payload["data"]["contact"]["name"].string ?? "-"
                    let email = payload["data"]["contact"]["email"].string ?? "-"
                    let phonenumber = payload["data"]["contact"]["phone_number"].string ?? "-"
                    let lastConversation = payload["data"]["contact"]["last_customer_message_date"].string ?? ""
                    self.name = name
                    self.email = email
                    self.phoneNumber = phonenumber
                    self.lastConversation = lastConversation
                    
                    self.tableView.reloadData()
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
            } else {
                //failed
            }
        }
    }

}
extension DetailCustomerInformationContactVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 4{
            return CGFloat(self.customerProperties.count * 53 + 50)
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DCIContactAvatarNameCellIdentifire", for: indexPath) as! DCIContactAvatarNameCell
            cell.ivAvatarName.image = self.avatarName
            cell.lbName.text = self.name
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DCIContactLastConversationCellIdentifire", for: indexPath) as! DCIContactLastConversationCell
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"
            dateFormatter.timeZone = .current
            if let date = dateFormatter.date(from: self.lastConversation) {
                let dateFormatter2 = DateFormatter()
                dateFormatter2.dateFormat = "d/MM/yy"
                let dateString = dateFormatter2.string(from: date)
                
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "HH:mm"
                let timeString = timeFormatter.string(from: date)
                
                var result = "-"
                if Calendar.current.isDateInToday(date){
                    result = "Today, \(timeString)"
                }else if Calendar.current.isDateInYesterday(date) {
                    result = "Yesterday, \(timeString)"
                }else{
                    result = "\(dateString), \(timeString)"
                }
                
                cell.lbDateTime.text = result
            }else{
                cell.lbDateTime.text = "-"
            }
            
            return cell
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HDCIContactEmailAndPhoneCellIdentifire", for: indexPath) as! HDCIContactEmailAndPhoneCell
            cell.lbEMail.text = self.email
            cell.lbPhoneNumber.text = self.phoneNumber
            return cell
        } else if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HDCIContactChannelCellIdentifire", for: indexPath) as! HDCIContactChannelCell
            cell.lbChannelName.text = self.channelName
            cell.ivBadgeChannel.image = self.ivBadgeChannel
            return cell
        }else if indexPath.row == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HDCIContactCustomerPropertisCellIdentifire", for: indexPath) as! HDCIContactCustomerPropertisCell
            cell.tableViewHeightCons.constant = CGFloat(self.customerProperties.count * 53)
            cell.customerProperties = self.customerProperties
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            cell.tableView.reloadData()
            return cell
        }
        
        return UITableViewCell()
    }
    
}
