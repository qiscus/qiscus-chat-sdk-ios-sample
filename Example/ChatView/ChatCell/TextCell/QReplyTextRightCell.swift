//
//  QTextRightCell.swift
//  Qiscus
//
//  Created by arief nur putranto on 04/09/18.
//

import UIKit

import QiscusCore

class QReplyTextRightCell: UIBaseChatCell {

    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var tvContent: UILabel!
    @IBOutlet weak var ivBaloonLeft: UIImageView!
    
    @IBOutlet weak var ivStatus: UIImageView!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var lbNameHeight: NSLayoutConstraint!
    @IBOutlet weak var lbNameLeading: NSLayoutConstraint!
    @IBOutlet weak var lbNameTrailing: NSLayoutConstraint!
    
    @IBOutlet weak var lbReplyName: UILabel!
    @IBOutlet weak var tvReplyContent: UILabel!
    var isQiscus : Bool = false
    var menuConfig = enableMenuConfig()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setMenu(isQiscus: isQiscus)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
         self.setMenu(isQiscus: isQiscus)
        // Configure the view for the selected state
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
        
        self.lbTime.text = self.hour(date: message.date())
        self.tvContent.text = message.message
        self.tvContent.textColor = ColorConfiguration.rightBaloonTextColor
        
        
        if let messageReply = message.payload?["replied_comment_message"] as? String {
            if messageReply.contains("This message was sent on previous session") == true {
                let messageALLArr = messageReply.components(separatedBy: "This message was sent on previous session")
                let message = messageALLArr[0]
                self.tvReplyContent.text = message
            }else{
                self.tvReplyContent.text = messageReply
            }
        }else{
           self.tvReplyContent.text = "unknow"
        }
        
        if let senderReply = message.payload?["replied_comment_sender_username"] as? String {
             self.lbReplyName.text = senderReply
        }else{
            self.lbReplyName.text = ""
        }
    }
    
    func setupBalon(message : CommentModel){
        //self.ivBaloonLeft.applyShadow()
        self.ivBaloonLeft.image = self.getBallon()
        if message.isMyComment() {
            self.lbNameHeight.constant = 0
            self.ivBaloonLeft.tintColor = ColorConfiguration.rightBaloonColor
        } else {
            self.lbNameHeight.constant = 20
            self.lbName.text = message.username
            self.lbName.textColor = ColorConfiguration.otherAgentRightBallonColor
            self.ivBaloonLeft.tintColor = ColorConfiguration.otherAgentRightBallonColor
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
