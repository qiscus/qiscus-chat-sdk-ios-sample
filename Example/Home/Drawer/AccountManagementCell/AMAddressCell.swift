//
//  AMAddressCell.swift
//  Example
//
//  Created by Qiscus on 09/02/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit

class AMAddressCell: UITableViewCell {

    @IBOutlet weak var lbNotifEmptyAddress: UILabel!
    @IBOutlet weak var tfAddress: UITextField!
    var dataAddress = ""
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        var bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: tfAddress.frame.height - 1, width: tfAddress.frame.width, height: 1.0)
        bottomLine.backgroundColor = UIColor.lightGray.cgColor
        tfAddress.borderStyle = UITextField.BorderStyle.none
        tfAddress.layer.addSublayer(bottomLine)
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(updateUI), name: Notification.Name("AMAddressChanged"), object: nil)
        
        self.tfAddress.delegate = self
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupData(address : String = ""){
        if dataAddress.isEmpty == true {
            self.dataAddress = address
            self.tfAddress.text = address
        }
    }
    
    @objc func updateUI(){
        if self.tfAddress.text?.isEmpty == true {
            self.lbNotifEmptyAddress.isHidden = false
        } else {
            self.lbNotifEmptyAddress.isHidden = true
        }
    }
    
}

extension AMAddressCell : UITextFieldDelegate {
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
            if self.tfAddress.text?.isEmpty == false {
                self.lbNotifEmptyAddress.isHidden = true
            }
        }
        
        return true;
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
}

