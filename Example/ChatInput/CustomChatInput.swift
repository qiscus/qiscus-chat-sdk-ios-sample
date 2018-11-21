//
//  CustomChatInput.swift
//  Example
//
//  Created by Qiscus on 04/09/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import UIKit
import QiscusUI
import QiscusCore
import SwiftyJSON

protocol CustomChatInputDelegate {
    func sendAttachment()
    func sendMessage(message: CommentModel)
}

class CustomChatInput: UIChatInput {
    
    @IBOutlet weak var iconReplyPreviewWidhtCons: NSLayoutConstraint!
    @IBOutlet weak var iconReplyPreview: UIImageView!
    @IBOutlet weak var viewColorReplyPreview: UIView!
    @IBOutlet weak var lbReplyPreviewSenderName: UILabel!
    @IBOutlet weak var lbReplyPreview: UILabel!
    @IBOutlet weak var ivReplyPreviewWidth: NSLayoutConstraint!
    @IBOutlet weak var ivReplyPreview: UIImageView!
    @IBOutlet weak var cancelReplyPreviewButton: UIButton!
    @IBOutlet weak var topReplyPreviewCons: NSLayoutConstraint!
    @IBOutlet weak var replyPreviewCons: NSLayoutConstraint!
    @IBOutlet weak var heightView: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var attachButton: UIButton!
    
    @IBOutlet weak var heightTextViewCons: NSLayoutConstraint!
    @IBOutlet weak var textView: UITextView!
    var delegate : CustomChatInputDelegate? = nil
    var replyData:CommentModel?
    var defaultInputBarHeight: CGFloat = 34.0
    var customInputBarHeight: CGFloat = 34.0
    var colorName : UIColor = UIColor.black
    
    override func commonInit(nib: UINib) {
        let nib = UINib(nibName: "CustomChatInput", bundle: nil)
        super.commonInit(nib: nib)
        textView.delegate = self
        textView.text = TextConfiguration.sharedInstance.textPlaceholder
        textView.textColor = UIColor.lightGray
        textView.font = UIConfiguration.chatFont
        self.textView.layer.cornerRadius = self.textView.frame.size.height / 2
        self.textView.clipsToBounds = true
        self.textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    func showPreviewReply(){
        
        if let data = replyData {
            self.lbReplyPreviewSenderName.text = data.username
            self.lbReplyPreviewSenderName.textColor = colorName
            self.viewColorReplyPreview.backgroundColor = colorName
            self.iconReplyPreviewWidhtCons.constant = 20
            self.ivReplyPreviewWidth.constant = 45
            
            if data.type == "text" {
                self.lbReplyPreview.text = data.message
                self.ivReplyPreviewWidth.constant = 0
                self.iconReplyPreviewWidhtCons.constant = 0
            }else if data.type == "location"{
                let payload = JSON(data.payload)
                let address = payload["address"].stringValue
                self.lbReplyPreview.text = address
                self.iconReplyPreview.image = UIImage(named: "map_ico")
                self.ivReplyPreview.image = UIImage(named: "map_ico")
                self.iconReplyPreviewWidhtCons.constant = 0
            }else if data.type == "contact_person"{
                let payloadJSON = JSON(data.payload)
                self.lbReplyPreview.text = payloadJSON["name"].string ??  payloadJSON["value"].string ?? ""
                self.iconReplyPreview.image = UIImage(named: "contact")
                self.ivReplyPreviewWidth.constant = 0
            }else if data.type == "file_attachment"{
                let replyType = ChatViewController().getType(message: data)
                switch replyType {
                case .image:
                    guard let payload = data.payload else { return }
                    let caption = payload["caption"] as? String
                    self.lbReplyPreview.text = caption
                    if let url = payload["url"] as? String {
                        ivReplyPreview.sd_setShowActivityIndicatorView(true)
                        ivReplyPreview.sd_setIndicatorStyle(.whiteLarge)
                        ivReplyPreview.sd_setImage(with: URL(string: url)!)
                    }
                    
                    self.iconReplyPreview.image = UIImage(named: "ic_image")
                    
                case .video:
                    var filename = data.fileName(text: data.message)
                    self.lbReplyPreview.text = filename
                    self.iconReplyPreview.image = UIImage(named: "ic_videocam")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                    self.iconReplyPreview.tintColor = UIColor.lightGray
                    self.ivReplyPreviewWidth.constant = 0
                case .audio:
                    var filename = data.fileName(text: data.message)
                    self.lbReplyPreview.text = filename
                    self.iconReplyPreview.image = UIImage(named: "ar_record")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                    self.iconReplyPreview.tintColor = UIColor.lightGray
                    self.ivReplyPreviewWidth.constant = 0
                case .document:
                    var filename = data.fileName(text: data.message)
                    self.lbReplyPreview.text = filename
                    self.iconReplyPreview.image = UIImage(named: "ic_file")
                    self.ivReplyPreviewWidth.constant = 0
                case .file:
                    var filename = data.fileName(text: data.message)
                    self.lbReplyPreview.text = filename
                    self.iconReplyPreview.image = UIImage(named: "ic_file")
                    self.ivReplyPreviewWidth.constant = 0
                default:
                    self.lbReplyPreview.text = data.message
                    self.iconReplyPreviewWidhtCons.constant = 0
                    self.iconReplyPreviewWidhtCons.constant = 0
                }
            }
            
            
            if(self.topReplyPreviewCons.constant != 0){
                self.topReplyPreviewCons.constant = 0
                self.customInputBarHeight = self.heightView.constant + self.replyPreviewCons.constant
                self.setHeight(self.customInputBarHeight)
            }
        }else{
           self.hidePreviewReply()
        }

    }
    
    func hidePreviewReply(){
        self.topReplyPreviewCons.constant = -50
        
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize.init(width: fixedWidth, height: CGFloat(MAXFLOAT)))
        self.heightTextViewCons.constant = newSize.height
        self.heightView.constant = newSize.height + 10.0
        self.setHeight(self.heightView.constant)
        
    }
    
    @IBAction func cancelReply(_ sender: Any) {
        self.replyData = nil
        self.hidePreviewReply()
    }
    @IBAction func clickSend(_ sender: Any) {
        guard let text = self.textView.text else {return}
        if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && text != TextConfiguration.sharedInstance.textPlaceholder {
            var payload:JSON? = nil
            let comment = CommentModel()
            if(replyData != nil){
                var senderName = replyData?.username
                comment.type = "reply"
                comment.message = text
                comment.payload = [
                    "replied_comment_sender_email"       : replyData?.userEmail,
                    "replied_comment_id" : Int((replyData?.id)!),
                    "text"      : text,
                    "replied_comment_message"   : replyData?.message,
                    "replied_comment_sender_username" : senderName,
                    "replied_comment_payload" : replyData?.payload,
                    "replied_comment_type" : replyData?.type
                ]
                self.replyData = nil
            }else{
               
                comment.type = "text"
                comment.message = text
                
            }
           
            self.delegate?.sendMessage(message: comment)
        }
        
        self.textView.text = ""
        self.hidePreviewReply()
    }
    
    @IBAction func clickAttachment(_ sender: Any) {
        self.delegate?.sendAttachment()
    }
}

extension CustomChatInput : UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if(textView.text == TextConfiguration.sharedInstance.textPlaceholder){
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if(textView.text.isEmpty){
            textView.text = TextConfiguration.sharedInstance.textPlaceholder
            textView.textColor = UIColor.lightGray
        }
        self.typing(false)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.typing(true)
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize.init(width: fixedWidth, height: CGFloat(MAXFLOAT)))
        if (newSize.height >= 34 && newSize.height <= 100) {
            self.heightTextViewCons.constant = newSize.height
            self.heightView.constant = newSize.height + 15.0
            if(self.topReplyPreviewCons.constant != 0){
                self.setHeight(self.heightView.constant)
            }else{
                self.setHeight(self.heightView.constant + self.replyPreviewCons.constant)
            }
            
        }
        
        if (newSize.height >= 100) {
            self.textView.isScrollEnabled = true
        }
    }
    
}
