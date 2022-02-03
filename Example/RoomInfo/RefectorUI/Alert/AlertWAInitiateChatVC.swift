//
//  AlertWAInitiateChatVC.swift
//  Example
//
//  Created by arief nur putranto on 29/12/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit
import QiscusCore
import Alamofire
import SwiftyJSON

class AlertWAInitiateChatVC: UIViewController {

    @IBOutlet weak var viewPopup: UIView!
    @IBOutlet weak var btLetMeThinkAgain: UIButton!
    @IBOutlet weak var btContinue: UIButton!
    @IBOutlet weak var lbMessage: UILabel!
    
    var channelID : Int = 0
    var roomID : String = "0"
    
    var message = NSAttributedString()
    var vc : UIChatViewController? = nil
    var isExpired : Bool = false
    var chargeCredits = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.btContinue.layer.cornerRadius = self.btContinue.layer.frame.size.height / 2
        
        self.viewPopup.layer.cornerRadius = 8
        self.lbMessage.attributedText = message
        
        self.getData()
    }

    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true) {
            
        }
    }
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true) {
            
        }
    }
    
    @IBAction func continueAction(_ sender: Any) {
        if self.isExpired == true {
            //go HSM24
            //
            self.dismiss(animated: true) {
                
            }
            
            let vc = OpenChatSessionWAVC()
            vc.chargedCredit = chargeCredits
            vc.channelID = self.channelID
            vc.roomId = self.roomID
            self.vc?.navigationController?.pushViewController(vc, animated: true)
        }else{
            self.vc?.chatInput.hideNoActiveSession()
            self.dismiss(animated: true) {
                
            }
        }
       
    }
    
    func getData(){
        if var room = QiscusCore.database.room.find(id: roomID){
            if var option = room.options{
                if !option.isEmpty{
                    var json = JSON.init(parseJSON: option)
                    let lastCustommerTimestamp = json["last_customer_message_timestamp"].string ?? ""
                    
                    if lastCustommerTimestamp.isEmpty == true {
                        guard let token = UserDefaults.standard.getAuthenticationToken() else {
                            return
                        }
                        
                        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
                        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v2/customer_rooms/\(roomID)", method: .get, parameters: nil, headers: header as! HTTPHeaders).responseJSON { (response) in
                            if response.result.value != nil {
                                if (response.response?.statusCode)! >= 300 {
                                    //error
                                    
                                    if response.response?.statusCode == 401 {
                                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                                            if success == true {
                                                self.getData()
                                            } else {
                                               return
                                            }
                                        }
                                    }
                                } else {
                                    //success
                                    let payload = JSON(response.result.value)
                        
                                    let lastCustomerTimestamp  = payload["data"]["customer_room"]["last_customer_timestamp"].string ??
                                        ""
                                    
                                    var json = JSON.init(parseJSON: option)
                                    json["last_customer_message_timestamp"] = JSON(lastCustomerTimestamp)
                                    
                                    if let rawData = json.rawString() {
                                        let room = room
                                        room.options = rawData
                                        QiscusCore.database.room.save([room])
                                    }
                                    
                                    let date = self.getDate(timestamp: lastCustomerTimestamp)
                                    let diff = date.differentTime()

                                    if  diff >= 16 && diff <= 23 {
                                        //show textField
                                        self.isExpired = false
                                    } else if diff >= 24  {
                                        //show hsm24
                                        self.isExpired = true
                                    } else {
                                        //show textField
                                        self.isExpired = false
                                    }
                                    
                                }
                            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                                //failed
                               
                            } else {
                                //failed
                                
                            }
                        }
                    }else{
                        let date = self.getDate(timestamp: lastCustommerTimestamp)
                        let diff = date.differentTime()

                        
                        if  diff >= 16 && diff <= 23 {
                            //show textField
                            self.isExpired = false
                        } else if diff >= 24  {
                            //show hsm24
                            self.isExpired = true
                        } else {
                            //show textField
                            self.isExpired = false
                        }
                        
                    }
                }
            }
        }
    }
    
    func getDate(timestamp : String) -> Date {
        //let timezone = TimeZone.current.identifier
        let formatter = DateFormatter()
        formatter.dateFormat    = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.timeZone = .current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let date = formatter.date(from: timestamp)
        return date ?? Date()
    }
    
    
}
