//
//  AlertAvailabilityAgent.swift
//  Example
//
//  Created by Qiscus on 14/12/20.
//  Copyright © 2020 Qiscus. All rights reserved.
//

import UIKit

class AlertAvailabilityAgent: UIViewController {

    @IBOutlet weak var viewPopup: UIView!
    @IBOutlet weak var buttonOk: UIButton!
    @IBOutlet weak var lbSubstitle: UILabel!
    @IBOutlet weak var lbTitle: UILabel!
    var isAvailable : Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewPopup.layer.cornerRadius = 8
        self.buttonOk.layer.cornerRadius = self.buttonOk.frame.height / 2
        
        if isAvailable == true {
            self.lbTitle.text = "Agent Status : Available"
            self.lbSubstitle.text = "Your status is now changed to available"
        } else {
            self.lbTitle.text = "Agent Status : Not Available"
            self.lbSubstitle.text = "Your status is now changed to not available"
        }
        
        
    }

    @IBAction func actionOK(_ sender: Any) {
        self.dismiss(animated: false) {
            
        }
    }

}
