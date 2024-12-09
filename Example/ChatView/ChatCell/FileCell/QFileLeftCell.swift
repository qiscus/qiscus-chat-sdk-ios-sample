//
//  QFileLeftCell.swift
//  Example
//
//  Created by Qiscus on 21/02/19.
//  Copyright © 2019 Qiscus. All rights reserved.
//

import UIKit
import QiscusCore

struct DocumentsDirectory {
    static let localDocumentsURL: NSURL? = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: .userDomainMask).last! as NSURL
    static let iCloudDocumentsURL: NSURL? = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") as! NSURL
    
}

class QFileLeftCell: UIBaseChatCell {
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var tvContent: UILabel!
    @IBOutlet weak var ivBaloonLeft: UIImageView!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var lbNameHeight: NSLayoutConstraint!
    @IBOutlet weak var lbNameLeading: NSLayoutConstraint!
    @IBOutlet weak var lbNameTrailing: NSLayoutConstraint!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    var isPublic: Bool = false
    var menuConfig = enableMenuConfig()
    var colorName : UIColor = UIColor.black
    @IBOutlet weak var ivFIle: UIImageView!
    @IBOutlet weak var viewBorder: UIView!
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
        
        self.lbTime.text = self.hour(date: message.date())
        self.lbTime.textColor = ColorConfiguration.timeLabelTextColor
        self.tvContent.text = message.message
        self.tvContent.textColor = ColorConfiguration.leftBaloonTextColor
        self.ivFIle.image = UIImage(named: "ic_file_attachment")?.withRenderingMode(.alwaysTemplate)
        self.ivFIle.tintColor = #colorLiteral(red: 0.5176470588, green: 0.7607843137, blue: 0.3803921569, alpha: 1)
        self.viewBorder.layer.cornerRadius = 8
        if(isPublic == true){
            self.lbName.text = message.username
            self.lbName.textColor = colorName
            lbNameHeight.constant = 21
        }else{
            self.lbName.text = ""
            lbNameHeight.constant = 0
        }
        
        guard let payload = message.payload else { return }
        if let fileName = payload["file_name"] as? String{
            self.tvContent.text = fileName
            if let url = payload["url"] as? String {
                QiscusCore.shared.download(url: URL(string: url)!, onSuccess: { (urlLocal) in
                    
                }) { (progress) in
                    
                }
            }
        }
    }
    
    @IBAction func saveFile(_ sender: Any) {
        if (self.comment?.message.contains("[/file]") == true){
            if let vc = self.currentViewController() {
                vc.view.endEditing(true)
            }
            var url = self.comment?.message.getAttachmentURL(message: self.comment?.message ?? "https://") ?? "https://"
            
            let preview = ChatPreviewDocVC()
            preview.fileName = url
            preview.url = url
            preview.roomName = "Document Preview"
            let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            backButton.tintColor = UIColor.white
            self.currentViewController()?.navigationItem.backBarButtonItem = backButton
            self.currentViewController()?.navigationController?.pushViewController(preview, animated: true)
            
        }else{
            guard let payload = self.comment?.payload else { return }
            if let fileName = payload["file_name"] as? String{
                if let url = payload["url"] as? String {
                    
                    if let vc = self.currentViewController() {
                        vc.view.endEditing(true)
                    }
                    
                    let preview = ChatPreviewDocVC()
                    preview.fileName = fileName
                    preview.url = url
                    preview.roomName = "Document Preview"
                    let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                    backButton.tintColor = UIColor.white
                    self.currentViewController()?.navigationItem.backBarButtonItem = backButton
                    self.currentViewController()?.navigationController?.pushViewController(preview, animated: true)
                    
                }
            }
        }
    }
    
    func save(fileName: String, tempLocalUrl: URL){
        
        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(atPath: tempLocalUrl.path)
        while let file = enumerator?.nextObject() as? String {
            
            do {
                try fileManager.setUbiquitous(true,
                                              itemAt: DocumentsDirectory.localDocumentsURL!.appendingPathComponent(file)!,
                                              destinationURL: DocumentsDirectory.iCloudDocumentsURL!.appendingPathComponent(file)!)
                print("Moved to iCloud")
            } catch let error as NSError {
                print("Failed to move file to Cloud : \(error)")
            }
        }
        
        
        
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
    
    
    func setupBalon(){
        self.ivBaloonLeft.applyShadow()
        self.ivBaloonLeft.image = self.getBallon()
        self.ivBaloonLeft.tintColor = ColorConfiguration.leftBaloonColor
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
