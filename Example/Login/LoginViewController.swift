//
//  LoginViewController.swift
//  example
//
//  Created by Qiscus on 30/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import UIKit
import QiscusCore
import QiscusUI

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Login"
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickLogin(_ sender: Any) {
        let alert = UIAlertController(title: "Login Qiscus", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Qiscus User or email"
        })
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "User Key or Password"
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
            if let name = alert.textFields?.first?.text {
                if let key = alert.textFields?.last?.text {
                    let local = UserDefaults.standard
//                    let avatar = URL(string: "https://www.w3schools.com/w3images/avatar2.png")
//                    let extras = [
//                        "access" : "admin",
//                        "name"   : name
//                    ]

                    QiscusCore.loginOrRegister(userID: name, userKey: key, onSuccess: { (user) in
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.auth()
                    }, onError: { (error) in
                        print("error \(String(describing: error))")
                        let alert = UIAlertController(title: "Failed to Login?", message: String(describing: error), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Try Again", style: .cancel, handler: nil))
                        
                        self.present(alert, animated: true)
                    })
                }
            }
        }))
        
        self.present(alert, animated: true)
        
    }
    
    @IBAction func clickJWT(_ sender: Any) {
        let token = "_"
        QiscusCore.login(withIdentityToken: token, onSuccess: { (user) in
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.auth()
        }) { (error) in
            print("Error Login \(error.message)")
        }
    }
}
