//
//  AlertFailedSubmitTicket.swift
//  Example
//
//  Created by Qiscus on 01/11/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit

class AlertFailedSubmitTicket: UIViewController {
    @IBOutlet weak var viewPopup: UIView!
    @IBOutlet weak var buttonOk: UIButton!
    @IBOutlet weak var label: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewPopup.layer.cornerRadius = 8
        self.buttonOk.layer.cornerRadius = self.buttonOk.frame.height / 2
    }
    
    @IBAction func actionOK(_ sender: Any) {
        self.dismiss(animated: false) {
            
        }
    }

}
