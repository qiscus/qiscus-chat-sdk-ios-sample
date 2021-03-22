//
//  QReplyRightCell.swift
//  Example
//
//  Created by Qiscus on 04/11/20.
//  Copyright © 2020 Qiscus. All rights reserved.
//

import UIKit
import QiscusCore
import SwiftyJSON
import AlamofireImage
import SDWebImage

class QReplyRightCell: UIBaseChatCell {
    @IBOutlet weak var viewReplyPreview: UIView!
    @IBOutlet weak var ivCommentImageWidhtCons: NSLayoutConstraint!
    @IBOutlet weak var lbCommentSender: UILabel!
    @IBOutlet weak var tvCommentContent: UITextView!
    @IBOutlet weak var ivCommentImage: UIImageView!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var lbContent: UILabel!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var ivBaloon: UIImageView!
    @IBOutlet weak var ivStatus: UIImageView!
    @IBOutlet weak var constraintTopMargin: NSLayoutConstraint!
    @IBOutlet weak var lbNameHeight: NSLayoutConstraint!
    var menuConfig = enableMenuConfig()
    var delegateChat: UIChatViewController? = nil
    var isQiscus : Bool = false
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setMenu(isQiscus: isQiscus)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        
        viewReplyPreview.addGestureRecognizer(tap)
        viewReplyPreview.isUserInteractionEnabled = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.setMenu(isQiscus: isQiscus)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        if let delegate = delegateChat {
            guard let replyData = self.comment?.payload else {
                return
            }
            let json = JSON(replyData)
            var commentID = json["replied_comment_id"].int ?? 0
            if commentID != 0 {
                if let comment = QiscusCore.database.comment.find(id: "\(commentID)"){
                    delegate.scrollToComment(comment: comment)
                }
            }
        }
    }
    
    override func present(message: CommentModel) {
        // parsing payload
        self.bindData(message: message)
        
    }
    
    override func update(message: CommentModel) {
        self.bindData(message: message)
    }
    
    func bindData(message: CommentModel){
        self.setupBalon(message: message)
        self.status(message: message)
        
        guard let replyData = message.payload else {
            return
        }
        var text = replyData["replied_comment_message"] as? String
        if text == ""{
            text = "this message has been deleted"
        }
        var replyType = message.replyType(message: text!)
        
        if replyType == .text  {
            switch replyData["replied_comment_type"] as? String {
            case "location":
                replyType = .location
                break
            case "contact_person":
                replyType = .contact
                break
            default:
                break
            }
        }
        var username = replyData["replied_comment_sender_username"] as? String
        let repliedEmail = replyData["replied_comment_sender_email"] as? String
        
        switch replyType {
        case .text:
            self.ivCommentImageWidhtCons.constant = 0
            self.tvCommentContent.text = text
        case .image:
            var filename = message.fileName(text: text!)
            self.tvCommentContent.text = filename
            
            self.ivCommentImage.backgroundColor = #colorLiteral(red: 0.9764705882, green: 0.9764705882, blue: 0.9764705882, alpha: 1)
            
            self.ivCommentImage.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
            self.ivCommentImage.sd_setImage(with: URL(string: message.getAttachmentURL(message: text!)) ?? URL(string: "https://"), placeholderImage: nil, options: .highPriority) { (uiImage, error, cache, urlPath) in
                if urlPath != nil && uiImage != nil{
                    self.ivCommentImage.af_setImage(withURL: urlPath!)
                }
            }
            
        case .video:
            let filename = message.fileName(text: text!)
            self.tvCommentContent.text = filename
            self.ivCommentImage.image = UIImage(named: "ic_file_attachment")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            self.ivCommentImage.tintColor = UIColor.black
        case .audio:
            let filename = message.fileName(text: text!)
            self.tvCommentContent.text = filename
            self.ivCommentImage.image = UIImage(named: "ic_file_attachment")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            self.ivCommentImage.tintColor = UIColor.black
        case .document:
            //pdf
            self.ivCommentImage.image = UIImage(named: "ic_file_attachment")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
           self.ivCommentImage.tintColor = UIColor.black
            let filename = message.fileName(text: text!)
            self.tvCommentContent.text = filename
        case .location:
            self.tvCommentContent.text = text
            self.ivCommentImage.image = UIImage(named: "map_ico")
        case .contact:
            self.tvCommentContent.text = text
            //self.ivCommentImage.image = UIImage(named: "contact")
        case .file:
            var filename = message.fileName(text: text!)
            self.tvCommentContent.text = filename
            self.ivCommentImage.image = UIImage(named: "ic_file_attachment")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            self.ivCommentImage.tintColor = UIColor.black
        case .other:
            self.tvCommentContent.text = text
            self.ivCommentImageWidhtCons.constant = 0
        }
        
        
        if message.message.contains("This message was sent on previous session") == true {
            
            let messageALL = message.message
            let messageALLArr = messageALL.components(separatedBy: "This message was sent on previous session")
            
            if  messageALLArr.count >= 2 {
                let message1 = messageALLArr[0] + "&#x2015;&#x2015;&#x2015;<br/><br/><small>"
                let message1Replace = message1.replacingOccurrences(of: "\n", with: "<br/>", options: .literal, range: nil)
                
                let message2 =  "This message was sent on previous session" + messageALLArr[1]
                let message2Replace = message2.replacingOccurrences(of: "\n", with: "<br/>", options: .literal, range: nil)
                let allMesage = message1Replace + message2Replace
                
                let attributedStringColor = [NSAttributedString.Key.foregroundColor : UIColor.white];
                // create the attributed string
                let attributedString = NSMutableAttributedString(string: allMesage.htmlToString, attributes: attributedStringColor)
                
                if let distance = attributedString.string.distance(of: "This message was sent on previous session") {
                    attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 10), range: NSRange(location: distance , length: attributedString.string.count - distance - 1))
                }
                
                self.lbContent.attributedText = attributedString
            }else{
                self.lbContent.text = message.message
            }
        }else{
            self.lbContent.text = message.message
        }
        
        self.lbTime.text = self.hour(date: message.date())
        self.lbTime.textColor = ColorConfiguration.timeLabelTextColor
        if(message.isMyComment() == true){
            self.lbName.text = "You"
        }else{
            self.lbName.text = message.username
        }
        
        guard let user = QiscusCore.getProfile() else { return }
        if repliedEmail == user.email {
            username = "You"
        }
        self.lbCommentSender.text = username
    }
    
    func setupBalon(message : CommentModel){
        //self.ivBaloon.applyShadow()
        self.ivBaloon.image = self.getBallon()
        self.ivBaloon.tintColor = ColorConfiguration.rightBaloonColor
        //self.ivBaloon.backgroundColor = ColorConfiguration.rightBaloonColor
        self.lbContent.textColor = ColorConfiguration.rightBaloonTextColor
        //self.ivBaloon.layer.cornerRadius = 16
        
        
        guard let payload = message.payload else {
            self.lbNameHeight.constant = 0
            self.ivBaloon.tintColor = ColorConfiguration.rightBaloonColor
            return
        }
        let caption = payload["caption"] as? String
        
        var dataCaption = ""
        if let caption = caption {
            dataCaption = caption
        }
        
        
        if message.isMyComment() {
            self.lbNameHeight.constant = 0
            if dataCaption.contains("This message was sent on previous session") == true {
                self.ivBaloon.tintColor = ColorConfiguration.rightLeftBaloonGreyColor
            } else {
                self.ivBaloon.tintColor = ColorConfiguration.rightBaloonColor
            }
            
        } else {
            self.lbNameHeight.constant = 20
            self.lbName.text = message.username
            if dataCaption.contains("This message was sent on previous session") == true {
                self.ivBaloon.tintColor = ColorConfiguration.rightLeftBaloonGreyColor
                self.lbName.textColor = ColorConfiguration.rightLeftBaloonGreyColor
            }else{
                self.lbName.textColor = ColorConfiguration.otherAgentRightBallonColor
                self.ivBaloon.tintColor = ColorConfiguration.otherAgentRightBallonColor
            }
        }
        
    }
    
    func status(message: CommentModel){
        
        switch message.status {
        case .deleted:
            ivStatus.image = UIImage(named: "ic_deleted")?.withRenderingMode(.alwaysTemplate)
            break
        case .sending, .pending:
            lbTime.textColor = ColorConfiguration.timeLabelTextColor
            ivStatus.tintColor = ColorConfiguration.sentOrDeliveredColor
            lbTime.text = TextConfiguration.sharedInstance.sendingText
            ivStatus.image = UIImage(named: "ic_info_time")?.withRenderingMode(.alwaysTemplate)
            break
        case .sent:
            lbTime.textColor = ColorConfiguration.timeLabelTextColor
            ivStatus.tintColor = ColorConfiguration.sentOrDeliveredColor
            ivStatus.image = UIImage(named: "ic_sending")?.withRenderingMode(.alwaysTemplate)
            break
        case .delivered:
            lbTime.textColor = ColorConfiguration.timeLabelTextColor
            ivStatus.tintColor = ColorConfiguration.sentOrDeliveredColor
            ivStatus.image = UIImage(named: "ic_read")?.withRenderingMode(.alwaysTemplate)
            break
        case .read:
            lbTime.textColor = ColorConfiguration.timeLabelTextColor
            ivStatus.tintColor = ColorConfiguration.readMessageColor
            ivStatus.image = UIImage(named: "ic_read")?.withRenderingMode(.alwaysTemplate)
            break
        case . failed:
            lbTime.textColor = ColorConfiguration.timeLabelTextColor
            lbTime.text = TextConfiguration.sharedInstance.failedText
            ivStatus.image = UIImage(named: "ic_warning")?.withRenderingMode(.alwaysTemplate)
            ivStatus.tintColor = ColorConfiguration.failToSendColor
            break
        case .deleting:
            ivStatus.image = UIImage(named: "ic_deleted")?.withRenderingMode(.alwaysTemplate)
            break
        }
    }
    
    func hour(date: Date?) -> String {
        guard let date = date else {
            return "-"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone      = TimeZone.current
        let defaultTimeZoneStr = formatter.string(from: date);
        return defaultTimeZoneStr
    }
   
}
