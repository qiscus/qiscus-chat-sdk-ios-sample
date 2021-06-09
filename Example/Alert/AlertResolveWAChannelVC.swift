//
//  AlertResolveWAChannelVC.swift
//  Example
//
//  Created by Qiscus on 07/06/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit


protocol AlertResolveWAChannelDelegate{
    func actionResolve()
    func actionDismiss()
}

class AlertResolveWAChannelVC: UIViewController {

    @IBOutlet weak var heightViewConst: NSLayoutConstraint!
    @IBOutlet weak var viewPopup: UIView!
    @IBOutlet weak var lbSubtitle: UILabel!
    @IBOutlet weak var buttonResolve: UIButton!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var buttonCancel: UIButton!
    var delegate : AlertResolveWAChannelDelegate? = nil
    var queque = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewPopup.layer.cornerRadius = 8
        self.buttonResolve.layer.cornerRadius = self.buttonResolve.frame.height / 2
        
        if queque == 0 {
            self.lbTitle.text = "Resolve this channel"
            self.lbSubtitle.text = "Are you want to resolve this channel?"
            self.heightViewConst.constant = 350
        }else{
            self.lbTitle.text = "Resolve another channel"
            self.lbSubtitle.text = "The resolving process of the previous channel is still ongoing, your request to resolve this channel will be put on the waiting list. proceed to waiting list?"
            self.heightViewConst.constant = 390
        }
    }
    
    @IBAction func actionResolve(_ sender: Any) {
        self.dismiss(animated: false) {
            if let delegate = self.delegate {
                delegate.actionResolve()
            }
        }
    }
    
    @IBAction func actionCancel(_ sender: Any) {
        self.dismiss(animated: false) {
            if let delegate = self.delegate {
                delegate.actionDismiss()
            }
        }
    }
    
    @IBAction func actionCancelPopup(_ sender: Any) {
        self.dismiss(animated: false) {
            if let delegate = self.delegate {
                delegate.actionDismiss()
            }
        }
    }

}
