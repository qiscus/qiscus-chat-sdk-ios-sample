//
//  AlertMenuUploadVC.swift
//  Example
//
//  Created by Qiscus on 10/02/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit
import BottomPopup
import Alamofire
import SwiftyJSON

protocol AlertMenuUploadVCDelegate {
    func openCamera()
    func openGallery()
}

class AlertMenuUploadVC: BottomPopupViewController {
    var width : CGFloat?
    var topCornerRadius: CGFloat?
    var presentDuration: Double?
    var dismissDuration: Double?
    var shouldDismissInteractivelty: Bool?
    
    var delegate : AlertMenuUploadVCDelegate? = nil
    override func viewDidLoad() {
        super.viewDidLoad()

        if let width = width {
            self.view.frame.size.width = width
        }
    }
    @IBAction func cameraAction(_ sender: Any) {
        if let delegateVC = self.delegate {
            delegateVC.openCamera()
            self.dismiss(animated: true) {
                
            }
        }
    }
    @IBAction func galleryAction(_ sender: Any) {
        if let delegateVC = self.delegate {
            delegateVC.openGallery()
            self.dismiss(animated: true) {
                
            }
        }
    }
    
    // Bottom popup attribute methods
    // You can override the desired method to change appearance
    
    override func getPopupHeight() -> CGFloat {
        return 110
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
