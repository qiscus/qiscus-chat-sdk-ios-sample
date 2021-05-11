//
//  UIChatListViewCell.swift
//  QiscusUI
//
//  Created by Qiscus on 30/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import UIKit
import QiscusCore
import AlamofireImage
import SwiftyJSON
import Alamofire

class UIChatListViewCell: UITableViewCell {

    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    var data : RoomModel? = nil
    var dataCustomerRoom : CustomerRoom? = nil
    static var identifier: String {
        return String(describing: self)
    }
    @IBOutlet weak var badgeWitdh: NSLayoutConstraint!
    
    @IBOutlet weak var viewBadge: UIView!
    @IBOutlet weak var viewNewUnreadCount: UIView!
    @IBOutlet weak var imageViewPinRoom: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelLastMessage: UILabel!
    @IBOutlet weak var imageViewRoom: UIImageView!
    @IBOutlet weak var labelDate: UILabel!
    
    @IBOutlet weak var labelBadge: UILabel!
    
    @IBOutlet weak var ic_isResolved: UIImageView!
    @IBOutlet weak var ivTypeChannel: UIImageView!
    @IBOutlet weak var ivWaMessageExpired: UIImageView!
    @IBOutlet weak var ivBot: UIImageView!
    var lastMessageCreateAt:String{
        get{
            guard let comment = data?.lastComment else { return "" }
            let createAt = comment.unixTimestamp
            if createAt == 0 {
                return ""
            }else{
                var result = ""
                let date = Date(timeIntervalSince1970: Double(createAt/1000000000))
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "d/MM"
                dateFormatter.timeZone = .current
                let dateString = dateFormatter.string(from: date)
                
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "h:mm a"
                timeFormatter.timeZone = .current
                let timeString = timeFormatter.string(from: date)
                
                if Calendar.current.isDateInToday(date){
                    result = "Today, \(timeString)"
                }else if Calendar.current.isDateInYesterday(date) {
                    result = "Yesterday, \(timeString)"
                }else{
                    result = "\(dateString), \(timeString)"
                }
                
                return result
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        labelLastMessage.sizeToFit()
        imageViewRoom.layer.cornerRadius = imageViewRoom.frame.width/2
        self.viewBadge.layer.cornerRadius = self.viewBadge.frame.width/2
        
        self.viewNewUnreadCount.layer.cornerRadius = self.viewNewUnreadCount.frame.width/2
        self.layoutIfNeeded()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func showExpired(){
        self.ivWaMessageExpired.image = UIImage(named: "ic_wa_message_expired")
        self.ivWaMessageExpired.isHidden = false
    }
    
    func showExpire(){
        self.ivWaMessageExpired.image = UIImage(named: "ic_wa_message_expired_in")
        self.ivWaMessageExpired.isHidden = false
    }
    
    func hideExpiredOrExpire(){
        self.ivWaMessageExpired.image = UIImage(named: "ic_wa_message_expired")
        self.ivWaMessageExpired.isHidden = true
    }
    

    func setupUI(data : RoomModel) {
    self.data = data
       if let option = data.options {
            if !option.isEmpty{
                self.ivWaMessageExpired.isHidden = true
                let json = JSON.init(parseJSON: option)
                let channelType = json["channel"].string ?? "qiscus"
                let is_resolved = json["is_resolved"].bool ?? false
                let is_handled_by_bot = json["is_handled_by_bot"].bool ?? false
                if channelType.lowercased() == "qiscus"{
                    self.ivTypeChannel.image = UIImage(named: "ic_qiscus")
                }else if channelType.lowercased() == "telegram"{
                    self.ivTypeChannel.image = UIImage(named: "ic_telegram")
                }else if channelType.lowercased() == "line"{
                    self.ivTypeChannel.image = UIImage(named: "ic_line")
                }else if channelType.lowercased() == "fb"{
                    self.ivTypeChannel.image = UIImage(named: "ic_fb")
                }else if channelType.lowercased() == "wa"{
                    self.ivTypeChannel.image = UIImage(named: "ic_wa")
                    
                    if var room = QiscusCore.database.room.find(id: data.id){
                        if var option = room.options{
                            if !option.isEmpty{
                                var json = JSON.init(parseJSON: option)
                                let lastCustommerTimestamp = json["last_customer_message_timestamp"].string ?? ""
                                
                                if lastCustommerTimestamp.isEmpty == true {
                                    guard let token = UserDefaults.standard.getAuthenticationToken() else {
                                        return
                                    }
                                    
                                    let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
                                    Alamofire.request("\(QiscusHelper.getBaseURL())/api/v2/customer_rooms/\(room.id)", method: .get, parameters: nil, headers: header as! HTTPHeaders).responseJSON { (response) in
                                        if response.result.value != nil {
                                            if (response.response?.statusCode)! >= 300 {
                                                //error
                                                
                                                if response.response?.statusCode == 401 {
                                                    RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                                                        if success == true {
                                                            self.setupUI(data: data)
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
                                                    self.showExpire()
                                                } else if diff >= 24  {
                                                    self.showExpired()
                                                } else {
                                                    self.hideExpiredOrExpire()
                                                }
                                                
                                            }
                                        } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                                            //failed
                                            self.hideExpiredOrExpire()
                                        } else {
                                            //failed
                                            self.hideExpiredOrExpire()
                                        }
                                    }
                                }else{
                                    let date = self.getDate(timestamp: lastCustommerTimestamp)
                                    let diff = date.differentTime()

                                    if  diff >= 16 && diff <= 23 {
                                        self.showExpire()
                                    } else if diff >= 24  {
                                        self.showExpired()
                                    } else {
                                        self.hideExpiredOrExpire()
                                    }
                                    
                                }
                            }
                        }
                    }
                }else if channelType.lowercased() == "twitter"{
                    self.ivTypeChannel.image = UIImage(named: "ic_custom_channel")
                }else if channelType.lowercased() == "custom"{
                    self.ivTypeChannel.image = UIImage(named: "ic_custom_channel")
                }else{
                    self.ivTypeChannel.image = UIImage(named: "ic_custom_channel")
                }
                
                
                if is_resolved == true {
                    self.ic_isResolved.isHidden = false
                }else{
                    self.ic_isResolved.isHidden = true
                }
                
                if is_handled_by_bot == true {
                    self.ivBot.isHidden = false
                }else{
                    self.ivBot.isHidden = true
                }
            }
       }else{
            self.ivWaMessageExpired.isHidden = true
       }
        
        
        if !data.name.isEmpty {
            self.labelName.text = data.name
        }else { self.labelName.text = "Room" }
        self.labelDate.text = lastMessageCreateAt
        
        
        
        if(data.unreadCount == 0){
            self.hiddenBadge()
        }else{
            self.showBadge()
            self.labelBadge.text = "\(data.unreadCount)"
        }
        
        var message = ""
        guard let lastComment = data.lastComment else { return }
        if lastComment.type == "" || lastComment.type == "file_attachment" || lastComment.message.hasPrefix("[file]"){
            message = "Send File Attachment"
        } else if lastComment.type == "text" && lastComment.message.hasPrefix("[sticker]") == true{
            message = "Send Sticker"
        } else {
            message = lastComment.message
        }
        if(data.type != .single){
            self.labelLastMessage.text  =  "\(lastComment.username) :\n\(message)"
        }else{
            self.labelLastMessage.text  = message // single
        }
        
        if let avatar = data.avatarUrl {
            if avatar.absoluteString.contains("https://image.flaticon.com/icons/svg/145/145867.svg") == true{
                self.imageViewRoom.af_setImage(withURL: URL(string:"https://d1edrlpyc25xu0.cloudfront.net/ziv-nqsjtf0zdqf6kfk7s/image/upload/w_320,h_320,c_limit/r7byw7m9e4/default-wa.png")!)
               
            }else if avatar.absoluteString.contains(".png") == true || avatar.absoluteString.contains(".jpg") == true || avatar.absoluteString.contains(".jpeg") == true{
                self.imageViewRoom.af_setImage(withURL: avatar)
            }else{
                self.imageViewRoom.af_setImage(withURL: avatar ?? URL(string:"https://")!)
            }
        }else{
            self.imageViewRoom.af_setImage(withURL: URL(string:"https://")!)
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
    
    func setupUICustomerRoom(data : CustomerRoom) {
        self.dataCustomerRoom = data
        self.hideExpiredOrExpire()
        let channelType = data.source
        let is_resolved = data.isResolved
        let is_handled_by_bot = data.isHandledByBot
        if channelType.lowercased() == "qiscus"{
            self.ivTypeChannel.image = UIImage(named: "ic_qiscus")
        }else if channelType.lowercased() == "telegram"{
            self.ivTypeChannel.image = UIImage(named: "ic_telegram")
        }else if channelType.lowercased() == "line"{
            self.ivTypeChannel.image = UIImage(named: "ic_line")
        }else if channelType.lowercased() == "fb"{
            self.ivTypeChannel.image = UIImage(named: "ic_fb")
        }else if channelType.lowercased() == "wa"{
            self.ivTypeChannel.image = UIImage(named: "ic_wa")
            
            let date = self.getDate(timestamp: data.lastCustomerTimestamp)
            let diff = date.differentTime()

            if  diff >= 16 && diff <= 23 {
                self.showExpire()
            } else if diff >= 24  {
                self.showExpired()
            } else {
                self.hideExpiredOrExpire()
            }
        }else if channelType.lowercased() == "twitter"{
            self.ivTypeChannel.image = UIImage(named: "ic_custom_channel")
        }else if channelType.lowercased() == "custom"{
            self.ivTypeChannel.image = UIImage(named: "ic_custom_channel")
        }else{
            self.ivTypeChannel.image = UIImage(named: "ic_custom_channel")
        }
        
        
        if is_resolved == true {
            self.ic_isResolved.isHidden = false
        }else{
            self.ic_isResolved.isHidden = true
        }
        
        if is_handled_by_bot == true {
            self.ivBot.isHidden = false
        }else{
            self.ivBot.isHidden = true
        }
        
        self.labelName.text = data.name
        
        self.labelDate.text = data.lastCommentTimestamp
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"
        dateFormatter.timeZone = .current
        if let date = dateFormatter.date(from: data.lastCommentTimestamp) {
            let dateFormatter2 = DateFormatter()
            dateFormatter2.dateFormat = "d/MM"
            let dateString = dateFormatter2.string(from: date)
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            let timeString = timeFormatter.string(from: date)
            
            var result = ""
            
            if Calendar.current.isDateInToday(date){
                result = "Today, \(timeString)"
            }
            else if Calendar.current.isDateInYesterday(date) {
                result = "Yesterday, \(timeString)"
            }else{
                result = "\(dateString), \(timeString)"
            }
            
            
            self.labelDate.text = result
        }else{
            self.labelDate.text = ""
        }
       
        
        
        if let avatar = data.avatarUrl {
            if avatar.contains("https://image.flaticon.com/icons/svg/145/145867.svg") == true{
                self.imageViewRoom.af_setImage(withURL: URL(string:"https://d1edrlpyc25xu0.cloudfront.net/ziv-nqsjtf0zdqf6kfk7s/image/upload/w_320,h_320,c_limit/r7byw7m9e4/default-wa.png")!)
               
            }else if avatar.contains(".png") == true || avatar.contains(".jpg") == true || avatar.contains(".jpeg") == true{
                self.imageViewRoom.af_setImage(withURL: URL(string: avatar)!)
            }else{
                self.imageViewRoom.af_setImage(withURL: URL(string: avatar) ?? URL(string:"https://")!)
            }
        }else{
            self.imageViewRoom.af_setImage(withURL: URL(string:"https://")!)
        }
        
        var message = ""
        if let room = QiscusCore.database.room.find(id: data.roomId){
            if(room.unreadCount == 0){
//                if let lastComment = room.lastComment{
//                    if !lastComment.isMyComment() && lastComment.status != .read && data.lastCustomerTimestamp == data.lastCommentTimestamp{
//                        self.showBadge()
//                    }else{
//                        self.hiddenBadge()
//                    }
//                }else{
//                    self.hiddenBadge()
//                }
                self.hiddenBadge()
            }else{
                self.showBadge()
            }
            
            if let lastComment = room.lastComment{
                if lastComment.message.hasPrefix("[file]"){
                    message = "Send File Attachment"
                } else if lastComment.message.hasPrefix("[sticker]") == true{
                    message = "Send Sticker"
                } else {
                    message = lastComment.message
                }
                
                if(room.type != .single){
                    self.labelLastMessage.text  =  "\(lastComment.username) :\n\(message)"
                }else{
                    self.labelLastMessage.text  = message // single
                }
            }else{
                let lastComment = data.lastComment
              
                if lastComment.hasPrefix("[file]"){
                    message = "Send File Attachment"
                } else if lastComment.hasPrefix("[sticker]") == true{
                    message = "Send Sticker"
                } else {
                    message = lastComment
                }
                self.labelLastMessage.text  = message
            }
            
        } else {
            let lastComment = data.lastComment
          
            if lastComment.hasPrefix("[file]"){
                message = "Send File Attachment"
            } else if lastComment.hasPrefix("[sticker]") == true{
                message = "Send Sticker"
            } else {
                message = lastComment
            }
            self.labelLastMessage.text  = message
            self.hiddenBadge()
        }
        
    }
    
    func hiddenBadge(){
        self.viewNewUnreadCount.isHidden = true
    }
    
    func showBadge(){
        self.viewNewUnreadCount.isHidden = false
    }
    
}
