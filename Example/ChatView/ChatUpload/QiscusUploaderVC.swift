//
//  QiscusUploaderVC.swift
//  Example
//
//  Created by Ahmad Athaullah on 9/12/17.
//  Copyright © 2017 Ahmad Athaullah. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices
import QiscusCore

enum QUploaderType {
    case image
    case video
}

class QiscusUploaderVC: UIViewController, UIScrollViewDelegate,UITextViewDelegate {

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var heightProgressViewCons: NSLayoutConstraint!
    @IBOutlet weak var labelProgress: UILabel!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var containerProgressView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var inputBottom: NSLayoutConstraint!
    @IBOutlet weak var mediaCaption: UITextView!
    @IBOutlet weak var minInputHeight: NSLayoutConstraint!
    @IBOutlet weak var mediaBottomMargin: NSLayoutConstraint!
    
    var chatView:UIChatViewController?
    var type = QUploaderType.image
    var data   : Data?
    var fileName :String?
    var imageData: [CommentModel] = []
    var selectedImageIndex: Int = 0
    let maxProgressHeight:Double = 40.0
    /**
     Setup maximum size when you send attachment inside chat view, example send video/image from galery. By default maximum size is unlimited.
     */
    var maxUploadSizeInKB:Double = Double(100) * Double(1024)
    
    //UnStableConnection
    @IBOutlet weak var viewUnstableConnection: UIView!
    @IBOutlet weak var heightViewUnstableConnectionConst: NSLayoutConstraint!
    
    @IBOutlet weak var btRetry: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.setupUI()
        
        self.upload()
       
    }
    
    func upload(){
        self.btRetry.isHidden = true
        self.btRetry.layer.cornerRadius = self.btRetry.frame.size.width / 2
        let startDate = Date()
        QiscusCore.shared.synchronize { (comments) in
            let now = startDate
            
            let currentDate = Date()
            let diffComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: now, to: currentDate)
            let seconds = diffComponents.second ?? 0
            
            if seconds > 5 {
                let defaults = UserDefaults.standard
                defaults.set(false, forKey: "hasInternet")
                NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "unStableConnection"), object: nil)
            }else{
                let defaults = UserDefaults.standard
                defaults.set(true, forKey: "hasInternet")
                NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "stableConnection"), object: nil)
            }
        } onError: { (error) in
            let defaults = UserDefaults.standard
            defaults.set(false, forKey: "hasInternet")
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "unStableConnection"), object: nil)
        }
        let now = startDate
        
        if self.fileName != nil && self.data != nil && self.imageData.count == 0 {
            self.labelTitle.text = self.fileName!
            QiscusCore.shared.upload(data: data!, filename: fileName!, onSuccess: { (file) in
                self.sendButton.isEnabled = true
                self.sendButton.isHidden = false
                self.hiddenProgress()
                
                let message = CommentModel()
                message.type = "file_attachment"
                message.payload = [
                    "url"       : file.url.absoluteString,
                    "file_name" : file.name,
                    "size"      : file.size,
                    "caption"   : ""
                ]
                message.message = "Send Image"
                self.imageData.append(message)
            }, onError: { (error) in
                let defaults = UserDefaults.standard
                defaults.set(false, forKey: "hasInternet")
                NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "unStableConnection"), object: nil)
                self.btRetry.isHidden = false
                self.hiddenProgress()
            }) { (progress) in
                print("upload progress: \(progress)")
                self.showProgress()
                self.labelProgress.text = "\(Int(progress * 100)) %"
                
                let newHeight = progress * self.maxProgressHeight
                self.heightProgressViewCons.constant = CGFloat(newHeight)
                UIView.animate(withDuration: 0.65, animations: {
                    self.progressView.layoutIfNeeded()
                })
                
                let currentDate = Date()
                let diffComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: now, to: currentDate)
                let seconds = diffComponents.second ?? 0
                
                if seconds > 7 {
                    let defaults = UserDefaults.standard
                    defaults.set(false, forKey: "hasInternet")
                    NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "unStableConnection"), object: nil)
                }else{
                    let defaults = UserDefaults.standard
                    defaults.set(true, forKey: "hasInternet")
                    NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "stableConnection"), object: nil)
                }
            }
            
        }
        
        for gesture in self.view.gestureRecognizers! {
            self.view.removeGestureRecognizer(gesture)
        }
    }
    
    @IBAction func retry(_ sender: Any) {
        self.upload()
    }
    
    
    func setupReachability(){
        let defaults = UserDefaults.standard
        let hasInternet = defaults.bool(forKey: "hasInternet")
        if hasInternet == true {
            self.stableConnection()
        }else{
            self.unStableConnection()
        }
    }
    
    @objc func showUnstableConnection(_ notification: Notification){
        self.unStableConnection()
    }
    
    func unStableConnection(){
        self.viewUnstableConnection.alpha = 1
        self.heightViewUnstableConnectionConst.constant = 45
    }
    
    @objc func hideUnstableConnection(_ notification: Notification){
        self.stableConnection()
    }
    
    func stableConnection(){
        self.viewUnstableConnection.alpha = 0
        self.heightViewUnstableConnectionConst.constant = 0
    }
    
    func qiscusAutoHideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.qiscusDismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func qiscusDismissKeyboard() {
        view.endEditing(true)
    }
    
    func setupUI(){
        self.labelTitle.text = "Image"
        self.hiddenProgress()
        self.containerProgressView.layer.cornerRadius = self.containerProgressView.frame.height / 2
        
        let keyboardToolBar = UIToolbar()
        keyboardToolBar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem:
            UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem:
            UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.doneClicked) )
        
        keyboardToolBar.setItems([flexibleSpace, doneButton], animated: true)
        
        mediaCaption.inputAccessoryView = keyboardToolBar
        
        mediaCaption.text = TextConfiguration.sharedInstance.captionPlaceholder
        mediaCaption.textColor = UIColor.lightGray
        mediaCaption.delegate = self
        
        self.qiscusAutoHideKeyboard()
        self.scrollView.delegate = self
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 4.0
        let sendImage = UIImage(named: "send")?.withRenderingMode(.alwaysTemplate)
        self.sendButton.setImage(sendImage, for: .normal)
        self.sendButton.tintColor = ColorConfiguration.defaultColorTosca
        self.cancelButton.setTitle("Cancel", for: .normal)
        self.mediaCaption.font = ChatConfig.chatFont
        
        self.sendButton.isEnabled = false
        self.sendButton.isHidden = true
        
        self.sendButton.tintColor = ColorConfiguration.defaultColorTosca
        self.sendButton.setImage(UIImage(named: "ic_send")?.withRenderingMode(.alwaysTemplate), for: .normal)
        
        self.cancelButton.tintColor = ColorConfiguration.defaultColorTosca
        self.cancelButton.setImage(UIImage(named: "ic_back")?.withRenderingMode(.alwaysTemplate), for: .normal)
    }
    
    func hiddenProgress(){
        self.containerProgressView.isHidden = true
        self.labelProgress.isHidden = true
        self.progressView.isHidden = true
    }
    
    func showProgress(){
        self.labelProgress.isHidden = false
        self.containerProgressView.isHidden = false
        self.progressView.isHidden = false
    }
    
    @objc func doneClicked() {
        view.endEditing(true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = TextConfiguration.sharedInstance.captionPlaceholder
            textView.textColor = UIColor.lightGray
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.data != nil {
            if type == .image {
                self.imageView.image = UIImage(data: self.data!)
            }
        }

        let center: NotificationCenter = NotificationCenter.default
        center.addObserver(self, selector: #selector(QiscusUploaderVC.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        center.addObserver(self, selector: #selector(QiscusUploaderVC.keyboardChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        self.navigationController?.isNavigationBarHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(hideUnstableConnection(_:)), name: NSNotification.Name(rawValue: "stableConnection"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showUnstableConnection(_:)), name: NSNotification.Name(rawValue: "unStableConnection"), object: nil)
        
        self.setupReachability()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    @IBAction func sendMedia(_ sender: Any) {
        if type == .image {
            
            if (mediaCaption.text != TextConfiguration.sharedInstance.captionPlaceholder ){
                
                self.imageData.first?.payload![ "caption" ] = mediaCaption.text
                
            }
            
            chatView?.send(message: self.imageData.first!, onSuccess: { (comment) in
                 let _ = self.navigationController?.popViewController(animated: true)
            }, onError: { (error) in
                 let _ = self.navigationController?.popViewController(animated: true)
            })
        }
    }
    
    // MARK: - Keyboard Methode
    @objc func keyboardWillHide(_ notification: Notification){
        let info: NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        
        let animateDuration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        self.inputBottom.constant = 0
        self.mediaBottomMargin.constant = 8
        UIView.animate(withDuration: animateDuration, delay: 0, options: UIView.AnimationOptions(), animations: {
            self.view.layoutIfNeeded()
            
        }, completion: nil)
    }
    @objc func keyboardChange(_ notification: Notification){
        let info:NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let keyboardSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let keyboardHeight: CGFloat = keyboardSize.height
        let animateDuration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        
        self.inputBottom.constant = keyboardHeight
        self.mediaBottomMargin.constant = -(self.mediaCaption.frame.height + 8)
        UIView.animate(withDuration: animateDuration, delay: 0, options: UIView.AnimationOptions(), animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    @IBAction func cancel(_ sender: Any) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
}

