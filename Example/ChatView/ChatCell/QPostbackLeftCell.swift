//
//  QPostbackLeftCell.swift
//  Pods
//
//  Created by asharijuang on 18/10/18.
//

import UIKit
import QiscusUI
import QiscusCore
import SwiftyJSON

protocol PostbackCellDelegate {
    func postBackCell(cell:QPostbackLeftCell, didTapAction data:JSON)
}

enum PostbackType : String {
    case accountLinking    = "account_linking"
    case buttons           = "buttons"
}

class QPostbackLeftCell: QUIBaseChatCell {
    let maxWidth:CGFloat = UIConfiguration.chatTextMaxWidth
    let minWidth:CGFloat = UIConfiguration.chatTextMaxWidth
    let buttonWidth:CGFloat = UIConfiguration.chatTextMaxWidth + 10
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var balloonView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var buttonsView: UIStackView!
    
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
//    @IBOutlet weak var textViewWidth: NSLayoutConstraint!
    @IBOutlet weak var buttonsViewHeight: NSLayoutConstraint!
    var delegate : PostbackCellDelegate? = nil
    var type : PostbackType = .accountLinking
    
    override func awakeFromNib() {
        super.awakeFromNib()
       textView.contentInset = UIEdgeInsets.zero
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

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
        self.setupBalon()
        
        balloonView.image = getBallon()
        
        for view in buttonsView.subviews{
            view.removeFromSuperview()
        }
        
        dateLabel.text = self.hour(date: message.date())
        balloonView.tintColor = ColorConfiguration.leftBaloonColor
        //balloonView.tintColor = UIColor.lightGray
        dateLabel.textColor = ColorConfiguration.leftBaloonTextColor

        if self.comment!.type == "buttons" {
            var i = 0
            
            guard let dataPayload = message.payload else {
                return
            }
            let data = JSON(dataPayload)
            
            let message = data["text"].string ?? ""
            
            let attributedText = NSMutableAttributedString(string: message)
            let allRange = (message as NSString).range(of: message)
            attributedText.addAttributes(self.textAttribute, range: allRange)
            
            self.textView.attributedText = attributedText
            self.textView.linkTextAttributes = self.linkTextAttributes
            
            let buttonsPayload = data["buttons"].arrayValue
            self.buttonsViewHeight.constant = CGFloat(buttonsPayload.count * 35)
            self.layoutIfNeeded()
            for buttonsData in buttonsPayload{
                let button = UIButton(frame: CGRect(x: 0, y: 0, width: self.buttonWidth, height: 32))
                button.backgroundColor = ColorConfiguration.postBackButtonColor
                button.setTitle(buttonsData["label"].stringValue, for: .normal)
                button.setTitleColor(.black, for: .normal)
                button.tag = i
                button.addTarget(self, action:#selector(self.postback(sender:)), for: .touchUpInside)
                self.buttonsView.addArrangedSubview(button)
                i += 1
            }
        }else{
            guard let dataPayload = message.payload else {
                return
            }
            
            let data = JSON(dataPayload)
            let paramData = data["params"]

            self.buttonsViewHeight.constant = CGFloat(35)
            self.layoutIfNeeded()

            let button = UIButton(frame: CGRect(x: 0, y: 0, width: self.buttonWidth, height: 32))
            button.backgroundColor = ColorConfiguration.postBackButtonColor
            button.setTitle(paramData["button_text"].stringValue, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.tag = 2222
            button.addTarget(self, action:#selector(self.accountLinking(sender:)), for: .touchUpInside)

            self.buttonsView.addArrangedSubview(button)
        }
    }
    
    func setupBalon(){
        
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
    
    @objc func postback(sender:UIButton){
        guard let dataPayload = self.comment?.payload else {
            return
        }
        let data = JSON(dataPayload)
        let allData =  data["buttons"].arrayValue
        if allData.count > sender.tag {
            self.delegate?.postBackCell(cell: self, didTapAction: allData[sender.tag])
        }
    }
    
    @objc func accountLinking(sender:UIButton){
        guard let dataPayload = self.comment?.payload else {
            return
        }
        let data = JSON(dataPayload)
        self.delegate?.postBackCell(cell: self, didTapAction: data)
    }
}

extension ChatViewController : PostbackCellDelegate {
    func postBackCell(cell: QPostbackLeftCell, didTapAction data: JSON) {
        switch cell.type {
        case .accountLinking:
            let webView = ChatPreviewDocVC()
            webView.accountLinking = true
            webView.accountData = data
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            self.navigationController?.pushViewController(webView, animated: true)
            break
        case .buttons:
            let postbackType = data["type"].stringValue
            let payload = data["payload"]
            switch postbackType {
            case "link":
                let urlString = payload["url"].stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
                let urlArray = urlString.components(separatedBy: "/")
                func openInBrowser(){
                    if let url = URL(string: urlString) {
                        UIApplication.shared.openURL(url)
                    }
                }
                if urlArray.count > 2 {
                    if urlArray[2].lowercased().contains("instagram.com") {
                        var instagram = "instagram://app"
                        if urlArray.count == 4 || (urlArray.count == 5 && urlArray[4] == ""){
                            let usernameIG = urlArray[3]
                            instagram = "instagram://user?username=\(usernameIG)"
                        }
                        if let instagramURL =  URL(string: instagram) {
                            if UIApplication.shared.canOpenURL(instagramURL) {
                                UIApplication.shared.openURL(instagramURL)
                            }else{
                                openInBrowser()
                            }
                        }
                    }else{
                        openInBrowser()
                    }
                }else{
                    openInBrowser()
                }
                break
            default:
                let text = data["label"].stringValue
                let type = "text"
                let comment = CommentModel()
                comment.type = type
                comment.message = text
                comment.payload = payload.dictionaryObject
                self.sendMessage(message: comment)
                break
            }
            break
        }
    }
    
    
}
