//
//  AlertSuccessSubmitTicket.swift
//  Example
//
//  Created by Qiscus on 22/10/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit

class AlertSuccessSubmitTicket: UIViewController {
    @IBOutlet weak var viewPopup: UIView!
    @IBOutlet weak var buttonOk: UIButton!
    @IBOutlet weak var label: UILabel!
    var dataLabel = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewPopup.layer.cornerRadius = 8
        self.buttonOk.layer.cornerRadius = self.buttonOk.frame.height / 2
        self.label.text = dataLabel
    }
    
    @IBAction func actionOK(_ sender: Any) {
        self.dismiss(animated: false) {
            
        }
    }

}
