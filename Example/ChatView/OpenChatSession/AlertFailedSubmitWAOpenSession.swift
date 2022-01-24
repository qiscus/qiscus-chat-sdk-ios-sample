//
//  AlertFailedSubmitWAOpenSession.swift
//  Example
//
//  Created by arief nur putranto on 18/01/22.
//  Copyright © 2022 Qiscus. All rights reserved.
//

import UIKit

class AlertFailedSubmitWAOpenSession: UIViewController {
    @IBOutlet weak var viewPopup: UIView!
    @IBOutlet weak var buttonOk: UIButton!
    @IBOutlet weak var label: UILabel!
    var message = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewPopup.layer.cornerRadius = 8
        self.buttonOk.layer.cornerRadius = self.buttonOk.frame.height / 2
        self.label.text = message
    }
    
    @IBAction func actionOK(_ sender: Any) {
        self.dismiss(animated: false) {
            
        }
    }

}
