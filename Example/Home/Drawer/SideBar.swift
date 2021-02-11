//
//  SideBar.swift
//  SampleNavigationDrawer
//
//  Created by Randolf Dini-ay on 03/04/2019.
//  Copyright © 2019 Randolf Dini-ay. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire
import SwiftyJSON
import QiscusCore

class SideBar: RDNavigationDrawer,  UITableViewDataSource, UITableViewDelegate {

    var viewModel: String!
    
    @IBOutlet weak var btEditProfile: UIButton!
    @IBOutlet weak var viewMenuLogout: UIView!
    @IBOutlet weak var viewMenuSetting: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var ivProfile: UIImageView!
    var hideOnlineOfflineAgent = true
    init(viewModel: String) {
        self.viewModel = viewModel
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let userType = UserDefaults.standard.getUserType(){
            if userType == 2 {
                hideOnlineOfflineAgent = false
            }else{
                hideOnlineOfflineAgent = true
            }
        } else {
            hideOnlineOfflineAgent = true
        }
        
        self.setupHeader()
        self.setupTableView()
        self.setupMenuLogout()
        self.setupMenuSetting()
        self.setupEditProfile()
    }
    
    func setupHeader(){
        self.ivProfile.layer.cornerRadius = self.ivProfile.frame.size.height/2
        
        if let profile = QiscusCore.getProfile(){
            self.lbName.text = profile.username
            self.ivProfile.af_setImage(withURL: profile.avatarUrl)
        }
        
        //load from server
        QiscusCore.shared.getProfile(onSuccess: { (profile) in
            self.lbName.text = profile.username
            self.ivProfile.af_setImage(withURL: profile.avatarUrl)
        }, onError: { (error) in
            //error
        })
    }
    
    func setupMenuLogout(){
        viewMenuLogout.layer.shadowColor = UIColor.black.cgColor
        viewMenuLogout.layer.shadowOffset = CGSize(width: 1, height: 1)
        viewMenuLogout.layer.shadowOpacity = 0.3
        viewMenuLogout.layer.shadowRadius = 1.0
        viewMenuLogout.layer.cornerRadius = 8
    }
    
    func setupMenuSetting(){
        viewMenuSetting.layer.shadowColor = UIColor.black.cgColor
        viewMenuSetting.layer.shadowOffset = CGSize(width: 1, height: 1)
        viewMenuSetting.layer.shadowOpacity = 0.3
        viewMenuSetting.layer.shadowRadius = 1.0
        viewMenuSetting.layer.cornerRadius = 8
    }
    
    func setupEditProfile(){
        self.btEditProfile.layer.cornerRadius = self.btEditProfile.frame.size.height/2
               
        btEditProfile.layer.shadowColor = UIColor.black.cgColor
        btEditProfile.layer.shadowOffset = CGSize(width: 1, height: 1)
        btEditProfile.layer.shadowOpacity = 0.3
        btEditProfile.layer.shadowRadius = 1.0
    }
    
    @IBAction func goToEditProfile(_ sender: Any) {
        if RDNavigationDrawer.isOpen == true {
            RDNavigationDrawer.sideToggle()
        }
        
        if let userType = UserDefaults.standard.getUserType(){
            if userType == 1  {
                //admin
                //coming soon
            }else if userType == 2{
                //agent
                let vc = AccountManagementAgentVC()
                self.currentViewController()?.navigationController?.pushViewController(vc, animated: true)
            }else{
                //spv
                //coming soon
            }
        }
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        if let userType = UserDefaults.standard.getUserType(){
            if userType == 2{
                //agent
                self.forceOffline()
            }
        }
        
        if let deviceToken = UserDefaults.standard.getDeviceToken(){
            QiscusCore.shared.removeDeviceToken(token: deviceToken, onSuccess: { (isSuccess) in
                
            }) { (error) in
                
            }
        }
        
        QiscusCore.logout { (error) in
            let app = UIApplication.shared.delegate as! AppDelegate
            app.auth()
        }
    }
    
    @IBAction func settingAction(_ sender: Any) {
        if RDNavigationDrawer.isOpen == true {
            RDNavigationDrawer.sideToggle()
        }
        let vc = SettingMenuVC()
        self.currentViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func forceOffline(){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        
        var param: [String: Any] = [
            "is_available": false
        ]
        
        
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v1/set_availability", method: .post, parameters: param, encoding: JSONEncoding.default, headers: header as! HTTPHeaders).responseJSON { (response) in
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //error
                    
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.forceOffline()
                            } else {
                                return
                            }
                        }
                    }
                    
                } else {
                    //success
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
            } else {
                //failed
                
            }
        }
    }
    
    
    func setupTableView(){
        //table view
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UINib(nibName: "AvailabilityAgentCell", bundle: nil), forCellReuseIdentifier: "AvailabilityAgentCellIdentifire")
        
        self.tableView.tableFooterView = UIView()
        self.tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if hideOnlineOfflineAgent == true {
            return 0
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AvailabilityAgentCellIdentifire", for: indexPath) as! AvailabilityAgentCell
        cell.getProfileInfo()
        return cell
        
    }
    
    func currentViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return currentViewController(base: nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController {
            let moreNavigationController = tab.moreNavigationController
            
            if let top = moreNavigationController.topViewController, top.view.window != nil {
                return currentViewController(base: top)
            } else if let selected = tab.selectedViewController {
                return currentViewController(base: selected)
            }
        }
        
        if let presented = base?.presentedViewController {
            return currentViewController(base: presented)
        }
        
        return base
    }
    
}

