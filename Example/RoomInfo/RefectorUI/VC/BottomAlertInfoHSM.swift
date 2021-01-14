//
//  BottomAlertInfoHSM.swift
//  Example
//
//  Created by Qiscus on 07/01/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit
import BottomPopup

class BottomAlertInfoHSM: BottomPopupViewController {
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbSubtitle: UILabel!
    var height: CGFloat?
    var width : CGFloat?
    var topCornerRadius: CGFloat?
    var presentDuration: Double?
    var dismissDuration: Double?
    var shouldDismissInteractivelty: Bool?
    var titleAlertExpired = "Has expired"
    var titleAlertWillExpireSoon = "Will expire soon"
    var subtitleAlertExpired = #"The session has expired since it's over 24-hours after the customer's last message. If you wish to re-initiate a conversation after that time period, you need to send a paid message template. Please click the "Send Message Template" button"#
    var subtitleAlertWillExpireSoon = "After 24-hours since the customer's last message, the session will be expired. You can re-initiate a conversation after that time period with a paid message template."
    var subtitleAlertDisableHSM = "The session has expired since it's over 24-hours after the customer's last message. If you wish to re-initiate a conversation after that time period, you need to send a paid message template."
    var isExpired : Bool = false
    var enableHSM: Bool = true
    @IBOutlet weak var btClose: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        if let width = width {
            self.view.frame.size.width = width
        }
        
        self.btClose.setImage(UIImage(named: "ic_close")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
        self.btClose.tintColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if enableHSM == false{
            self.lbTitle.text = self.titleAlertExpired
            self.lbSubtitle.text = self.subtitleAlertDisableHSM
        }else{
            if isExpired == true {
                self.lbTitle.text = self.titleAlertExpired
                self.lbSubtitle.text = self.subtitleAlertExpired
            } else {
                self.lbTitle.text = self.titleAlertWillExpireSoon
                self.lbSubtitle.text = self.subtitleAlertWillExpireSoon
            }
        }
    }

    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // Bottom popup attribute methods
    // You can override the desired method to change appearance
    
    override func getPopupHeight() -> CGFloat {
        if self.isExpired == true {
            return 210
        } else {
            return 160
        }
    }
    
    override func getPopupTopCornerRadius() -> CGFloat {
        return topCornerRadius ?? CGFloat(10)
    }
    
    override func getPopupPresentDuration() -> Double {
        return presentDuration ?? 1.0
    }
    
    override func getPopupDismissDuration() -> Double {
        return dismissDuration ?? 1.0
    }
    
    override func shouldPopupDismissInteractivelty() -> Bool {
        return shouldDismissInteractivelty ?? true
    }
}
