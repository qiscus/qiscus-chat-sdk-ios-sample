//
//  LoginViewController.swift
//  example
//
//  Created by Qiscus on 30/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import UIKit
import QiscusCore


class LoginViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textFieldUserID: UITextField!
    @IBOutlet weak var textFieldUserKey: UITextField!
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var viewStart: UIView!
    @IBOutlet weak var arrowNext: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Login"
        // Do any additional setup after loading the view.
        self.setup()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setup(){
        self.textFieldUserID.delegate = self
        self.textFieldUserKey.delegate = self
        self.textFieldName.delegate = self
        
        self.textFieldUserID.setBottomBorder()
        self.textFieldUserKey.setBottomBorder()
        self.textFieldName.setBottomBorder()
        
        self.textFieldUserID.addDoneButtonOnKeyboard()
        self.textFieldUserKey.addDoneButtonOnKeyboard()
        self.textFieldName.addDoneButtonOnKeyboard()
        
        self.arrowNext.image = self.arrowNext.image?.withRenderingMode(.alwaysTemplate)
        self.arrowNext.tintColor = UIColor.white
        
        let tap = UITapGestureRecognizer(target: self, action:#selector(login))
        self.viewStart.addGestureRecognizer(tap)
        
        self.viewStart.layer.cornerRadius = 4
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    // Called when the UIKeyboardWillHideNotification is sent
    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @objc func login() {
        if(self.textFieldUserID.text?.isEmpty == true){
             self.textFieldUserID.becomeFirstResponder()
        }else if (self.textFieldUserKey.text?.isEmpty == true){
             self.textFieldUserKey.becomeFirstResponder()
        }else if (self.textFieldName.text?.isEmpty == true){
            self.textFieldName.becomeFirstResponder()
        }else{
            
            QiscusCore.loginOrRegister(userID: self.textFieldUserID.text!, userKey: self.textFieldUserKey.text!, username: self.textFieldName.text!, avatarURL: nil, extras: nil, onSuccess: { (user) in
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.auth()
            }) { (error) in
                let alert = UIAlertController(title: "Failed to Login?", message: String(describing: error.message), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Try Again", style: .cancel, handler: nil))
                
                self.present(alert, animated: true)
            }
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.textFieldName.setBottomColorGrey()
        self.textFieldUserID.setBottomColorGrey()
        self.textFieldUserKey.setBottomColorGrey()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(textField == self.textFieldUserID){
            self.textFieldUserID.setBottomGreen()
            self.textFieldUserKey.setBottomColorGrey()
            self.textFieldName.setBottomColorGrey()
        }else if(textField == self.textFieldUserKey){
            self.textFieldUserKey.setBottomGreen()
            self.textFieldUserID.setBottomColorGrey()
            self.textFieldName.setBottomColorGrey()
        }else {
            self.textFieldName.setBottomGreen()
            self.textFieldUserID.setBottomColorGrey()
            self.textFieldUserKey.setBottomColorGrey()
        }
    }
    
}



