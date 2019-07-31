//
//  QFileRightCell.swift
//  Example
//
//  Created by Qiscus on 21/02/19.
//  Copyright © 2019 Qiscus. All rights reserved.
//

import UIKit
import QiscusCore

class QFileRightCell: UIBaseChatCell {
    
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var tvContent: UILabel!
    @IBOutlet weak var ivBaloonLeft: UIImageView!
    
    @IBOutlet weak var ivStatus: UIImageView!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var lbNameHeight: NSLayoutConstraint!
    @IBOutlet weak var lbNameLeading: NSLayoutConstraint!
    @IBOutlet weak var lbNameTrailing: NSLayoutConstraint!
    
    @IBOutlet weak var ivFIle: UIImageView!
    var menuConfig = enableMenuConfig()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setMenu()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.setMenu()
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
        self.status(message: message)
        
        self.lbName.text = "You"
        self.lbTime.text = self.hour(date: message.date())
        self.tvContent.textColor = ColorConfiguration.rightBaloonTextColor
        self.lbNameHeight.constant = 0
        self.ivFIle.image = UIImage(named: "ic_file_attachment")?.withRenderingMode(.alwaysTemplate)
        self.ivFIle.tintColor = UIColor.white
        
        guard let payload = message.payload else { return }
        if let fileName = payload["file_name"] as? String{
            if fileName.isEmpty {
                self.tvContent.text = message.fileName(text: message.message)
            }else{
                self.tvContent.text = fileName
            }
            if let url = payload["url"] as? String {
                QiscusCore.shared.download(url: URL(string: url)!, onSuccess: { (urlLocal) in
                    
                }) { (progress) in
                    
                }
            }
        }
       
    }
    @IBAction func saveFile(_ sender: Any) {
        guard let payload = self.comment?.payload else { return }
        if let fileName = payload["file_name"] as? String{
            if let url = payload["url"] as? String {
                let preview = ChatPreviewDocVC()
                preview.fileName = fileName
                preview.url = url
                preview.roomName = "Document Preview"
                let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                
                self.currentViewController()?.navigationItem.backBarButtonItem = backButton
                self.currentViewController()?.navigationController?.pushViewController(preview, animated: true)
            }
        }
    }
    
    func setupBalon(){
        //self.ivBaloonLeft.applyShadow()
        self.ivBaloonLeft.image = self.getBallon()
        self.ivBaloonLeft.tintColor = ColorConfiguration.rightBaloonColor
    }
    
    func save(fileName: String, tempLocalUrl: URL){
        do {
            let documentsURL = try
                FileManager.default.url(for: .documentDirectory,
                                        in: .userDomainMask,
                                        appropriateFor: nil,
                                        create: false)
            
            let savedURL = documentsURL.appendingPathComponent(fileName)
            try FileManager.default.copyItem(at: tempLocalUrl, to: savedURL)
            self.showAlertWith(title: "Saved!", message: "Your file has been saved to your document.")
        } catch {
            print ("file error: \(error)")
            self.showAlertWith(title: "Save error", message: "\(error.localizedDescription)")
        }
        
    }
    
    func showAlertWith(title: String, message: String){
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        self.currentViewController()?.navigationController?.present(ac, animated: true, completion: {
            //success
        })
        
    }
    
    func currentViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return currentViewController(base: nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController {
            let moreNavigationController = tab.moreNavigationController
            
            if let top = moreNavigationController.topViewController, top.view.window != nil {
                return currentViewController(base: top)
            } else if let selected = tab.selectedViewController {
                return currentViewController(base: selected)
            }
        }
        
        if let presented = base?.presentedViewController {
            return currentViewController(base: presented)
        }
        
        return base
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

