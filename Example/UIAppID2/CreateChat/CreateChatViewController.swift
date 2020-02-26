//
//  CreateChatViewController.swift
//  Example
//
//  Created by Qiscus on 28/02/20.
//  Copyright © 2020 Qiscus. All rights reserved.
//

import UIKit
import QiscusCore

class CreateChatViewController: UIViewController {

    @IBOutlet weak var lbUser: UILabel!
    @IBOutlet weak var btStartChat: UIButton!
    @IBOutlet weak var tfUserID: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.lbUser.text = "You are loggin with user \((QiscusCoreManager.qiscusCore2.getUserData()?.name)!)"
        self.setupNavigationTitle()
    }

    @IBAction func startChat(_ sender: Any) {
        QiscusCoreManager.qiscusCore2.connect(delegate: self)
        
        if(self.tfUserID.text?.isEmpty == true){
            self.tfUserID.becomeFirstResponder()
        } else {
            btStartChat.titleLabel?.text = "Loading..."
            btStartChat.isEnabled = false
            QiscusCoreManager.qiscusCore2.shared.chatUser(userId: self.tfUserID.text ?? "", onSuccess: { (qChatRoom, QMessage) in
                self.btStartChat.isEnabled = true
                self.btStartChat.titleLabel?.text = "Start Chat"
                let target = UIChatViewController2()
                target.room = qChatRoom
                self.navigationController?.pushViewController(target, animated: true)
            }) { (error) in
                self.btStartChat.titleLabel?.text = "Start Chat"
                self.btStartChat.isEnabled = true
                
                let alert = UIAlertController(title: "Error Start Chat", message: error.message, preferredStyle: UIAlertController.Style.alert)

                // add an action (button)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

                // show the alert
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.btStartChat.isEnabled = true
        self.btStartChat.titleLabel?.text = "Start Chat"
    }
    
    private func setupNavigationTitle(){
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = false
        }
        var totalButton = 1
        if let leftButtons = self.navigationItem.leftBarButtonItems {
            totalButton += leftButtons.count
        }
        
        if let rightButtons = self.navigationItem.rightBarButtonItems {
            totalButton += rightButtons.count
        }
        
        let backButton = self.backButton(self, action: #selector(CreateChatViewController.goBack))
        let rightButton = self.logoutButton(self, action: #selector(CreateChatViewController.logout))
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.leftBarButtonItems = [backButton]
        self.navigationItem.rightBarButtonItems = [rightButton]
        
        self.title = "Create Chat"
        
    }
    
    @objc func goBack() {
        view.endEditing(true)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func logout() {
        let text = "Are you want to logout?"
        let cancelTxt = "Cancel"
        let OK = TextConfiguration.sharedInstance.alertSettingText
        QPopUpView.showAlert(withTarget: self, message: text, firstActionTitle: OK, secondActionTitle: cancelTxt,
            doneAction: {
                QiscusCoreManager.qiscusCore2.clearUser { (error) in
                self.navigationController?.popViewController(animated: true)
            }
        },
            cancelAction: {}
        )
       
    }
    
    private func logoutButton(_ target: UIViewController, action: Selector) -> UIBarButtonItem{
        let backIcon = UIImageView()
        backIcon.contentMode = .scaleAspectFit
        
        let image = UIImage(named: "ic_logout")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        backIcon.image = image
        backIcon.tintColor = #colorLiteral(red: 0.5176470588, green: 0.7607843137, blue: 0.3803921569, alpha: 1)
        
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
    
    private func backButton(_ target: UIViewController, action: Selector) -> UIBarButtonItem{
        let backIcon = UIImageView()
        backIcon.contentMode = .scaleAspectFit
        
        let image = UIImage(named: "ic_back")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        backIcon.image = image
        backIcon.tintColor = #colorLiteral(red: 0.5176470588, green: 0.7607843137, blue: 0.3803921569, alpha: 1)
        
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
}

extension CreateChatViewController : QiscusConnectionDelegate {
    func onConnected(){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reSubscribeRoom2"), object: nil)
    }
    func onReconnecting(){
        
    }
    func onDisconnected(withError err: QError?){
        
    }
    
    func connectionState(change state: QiscusConnectionState) {
        
        
    }
}
