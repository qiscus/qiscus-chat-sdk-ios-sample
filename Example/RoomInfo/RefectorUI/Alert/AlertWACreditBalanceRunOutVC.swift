//
//  AlertWACreditBalanceRunOutVC.swift
//  Example
//
//  Created by arief nur putranto on 29/12/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit

class AlertWACreditBalanceRunOutVC: UIViewController {

    @IBOutlet weak var viewAlert: UIView!
    @IBOutlet weak var btClose: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewAlert.layer.cornerRadius = 8
        self.btClose.layer.cornerRadius = self.btClose.layer.frame.height / 2
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true) {
            
        }
    }
}
