//
//  AlertResolveCancelationWAChannelVC.swift
//  Example
//
//  Created by Qiscus on 08/06/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit

protocol AlertResolveCancelationWAChannelDelegate{
    func actionCancelResolved()
    func actionDismiss()
}

class AlertResolveCancelationWAChannelVC: UIViewController {

    @IBOutlet weak var viewPopup: UIView!
    @IBOutlet weak var buttonResolve: UIButton!
    @IBOutlet weak var buttonCancel: UIButton!
    var delegate : AlertResolveCancelationWAChannelDelegate? = nil
    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewPopup.layer.cornerRadius = 8
        self.buttonResolve.layer.cornerRadius = self.buttonResolve.frame.height / 2
    }
    
    @IBAction func actionCancelResolve(_ sender: Any) {
        self.dismiss(animated: false) {
            if let delegate = self.delegate {
                delegate.actionCancelResolved()
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
