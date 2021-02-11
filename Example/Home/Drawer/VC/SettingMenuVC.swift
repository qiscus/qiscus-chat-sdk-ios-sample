//
//  SettingMenuVC.swift
//  Example
//
//  Created by Qiscus on 09/02/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit

class SettingMenuVC: UIViewController {
    @IBOutlet weak var viewMenuAccountManagement: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavBar()
        self.setupMenuAccountManagement()
    }
    
    func setupMenuAccountManagement(){
        viewMenuAccountManagement.layer.shadowColor = UIColor.black.cgColor
        viewMenuAccountManagement.layer.shadowOffset = CGSize(width: 1, height: 1)
        viewMenuAccountManagement.layer.shadowOpacity = 0.3
        viewMenuAccountManagement.layer.shadowRadius = 1.0
        viewMenuAccountManagement.layer.cornerRadius = 8
    }
    
    @IBAction func accountManagementAction(_ sender: Any) {
        if let userType = UserDefaults.standard.getUserType(){
            if userType == 1  {
                //admin
                //coming soon
            }else if userType == 2{
                //agent
                let vc = AccountManagementAgentVC()
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                //spv
                //coming soon
            }
        }
    }
    
    func setupNavBar(){
        //setup navigationBar
        self.title = "Settings"
        let backButton = self.backButton(self, action: #selector(SettingMenuVC.goBack))
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

}
