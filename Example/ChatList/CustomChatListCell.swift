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
import QiscusUI
import SwiftyJSON
import SDWebImage

class CustomChatListCell: BaseChatListCell {
    static var nib:UINib {
        return UINib(nibName: identifier, bundle:nil)
    }
    
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
    
    var lastMessageCreateAt:String{
        get{
            guard let comment = data?.lastComment else { return "" }
            let createAt = comment.unixTimestamp
            if createAt == 0 {
                return ""
            }else{
                var result = ""
                
                let date = Date(timeIntervalSince1970: TimeInterval(createAt / 1000000000))
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "d/MM"
                let dateString = dateFormatter.string(from: date)
                
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "h:mm a"
                let timeString = timeFormatter.string(from: date)
                
                if date.isToday{
                    result = "\(timeString)"
                }
                else if date.isYesterday{
                    result = "Yesterday"
                }else{
                    result = "\(dateString)"
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
    
    override func setupUI() {
        
        if let data = data {
            if !data.name.isEmpty {
                self.labelName.text = data.name
            }else { self.labelName.text = "Room" }
            self.labelDate.text = lastMessageCreateAt
            
            if let avatar = data.avatarUrl {
                self.imageViewRoom.af_setImage(withURL: avatar)
            }
            if(data.unreadCount == 0){
                self.hiddenBadge()
            }else{
                self.showBadge()
                self.labelBadge.text = "\(data.unreadCount)"
            }
            
            var message = ""
            guard let lastComment = data.lastComment else { return }
            if lastComment.message.range(of:"[file]") != nil {
                guard let payload = lastComment.payload else { return }
                let json = JSON(payload)
                let caption = json["caption"].string ?? ""
                if  !caption.isEmpty {
                    message = caption
                }else{
                    message = "Send Attachment"
                }
                
            }else{
                message = lastComment.message
            }

            if(data.type != .single){
                let message = "\(lastComment.username) :\n\(message)"
                let senderColor = "\(lastComment.username) :"
                
                let range = (message as NSString).range(of: senderColor)
                
                let attribute = NSMutableAttributedString.init(string: message)
                attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black , range: range)
                
                self.labelLastMessage.attributedText = attribute
            }else{
                self.labelLastMessage.text  = message // single
            }
        }
    }
    
    public func hiddenBadge(){
        self.viewBadge.isHidden     = true
        self.badgeWitdh.constant    = 0
        self.labelBadge.isHidden    = true
    }
    
    public func showBadge(){
        self.viewBadge.isHidden     = false
        self.labelBadge.isHidden    = false
        self.badgeWitdh.constant    = 25
    }
    
}
