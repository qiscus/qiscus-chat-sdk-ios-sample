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
    
    func loadDataMessage(data : RoomModel){
        if data.lastComment?.message.contains("Message failed to send because more than 24 hours") == true{
            self.showExpired()
        }else{
            if let comments = QiscusCore.database.comment.find(roomId: data.id) {
                if comments.count <= 1 {
                    QiscusCore.shared.getChatRoomWithMessages(roomId: data.id) { (room, comments) in
                        self.loadDataMessage(data: data)
                    } onError: { (error) in
                        
                    }

                }else{
                    let commentsFilterCustomer = comments.filter{ $0.username.lowercased() == data.name.lowercased() }
                    if let commentLast = commentsFilterCustomer.first{
                        
                        let diff = commentLast.date.differentTime()
                        if  diff >= 16 && diff <= 23 {
                            self.showExpire()
                        } else if diff >= 16  {
                            self.showExpired()
                        } else {
                            self.hideExpiredOrExpire()
                        }
                    } else {
                        var customerEmail = ""
                        //check again, maybe roomName was changed
                        if let participants = data.participants {
                            for participant in participants.enumerated(){
                                if participant.element.extras != nil {
                                    let dataJson = JSON(participant.element.extras)
                                    let customer = dataJson["is_customer"].bool ?? false
                                    if customer == true {
                                        customerEmail = participant.element.email
                                    }
                                }
                            }
                            
                            let commentsFilterCustomer = comments.filter{ $0.userEmail.lowercased() == customerEmail.lowercased() }
                            if let commentLast = commentsFilterCustomer.first{
                                
                                let diff = commentLast.date.differentTime()
                                if  diff >= 16 && diff <= 23 {
                                    self.showExpire()
                                } else if diff >= 16  {
                                    self.showExpired()
                                } else {
                                    self.hideExpiredOrExpire()
                                }
                            }else{
                                self.hideExpiredOrExpire()
                            }
                            
                        }else{
                            self.hideExpiredOrExpire()
                        }
                    }
                }
            } else {
                self.hideExpiredOrExpire()
            }
        }
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
                    if let comment = QiscusCore.database.comment.find(roomId: data.id){
                        self.loadDataMessage(data : data)
                    } else {
                        self.ivWaMessageExpired.isHidden = true
                    }
                }else if channelType.lowercased() == "twitter"{
                    self.ivTypeChannel.image = UIImage(named: "ic_qiscus")
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
        if lastComment.type == "" || lastComment.type == "file_attachment"{
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
            } else if diff >= 16  {
                self.showExpired()
            } else {
                self.hideExpiredOrExpire()
            }
        }else if channelType.lowercased() == "twitter"{
            self.ivTypeChannel.image = UIImage(named: "ic_qiscus")
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
        
        if let userType = UserDefaults.standard.getUserType(){
            if userType == 2 {
                self.hiddenBadge()
            }else{
                self.hiddenBadge()
            }
        }else{
            self.hiddenBadge()
        }
        var message = ""
        if let room = QiscusCore.database.room.find(id: data.roomId){
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
        }
        
    }
    
    func hiddenBadge(){
        self.viewBadge.isHidden     = true
        self.badgeWitdh.constant    = 0
        self.labelBadge.isHidden    = true
    }
    
    func showBadge(){
        self.viewBadge.isHidden     = false
        self.labelBadge.isHidden    = false
        self.badgeWitdh.constant    = 25
    }
    
}
