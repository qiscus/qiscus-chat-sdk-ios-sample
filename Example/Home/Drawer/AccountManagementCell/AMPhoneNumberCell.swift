//
//  AMPhoneNumberCell.swift
//  Example
//
//  Created by Qiscus on 09/02/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit

class AMPhoneNumberCell: UITableViewCell {

    @IBOutlet weak var lbNotifEmptyPhoneNumber: UILabel!
    @IBOutlet weak var tfPhoneNumber: UITextField!
    var dataPhoneNumber = ""
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        var bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: tfPhoneNumber.frame.height - 1, width: tfPhoneNumber.frame.width, height: 1.0)
        bottomLine.backgroundColor = UIColor.lightGray.cgColor
        tfPhoneNumber.borderStyle = UITextField.BorderStyle.none
        tfPhoneNumber.layer.addSublayer(bottomLine)
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(updateUI), name: Notification.Name("AMPhoneNumberChanged"), object: nil)
        
        self.tfPhoneNumber.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupData(phoneNumber : String = ""){
        if dataPhoneNumber.isEmpty == true {
            self.dataPhoneNumber = phoneNumber
            self.tfPhoneNumber.text = phoneNumber
        }
        
    }
    
    @objc func updateUI(){
        if self.tfPhoneNumber.text?.isEmpty == true {
            self.lbNotifEmptyPhoneNumber.isHidden = false
        } else {
            self.lbNotifEmptyPhoneNumber.isHidden = true
        }
    }
    
}

extension AMPhoneNumberCell : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
       
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
       
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
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { () -> Void in
            if self.tfPhoneNumber.text?.isEmpty == false {
                self.lbNotifEmptyPhoneNumber.isHidden = true
            }
        }
        
        return true;
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
}

