//
//  AccountManagementVC.swift
//  Example
//
//  Created by Qiscus on 09/02/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AccountManagementAgentVC: UIViewController,  UITableViewDataSource, UITableViewDelegate, AMProfileAvatarCellDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak public var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var btSave: UIButton!
    @IBOutlet weak var bottomTableViewCons: NSLayoutConstraint!
    var avatarURL = "https://"
    var fullName = ""
    var emailAddress = ""
    var role = [String]()
    var tfFullNameDuplicate = UITextField()
    //UnStableConnection
    @IBOutlet weak var viewUnstableConnection: UIView!
    @IBOutlet weak var heightViewUnstableConnectionConst: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupKeyboard()
        self.setupNavBar()
        self.setupButtonSave()
        self.setupTableView()
        self.getProfileApi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(hideUnstableConnection(_:)), name: NSNotification.Name(rawValue: "stableConnection"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showUnstableConnection(_:)), name: NSNotification.Name(rawValue: "unStableConnection"), object: nil)
        
        self.setupReachability()
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

    func setupButtonSave(){
        self.btSave.layer.cornerRadius = self.btSave.frame.height/2
    }
    
    func updateAvatarURL(avatarURL: URL) {
        self.avatarURL = avatarURL.absoluteString
    }
    
    func setupKeyboard(){
        NotificationCenter.default.addObserver(self, selector: #selector(AccountManagementAgentVC.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AccountManagementAgentVC.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setupNavBar(){
        //setup navigationBar
        self.title = "Account Management"
        let backButton = self.backButton(self, action: #selector(AccountManagementAgentVC.goBack))
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.leftBarButtonItems = [backButton]
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
    
    @IBAction func saveAction(_ sender: Any) {
        
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        if self.tfFullNameDuplicate.text?.isEmpty == true {
           
            //show alert
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name("AMFullnameChanged"), object: nil)
            return
        }
        
        self.loadingIndicator.startAnimating()
        self.loadingIndicator.isHidden = false
        
        var param: [String: Any] = [
            "name": self.tfFullNameDuplicate.text,
            "email" : self.emailAddress
        ]
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v1/agent/update_profile", method: .post, parameters: param,  encoding: JSONEncoding.default, headers: header as! HTTPHeaders).responseJSON { (response) in
            print("response call \(response)")
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //failed
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.saveAction(sender)
                            } else {
                                self.loadingIndicator.stopAnimating()
                                self.loadingIndicator.isHidden = true
                                return
                            }
                        }
                    }else{
                        //show error
                        self.loadingIndicator.stopAnimating()
                        self.loadingIndicator.isHidden = true
                        
                        let error = JSON(response.result.value)["errors"].string ?? "Something wrong"
                        
                        let vc = AlertAMFailedUpdate()
                        vc.errorMessage = error
                        vc.modalPresentationStyle = .overFullScreen
                        
                        self.navigationController?.present(vc, animated: false, completion: {
                            
                        })
                    }
                } else {
                    //success
                    self.loadingIndicator.stopAnimating()
                    self.loadingIndicator.isHidden = true
                    self.fullName = self.tfFullNameDuplicate.text ?? ""
                    self.tableView.reloadData()
                    
                    //show alert success
                    
                    let vc = AlertAMSuccessUpdate()
                    vc.modalPresentationStyle = .overFullScreen
                    
                    self.navigationController?.present(vc, animated: false, completion: {
                        
                    })
                    
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
                self.loadingIndicator.stopAnimating()
                self.loadingIndicator.isHidden = true
            } else {
                //failed
                self.loadingIndicator.stopAnimating()
                self.loadingIndicator.isHidden = true
            }
        }
    }
    
    @objc func changePassword(sender: UIButton){
        let vc = AMChangePasswordVC()
        vc.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(vc, animated: false, completion: {
            
        })
    }
    
    func getProfileApi(){
        self.loadingIndicator.startAnimating()
        self.loadingIndicator.isHidden = false
        
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
                                self.getProfileApi()
                            } else {
                                self.loadingIndicator.stopAnimating()
                                self.loadingIndicator.isHidden = true
                                return
                            }
                        }
                    }else{
                        //show error
                        self.loadingIndicator.stopAnimating()
                        self.loadingIndicator.isHidden = true
                        
                        let error = JSON(response.result.value)["errors"].string ?? "Something wrong"
                        
                        let vc = AlertAMFailedUpdate()
                        vc.errorMessage = error
                        vc.modalPresentationStyle = .overFullScreen
                        
                        self.navigationController?.present(vc, animated: false, completion: {
                            
                        })
                    }
                } else {
                    //success
                    let json = JSON(response.result.value)
                    let dataAvatarUrl = json["data"]["avatar_url"].string ?? "https://"
                    let dataName = json["data"]["name"].string ?? ""
                    let dataEmailAdress = json["data"]["email"].string ?? ""
                    let arrayRole = json["data"]["assigned_agent_roles"].array
                    
                    if arrayRole?.count != 0 {
                        for data in arrayRole! {
                            let dataRole = data["name"].string ?? ""
                            self.role.append(dataRole)
                        }
                    }
                    
                    self.emailAddress = dataEmailAdress
                    self.fullName = dataName
                    self.avatarURL = dataAvatarUrl
                    
                    self.tableView.reloadData()
                    self.tableView.isHidden = false
                    self.btSave.isHidden = false
                    self.loadingIndicator.stopAnimating()
                    self.loadingIndicator.isHidden = true
                    
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
                self.loadingIndicator.stopAnimating()
                self.loadingIndicator.isHidden = true
            } else {
                //failed
                self.loadingIndicator.stopAnimating()
                self.loadingIndicator.isHidden = true
            }
        }
    }
    
    // MARK: - Keyboard Methode
    @objc func keyboardWillHide(_ notification: Notification){
        let info: NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        
        let animateDuration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        self.bottomTableViewCons.constant = 25
        UIView.animate(withDuration: animateDuration, delay: 0, options: UIView.AnimationOptions(), animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification){
        let info:NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let keyboardSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let keyboardHeight: CGFloat = keyboardSize.height
        let animateDuration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        
        self.bottomTableViewCons.constant = 25 + keyboardHeight
        UIView.animate(withDuration: animateDuration, delay: 0, options: UIView.AnimationOptions(), animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    
    //tableView
    
    func setupTableView(){
        //table view
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UINib(nibName: "AMProfileAvatarCell", bundle: nil), forCellReuseIdentifier: "AMProfileAvatarCellIdentifire")
        self.tableView.register(UINib(nibName: "AMFullNameCell", bundle: nil), forCellReuseIdentifier: "AMFullNameCellIdentifire")
        self.tableView.register(UINib(nibName: "AMEmailAddressCell", bundle: nil), forCellReuseIdentifier: "AMEmailAddressCellIdentifire")
        self.tableView.register(UINib(nibName: "AMRoleCell", bundle: nil), forCellReuseIdentifier: "AMRoleCellIdentifire")
        self.tableView.register(UINib(nibName: "AMChangePasswordCell", bundle: nil), forCellReuseIdentifier: "AMChangePasswordCellIdentifire")
        
        
        
        self.tableView.tableFooterView = UIView()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AMProfileAvatarCellIdentifire", for: indexPath) as! AMProfileAvatarCell
            cell.viewVC = self.view
            cell.VC = self
            cell.delegate = self
            cell.setupData(urlImage: URL(string: self.avatarURL)!, dataFullName: self.fullName, dataEmailAddress: self.emailAddress)
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AMFullNameCellIdentifire", for: indexPath) as! AMFullNameCell
            cell.setupData(fullname : self.fullName)
            self.tfFullNameDuplicate = cell.tfFullname
            return cell
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AMEmailAddressCellIdentifire", for: indexPath) as! AMEmailAddressCell
            cell.setupData(emailAddress: self.emailAddress)
            return cell
        } else if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AMRoleCellIdentifire", for: indexPath) as! AMRoleCell
            cell.setupData(dataRole: self.role)
            return cell
        } else if indexPath.row == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AMChangePasswordCellIdentifire", for: indexPath) as! AMChangePasswordCell
            cell.btChangePassword.addTarget(self, action:#selector(self.changePassword(sender:)), for: .touchUpInside)
            return cell
            
        }
       
        return UITableViewCell()
    }
    
}
