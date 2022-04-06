//
//  ListOfHeaderBodyButtonCell.swift
//  Example
//
//  Created by arief nur putranto on 14/03/22.
//  Copyright © 2022 Qiscus. All rights reserved.
//

import UIKit

class ListOfHeaderBodyButtonCell: UITableViewCell {

    @IBOutlet weak var tfHeaderBodyButton: UITextField!
    @IBOutlet weak var viewTF: UIView!
    @IBOutlet weak var lbTitle: UILabel!
    
    var type : Int = 1
    var rowCell : Int = 0
    var vc : NewOpenChatSessionWAVC? = nil
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.viewTF.layer.shadowColor = UIColor(red: 0.412, green: 0.412, blue: 0.412, alpha: 0.15).cgColor
        self.viewTF.layer.shadowOffset = CGSize(width: -3, height: 5)
        self.viewTF.layer.shadowOpacity = 1
        self.viewTF.layer.shadowRadius = 14
        self.viewTF.layer.cornerRadius = 8
        
        //textField
        self.tfHeaderBodyButton.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(ListOfHeaderBodyButtonCell.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ListOfHeaderBodyButtonCell.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    // MARK: - Keyboard Methode
    @objc func keyboardWillHide(_ notification: Notification){
        let info: NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        
        let animateDuration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        self.vc?.bottomTableViewConstant.constant = 0
        UIView.animate(withDuration: animateDuration, delay: 0, options: UIView.AnimationOptions(), animations: {
            self.vc?.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification){
        let info:NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let keyboardSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let keyboardHeight: CGFloat = keyboardSize.height
        let animateDuration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        
        self.vc?.bottomTableViewConstant.constant = 0 + keyboardHeight - 100
        UIView.animate(withDuration: animateDuration, delay: 0, options: UIView.AnimationOptions(), animations: {
            self.vc?.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func setup(type : Int = 1, data : String = "", indexData : Int = 0){
        if type == 1{
            self.tfHeaderBodyButton.placeholder = "Type your header variable"
            self.lbTitle.text = "Header Variable {{\(indexData + 1)}}"
        }else if type == 2 {
            self.tfHeaderBodyButton.placeholder = "Type your body variable"
            self.lbTitle.text = "Body Variable {{\(indexData + 1)}}"
        }else {
            self.tfHeaderBodyButton.placeholder = "Type your button variable"
            self.lbTitle.text = "Button Variable {{\(indexData + 1)}}"
        }
        self.tfHeaderBodyButton.text = data
        self.type = type
        self.rowCell = indexData
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
}

extension ListOfHeaderBodyButtonCell : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text != nil {
            //update data
            if self.type == 1 {
                self.vc?.dataHeader[self.rowCell] = textField.text ?? ""
            }else if self.type == 2{
                self.vc?.dataBody[self.rowCell] = textField.text ?? ""
            }else{
                self.vc?.dataButton[self.rowCell] = textField.text ?? ""
            }
            
            self.vc?.checkDataCanSend()
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true;
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true;
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true;
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        
        return true;
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
}
