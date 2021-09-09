//
//  QTextRightCell.swift
//  Qiscus
//
//  Created by asharijuang on 04/09/18.
//

import UIKit
import SwiftyJSON
import QiscusCore

class QTextRightCell: UIBaseChatCell {

    @IBOutlet weak var lbName: UILabel!
//    @IBOutlet weak var tvContent: UILabel!
    @IBOutlet weak var tvContent: UITextView!
    @IBOutlet weak var ivBaloonLeft: UIImageView!
    
    @IBOutlet weak var ivStatus: UIImageView!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var lbNameHeight: NSLayoutConstraint!
    @IBOutlet weak var lbNameLeading: NSLayoutConstraint!
    @IBOutlet weak var lbNameTrailing: NSLayoutConstraint!
    var menuConfig = enableMenuConfig()
    var isQiscus : Bool = false
    var message: CommentModel? = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setMenu(isQiscus: isQiscus)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleMassage(_:)),
                                               name: Notification.Name("selectedCell"),
                                               object: nil)
    }
    
    @objc func handleMassage(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let json = JSON(userInfo)
            let commentId = json["commentId"].string ?? "0"
            if let message = self.message {
                if message.id == commentId{
                    self.contentView.backgroundColor = UIColor(red:39/255, green:177/255, blue:153/255, alpha: 0.1)
                }
            }
        }
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
        self.contentView.backgroundColor = UIColor.clear
        self.message = message
        self.setupBalon(message: message)
        self.status(message: message)
        
        self.lbTime.text = self.hour(date: message.date())
        
        self.tvContent.textColor = ColorConfiguration.rightBaloonTextColor
        
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
                
                self.tvContent.attributedText = attributedString
            }else{
                self.tvContent.text = message.message
            }
        }else{
            self.tvContent.text = message.message
        }
        
    }
    
    func setupBalon(message : CommentModel){
        //self.ivBaloonLeft.applyShadow()
        self.ivBaloonLeft.image = self.getBallon()
        if message.isMyComment() {
            self.lbNameHeight.constant = 0
            if message.message.contains("This message was sent on previous session") == true {
                self.ivBaloonLeft.tintColor = ColorConfiguration.rightLeftBaloonGreyColor
            } else {
                self.ivBaloonLeft.tintColor = ColorConfiguration.rightBaloonColor
            }
           
        } else {
            self.lbNameHeight.constant = 20
            self.lbName.text = message.username
            if message.message.contains("This message was sent on previous session") == true {
                self.ivBaloonLeft.tintColor = ColorConfiguration.rightLeftBaloonGreyColor
                self.lbName.textColor = ColorConfiguration.rightLeftBaloonGreyColor
            }else{
                self.lbName.textColor = ColorConfiguration.otherAgentRightBallonColor
                self.ivBaloonLeft.tintColor = ColorConfiguration.otherAgentRightBallonColor
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

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
