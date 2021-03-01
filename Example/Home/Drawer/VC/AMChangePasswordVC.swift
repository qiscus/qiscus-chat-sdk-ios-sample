//
//  AMChangePasswordVC.swift
//  Example
//
//  Created by Qiscus on 10/02/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import QiscusCore

class AMChangePasswordVC: UIViewController {
    @IBOutlet weak var viewPopup: UIView!
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var buttonCancel: UIButton!
    
    @IBOutlet weak var tfOldPassword: UITextField!
    @IBOutlet weak var tfRepeatNewPassword: UITextField!
    @IBOutlet weak var tfNewPassword: UITextField!
    
    @IBOutlet weak var lbAlertMessageRepeatNewPassword: UILabel!
    @IBOutlet weak var lbAlertMessageOldPassword: UILabel!
    @IBOutlet weak var lbAlertMessageNewPassword: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var bottomViewConst: NSLayoutConstraint!
    
    //alert change password
    @IBOutlet weak var alertViewPopup: UIView!
    @IBOutlet weak var alertButtonOk: UIButton!
    
    @IBOutlet weak var alertSuccessViewPopup: UIView!
    @IBOutlet weak var alertSuccessButtonLogout: UIButton!
    
    @IBOutlet weak var lbAlertMessageSuccess: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    func setupUI(){
        self.loadingIndicator.isHidden = true
        self.viewPopup.layer.cornerRadius = 8
        self.buttonSave.layer.cornerRadius = self.buttonSave.frame.height / 2
        self.buttonCancel.layer.cornerRadius = self.buttonCancel.frame.height / 2
        self.buttonCancel.layer.borderWidth = 2
        self.buttonCancel.layer.borderColor = ColorConfiguration.defaultColorTosca.cgColor
        
        
        self.alertViewPopup.layer.cornerRadius = 8
        self.alertButtonOk.layer.cornerRadius = self.alertButtonOk.frame.height / 2
        
        self.alertSuccessViewPopup.layer.cornerRadius = 8
        self.alertSuccessButtonLogout.layer.cornerRadius = self.alertSuccessButtonLogout.frame.height / 2
        
        tfOldPassword.setBottomBorder()
        tfNewPassword.setBottomBorder()
        tfRepeatNewPassword.setBottomBorder()
        
        NotificationCenter.default.addObserver(self, selector: #selector(AMChangePasswordVC.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AMChangePasswordVC.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Keyboard Methode
    @objc func keyboardWillHide(_ notification: Notification){
        let info: NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        
        let animateDuration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        self.bottomViewConst.constant = 0
        UIView.animate(withDuration: animateDuration, delay: 0, options: UIView.AnimationOptions(), animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification){
        let info:NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let keyboardSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let keyboardHeight: CGFloat = keyboardSize.height
        let animateDuration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        
        self.bottomViewConst.constant = 0 + keyboardHeight
        UIView.animate(withDuration: animateDuration, delay: 0, options: UIView.AnimationOptions(), animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @IBAction func actionSave(_ sender: Any) {
        var oldPassOk = false
        var newPassOk = false
        var repeatPassOk = false
        
        
        if tfOldPassword.text?.isEmpty == true {
            self.lbAlertMessageOldPassword.isHidden = false
        }else{
            oldPassOk = true
            self.lbAlertMessageOldPassword.isHidden = true
        }
        
        if tfNewPassword.text?.isEmpty == true {
            self.lbAlertMessageNewPassword.isHidden = false
        }else{
            newPassOk = true
            self.lbAlertMessageNewPassword.isHidden = true
        }
        
        if tfRepeatNewPassword.text?.isEmpty == true {
            lbAlertMessageRepeatNewPassword.text = "This field is required."
            self.lbAlertMessageRepeatNewPassword.isHidden = false
        }else{
            repeatPassOk = true
            self.lbAlertMessageRepeatNewPassword.isHidden = true
        }
        
        if tfNewPassword.text != tfRepeatNewPassword.text && repeatPassOk == true {
            lbAlertMessageRepeatNewPassword.isHidden = false
            lbAlertMessageRepeatNewPassword.text = "Please enter the same value again."
            repeatPassOk = false
            return
        }
        
        if oldPassOk == true && newPassOk == true && repeatPassOk == true {
            self.postChangePassword(oldPassword : tfOldPassword.text ?? "", newPassword: tfNewPassword.text ?? "")
        }
    }
    
    
    @IBAction func actionCancel(_ sender: Any) {
        self.dismiss(animated: false) {
            
        }
    }
    
    @IBAction func actionOKAlert(_ sender: Any) {
        self.alertViewPopup.isHidden = true
        self.viewPopup.isHidden = false
    }
    
    @IBAction func actionLogoutAlert(_ sender: Any) {
        if let userType = UserDefaults.standard.getUserType(){
            if userType == 1  {
                //admin
                self.alertSuccessViewPopup.isHidden = true
                self.dismiss(animated: false) {
                    
                }
            }else if userType == 2{
                //agent
                self.forceOffline()
                
                if let deviceToken = UserDefaults.standard.getDeviceToken(){
                    QiscusCore.shared.removeDeviceToken(token: deviceToken, onSuccess: { (isSuccess) in
                        
                    }) { (error) in
                        
                    }
                }
                
                QiscusCore.logout { (error) in
                    let app = UIApplication.shared.delegate as! AppDelegate
                    app.auth()
                }
            }else{
                //spv
                
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
        }
        
        
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
    
    func postChangePassword(oldPassword: String, newPassword: String){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        self.view.endEditing(true)
        
        self.buttonSave.isEnabled = false
        self.loadingIndicator.startAnimating()
        self.loadingIndicator.isHidden = false
        
        var param: [String: Any] = [
            "old_password": oldPassword,
            "new_password" : newPassword
        ]
        
        var agentAdminSpv = "admin"
        if let userType = UserDefaults.standard.getUserType(){
            if userType == 1  {
                //admin
                agentAdminSpv = "admin"
            }else if userType == 2{
                //agent
                agentAdminSpv = "agent"
            }else{
                //spv
                agentAdminSpv = "agent" //using this baseURL
            }
        }
        
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v1/\(agentAdminSpv)/change_password", method: .post, parameters: param,  encoding: JSONEncoding.default, headers: header as! HTTPHeaders).responseJSON { (response) in
            print("response call \(response)")
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //failed
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.postChangePassword(oldPassword: oldPassword, newPassword : newPassword)
                            } else {
                                self.loadingIndicator.stopAnimating()
                                self.loadingIndicator.isHidden = true
                                self.buttonSave.isEnabled = true
                            }
                        }
                    }else{
                        self.loadingIndicator.stopAnimating()
                        self.loadingIndicator.isHidden = true
                        self.buttonSave.isEnabled = true
                        
                        //show alert failed
                        self.viewPopup.isHidden = true
                        self.alertViewPopup.isHidden = false
                        
                    }
                } else {
                    //success
                    self.loadingIndicator.stopAnimating()
                    self.loadingIndicator.isHidden = true
                    self.buttonSave.isEnabled = true
                    
                    //show alert success
                    self.viewPopup.isHidden = true
                    
                    if let userType = UserDefaults.standard.getUserType(){
                        if userType == 1  {
                            //admin
                            self.lbAlertMessageSuccess.text = "Your password has been updated"
                            self.alertSuccessButtonLogout.setTitle("OK", for: .normal)
                        }
                    }
                    
                    self.alertSuccessViewPopup.isHidden = false
                    
                    
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
                self.loadingIndicator.stopAnimating()
                self.loadingIndicator.isHidden = true
                self.buttonSave.isEnabled = true
            } else {
                //failed
                self.loadingIndicator.stopAnimating()
                self.loadingIndicator.isHidden = true
                self.buttonSave.isEnabled = true
            }
        }
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
