//
//  AlertOnlineOfflineFirstLoginAgent.swift
//  Example
//
//  Created by Qiscus on 08/02/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit

class AlertOnlineOfflineFirstLoginAgent: UIViewController {

    @IBOutlet weak var iconAlertOffline: UIImageView!
    @IBOutlet weak var iconAlertOnline: UIImageView!
    @IBOutlet weak var viewPopupOnline: UIView!
    @IBOutlet weak var buttonOkOnline: UIButton!
    @IBOutlet weak var viewPopupOffline: UIView!
    @IBOutlet weak var buttonOkOffline: UIButton!
    
    var isAvailable : Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isAvailable == true {
            self.viewPopupOnline.isHidden = false
            self.viewPopupOffline.isHidden = true
        }else{
            self.viewPopupOffline.isHidden = false
            self.viewPopupOnline.isHidden = true
        }
    }
    
    func setupUI(){
        self.viewPopupOnline.layer.cornerRadius = 8
        self.buttonOkOnline.layer.cornerRadius = self.buttonOkOnline.frame.height / 2
        
        self.viewPopupOffline.layer.cornerRadius = 8
        self.buttonOkOffline.layer.cornerRadius = self.buttonOkOffline.frame.height / 2
        
        let imageOffline = UIImage(named: "ic_alert")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        iconAlertOffline.image = imageOffline
        iconAlertOffline.tintColor = #colorLiteral(red: 0, green: 0.6941176471, blue: 0.9921568627, alpha: 1)
        
        let imageOnline = UIImage(named: "ic_alert")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        iconAlertOnline.image = imageOnline
        iconAlertOnline.tintColor = #colorLiteral(red: 0, green: 0.6941176471, blue: 0.9921568627, alpha: 1)
    }
    
    @IBAction func actionOKOnline(_ sender: Any) {
        self.dismiss(animated: false) {
            
        }
    }
    
    @IBAction func actionOKOffline(_ sender: Any) {
        self.dismiss(animated: false) {
            
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
