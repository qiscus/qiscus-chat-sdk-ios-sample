//
//  AvailabilityAgentCell.swift
//  Example
//
//  Created by Qiscus on 13/12/20.
//  Copyright © 2020 Qiscus. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AvailabilityAgentCell: UITableViewCell {

    @IBOutlet weak var switchUI: UISwitch!
    @IBOutlet weak var lbOfflineOnline: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func didChange(_ sender: UISwitch) {
        self.changeOnlineOffline(isAvailable: sender.isOn)
    }
    
    func getProfileInfo(){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v1/agent/get_profile", method: .get, parameters: nil, headers: header as! HTTPHeaders).responseJSON { (response) in
            print("response call \(response)")
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //failed
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.getProfileInfo()
                            } else {
                                return
                            }
                        }
                    }
                } else {
                    //success
                    let json = JSON(response.result.value)
                    print("response.result.value =\(json)")
                    var data = json["data"]["is_available"].bool ?? false
                    
                    self.switchUI.setOn(data, animated: true)
                    
                    if data == true {
                        self.lbOfflineOnline.text = "Online"
                    } else {
                        self.lbOfflineOnline.text = "Offline"
                    }
                    
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
            } else {
                //failed
            }
        }
    }
    
    func changeOnlineOffline(isAvailable : Bool){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        
        var param: [String: Any] = [
            "is_available": isAvailable
        ]
        
        
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v1/set_availability", method: .post, parameters: param, encoding: JSONEncoding.default, headers: header as! HTTPHeaders).responseJSON { (response) in
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //error
                    
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.changeOnlineOffline(isAvailable: isAvailable)
                            } else {
                                return
                            }
                        }
                    }
                    
                } else {
                    //success
                    
                    
                    self.switchUI.setOn(isAvailable, animated: true)
                    if isAvailable == true {
                        self.lbOfflineOnline.text = "Online"
                        
                    } else {
                        self.lbOfflineOnline.text = "Offline"
                    }
                    
                    if RDNavigationDrawer.isOpen == true {
                         RDNavigationDrawer.sideToggle()
                    }
                   
                    
                    let vc = AlertAvailabilityAgent()
                    vc.modalPresentationStyle = .overFullScreen
                    vc.isAvailable = isAvailable
                    
                    self.currentViewController()?.navigationController?.present(vc, animated: false, completion: {
                        
                    })
                    
                    
                    
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
                if isAvailable == true {
                    self.switchUI.setOn(isAvailable, animated: true)
                    self.lbOfflineOnline.text = "Online"
                } else {
                    self.switchUI.setOn(false, animated: true)
                     self.lbOfflineOnline.text = "Offline"
                }
            } else {
                //failed
               if isAvailable == true {
                    self.switchUI.setOn(isAvailable, animated: true)
                    self.lbOfflineOnline.text = "Online"
               } else {
                    self.switchUI.setOn(false, animated: true)
                    self.lbOfflineOnline.text = "Offline"
               }
            }
        }
    }
    
    func currentViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return currentViewController(base: nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController {
            let moreNavigationController = tab.moreNavigationController
            
            if let top = moreNavigationController.topViewController, top.view.window != nil {
                return currentViewController(base: top)
            } else if let selected = tab.selectedViewController {
                return currentViewController(base: selected)
            }
        }
        
        if let presented = base?.presentedViewController {
            return currentViewController(base: presented)
        }
        
        return base
    }
    
}
