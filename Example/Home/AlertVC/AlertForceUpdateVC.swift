//
//  AlertForceUpdateVC.swift
//  Example
//
//  Created by Qiscus on 04/08/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit

class AlertForceUpdateVC: UIViewController {

    @IBOutlet weak var viewPopUp: UIView!
    @IBOutlet weak var btRemindMeLater: UIButton!
    @IBOutlet weak var btUpdateNewVersion: UIButton!
    var isForceUpdate = false
    var count = 0
    @IBOutlet weak var btHardClose: UIButton!
    @IBOutlet weak var heightRemindMeLaterConst: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewPopUp.layer.cornerRadius = 8
        self.btUpdateNewVersion.layer.cornerRadius = self.btUpdateNewVersion.frame.height / 2
        
        self.btRemindMeLater.layer.borderWidth = 1
        self.btRemindMeLater.layer.borderColor = ColorConfiguration.defaultColorTosca.cgColor
        self.btRemindMeLater.layer.cornerRadius = self.btRemindMeLater.frame.height / 2
        
        self.btRemindMeLater.isHidden = isForceUpdate
        
        if isForceUpdate == true {
            heightRemindMeLaterConst.constant = 0
        } else {
            heightRemindMeLaterConst.constant = 40
        }
        
        self.btHardClose.setTitle("", for: .normal)
    }

    
    @IBAction func updateNewVersionAction(_ sender: Any) {
        guard let url = URL(string: "https://apps.apple.com/us/app/qiscus-multichannel/id1507748978") else {
          return //be safe
        }

        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
        
    }
    @IBAction func remindMeLaterAction(_ sender: Any) {
        self.dismiss(animated: true) {
            
        }
    }
    
    @IBAction func close(_ sender: Any) {
        count = count + 1
        
        if count == 5 {
            self.dismiss(animated: true) {
                
            }
        }
    }
    
}
