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
    var menuConfig = enableMenuConfig()
    var delegateChat: UIChatViewController? = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setMenu()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        
        viewReplyPreview.addGestureRecognizer(tap)
        viewReplyPreview.isUserInteractionEnabled = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.setMenu()
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
        self.setupBalon()
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
            let url = URL(string: message.getAttachmentURL(message: text!))
            self.ivCommentImage.af.setImage(withURL: url ?? URL(string: "http://")!)
            
        case .video:
            self.tvCommentContent.text = text
        case .audio:
            self.tvCommentContent.text = text
        case .document:
            //pdf
          let url = URL(string: message.getAttachmentURL(message: text!))
             
             QiscusCore.shared.getThumbnailURL(url: message.getAttachmentURL(message: text!), onSuccess: { (url) in
                  self.ivCommentImage.af.setImage(withURL: URL(string: url)!)
             }) { (error) in
                 //error
                 self.ivCommentImage.image = UIImage(named: "ic_file")
             }
            
             var filename = message.fileName(text: text!)
        case .location:
            self.tvCommentContent.text = text
            //self.ivCommentImage.image = UIImage(named: "map_ico")
        case .contact:
            self.tvCommentContent.text = text
            //self.ivCommentImage.image = UIImage(named: "contact")
        case .file:
            var filename = message.fileName(text: text!)
            self.tvCommentContent.text = filename
            self.ivCommentImage.image = UIImage(named: "ic_file")
        case .other:
            self.tvCommentContent.text = text
            self.ivCommentImageWidhtCons.constant = 0
        }
        
        
        //let splittedMessage = message.message.components(separatedBy: "\n")
        self.lbContent.text = message.message
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
    
    func setupBalon(){
        //self.ivBaloon.applyShadow()
        self.ivBaloon.image = self.getBallon()
        self.ivBaloon.tintColor = ColorConfiguration.rightBaloonColor
        //self.ivBaloon.backgroundColor = ColorConfiguration.rightBaloonColor
        self.lbContent.textColor = ColorConfiguration.rightBaloonTextColor
        //self.ivBaloon.layer.cornerRadius = 16
        
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
