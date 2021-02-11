//
//  AlertAMSuccessUpdate.swift
//  Example
//
//  Created by Qiscus on 09/02/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit

class AlertAMSuccessUpdate: UIViewController {
    @IBOutlet weak var viewPopup: UIView!
    @IBOutlet weak var buttonOk: UIButton!
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
