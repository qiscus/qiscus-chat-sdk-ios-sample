//
//  CustomChatInput.swift
//  Example
//
//  Created by Qiscus on 04/09/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices
import QiscusCore
import SwiftyJSON
import AVFoundation
import PhotosUI
import AlamofireImage
import Alamofire

protocol CustomChatInputDelegate {
    func sendAttachment(button : UIButton)
    func sendMessage(message: CommentModel)
}

class CustomChatInput: UIChatInput {
    
    @IBOutlet weak var viewShadowNoActiveSession: UIView!
    @IBOutlet weak var btStartChatNoActiveSession: UIButton!
    @IBOutlet weak var viewNoActiveSession: UIView!
    @IBOutlet weak var viewRecord: UIView!
    @IBOutlet weak var heightView: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var attachButton: UIButton!
    @IBOutlet weak var heightTextViewCons: NSLayoutConstraint!
    @IBOutlet weak var textView: UITextView!
    var chatInputDelegate : CustomChatInputDelegate? = nil
    var defaultInputBarHeight: CGFloat = 34.0
    var customInputBarHeight: CGFloat = 34.0
    var colorName : UIColor = UIColor.black
    
    //rec audio
    var isRecording = false
    var recordingURL:URL?
    var recorder:AVAudioRecorder?
    var recordingSession = AVAudioSession.sharedInstance()
    var recordTimer:Timer?
    var recordDuration:Int = 0
    var processingAudio = false
    var isGranted = true
    //reply
    var replyData:CommentModel?
    @IBOutlet weak var viewReply: UIView!
    @IBOutlet weak var viewColorReplyPreview: UIView!
    @IBOutlet weak var lbReplyPreviewSenderName: UILabel!
    @IBOutlet weak var lbReplyPreview: UILabel!
    @IBOutlet weak var ivReplyPreviewWidth: NSLayoutConstraint!
    @IBOutlet weak var ivReplyPreview: UIImageView!
    @IBOutlet weak var cancelReplyPreviewButton: UIButton!
    @IBOutlet weak var topReplyPreviewCons: NSLayoutConstraint!
    @IBOutlet weak var replyPreviewCons: NSLayoutConstraint!
    override func commonInit(nib: UINib) {
        let nib = UINib(nibName: "CustomChatInput", bundle: nil)
        super.commonInit(nib: nib)
        textView.delegate = self
        textView.text = TextConfiguration.sharedInstance.textPlaceholder
        textView.textColor = UIColor.lightGray
        textView.font = ChatConfig.chatFont
        textView.backgroundColor = UIColor.white
        self.textView.layer.cornerRadius = 8
        //self.textView.clipsToBounds = true
        
        self.textView.layer.borderWidth = 1
        self.textView.layer.borderColor = UIColor.lightGray.cgColor
        
        self.textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        self.sendButton.tintColor = ColorConfiguration.defaultColorTosca
        self.attachButton.tintColor = ColorConfiguration.defaultColorTosca
        self.attachButton.setImage(UIImage(named: "ic_circle_plus")?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.sendButton.setImage(UIImage(named: "ic_send")?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.sendButton.isHidden = true
        self.viewRecord.alpha = 0
        
        self.btStartChatNoActiveSession.layer.cornerRadius = self.btStartChatNoActiveSession.layer.frame.height / 2
    }
    
    @IBAction func clickSend(_ sender: Any) {
        if(self.isRecording == true){
            if !self.processingAudio {
                self.processingAudio = true
                self.finishRecording()
            }
        } else {
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
                self.chatInputDelegate?.sendMessage(message: comment)
            }
        }
        self.textView.text = ""
        self.setHeight(50)
        self.hidePreviewReply()
        
    }
    
    @IBAction func clickAttachment(_ sender: Any) {
        self.chatInputDelegate?.sendAttachment(button: self.attachButton)
    }
    
    func showNoActiveSession(){
        self.viewNoActiveSession.isHidden = false
        self.viewNoActiveSession.alpha = 1
        self.setHeight(169)
        
        self.sendButton.isHidden = true
        self.viewRecord.alpha = 0
        self.hideUIRecord(isHidden: true)
        
        //shadow
        self.viewShadowNoActiveSession.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.30).cgColor
        self.viewShadowNoActiveSession.layer.shadowOffset = CGSize(width: 1, height: 0.5)
        self.viewShadowNoActiveSession.layer.shadowOpacity = 0.3
        self.viewShadowNoActiveSession.layer.shadowRadius = 1.5
        self.viewShadowNoActiveSession.backgroundColor = UIColor.white
        
    }
    
    func hideNoActiveSession(){
        self.viewNoActiveSession.isHidden = true
        self.viewNoActiveSession.alpha = 0
        self.setHeight(50)
        
        self.sendButton.isHidden = true
        self.viewRecord.alpha = 0
        self.hideUIRecord(isHidden: false)
    }
    
    
    func cancelRecord(){
        self.viewRecord.alpha = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.inputView?.layoutIfNeeded()
        }) { (_) in
            self.sendButton.isHidden = true
            if self.recordTimer != nil {
                self.recordTimer?.invalidate()
                self.recordTimer = nil
                self.recordDuration = 0
            }
            self.isRecording = false
        }
    }
    
    func onFinishRecording(){
        if(self.isRecording == true){
            if !self.processingAudio {
                self.processingAudio = true
                self.finishRecording()
            }
        }
    }
    
    func finishRecording(){
        self.recorder?.stop()
        self.recorder = nil
         self.viewRecord.alpha = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.inputView?.layoutIfNeeded()
        }) { (_) in
            self.sendButton.isHidden = true
            if self.recordTimer != nil {
                self.recordTimer?.invalidate()
                self.recordTimer = nil
                self.recordDuration = 0
            }
            self.isRecording = false
            self.processingAudio = false
        }
        
        if self.isGranted == true{
            if let audioURL = self.recordingURL {
                var fileContent: Data?
                fileContent = try! Data(contentsOf: audioURL)
                let fileName = audioURL.lastPathComponent
                
                QiscusCore.shared.upload(data: fileContent!, filename: fileName, onSuccess: { (file) in
                    
                    let message = CommentModel()
                    message.type = "file_attachment"
                    message.payload = [
                        "url"       : file.url.absoluteString,
                        "file_name" : file.name,
                        "size"      : file.size,
                        "caption"   : ""
                    ]
                    message.message = "Send Audio"
                    
                    self.chatInputDelegate?.sendMessage(message: message)
                }, onError: { (error) in
                    print("Error: \(error)")
                }) { (progress) in
                    
                }
                
            }
        }
    }
    
    func startRecording(){
        
        self.viewRecord.alpha = 1
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let time = Double(Date().timeIntervalSince1970)
        let timeToken = UInt64(time * 10000)
        let fileName = "audio-\(timeToken).m4a"
        let audioURL = documentsPath.appendingPathComponent(fileName)
        print ("audioURL: \(audioURL)")
        self.recordingURL = audioURL
        let settings:[String : Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: Float(44100),
            AVNumberOfChannelsKey: Int(2),
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        UIView.animate(withDuration: 0.5, animations: {
            self.inputView?.layoutIfNeeded()
        }, completion: { success in
            
            do {
                self.recorder = nil
                if self.recorder == nil {
                    self.recorder = try AVAudioRecorder(url: audioURL, settings: settings)
                }
                self.recorder?.prepareToRecord()
                self.recorder?.isMeteringEnabled = true
                self.recorder?.record()
                self.sendButton.isEnabled = true
                self.recordDuration = 0
                if self.recordTimer != nil {
                    self.recordTimer?.invalidate()
                    self.recordTimer = nil
                }
                self.recordTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(CustomChatInput.updateTimer), userInfo: nil, repeats: true)
                self.isRecording = true
                let displayLink = CADisplayLink(target: self, selector: #selector(CustomChatInput.updateAudioMeter))
                displayLink.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
            } catch {
                print("error recording")
            }
        })
    }
    
    @objc func updateTimer(){
       self.recordDuration += 1
        let minutes = Int(self.recordDuration / 60)
        let seconds = self.recordDuration % 60
        var minutesString = "\(minutes)"
        if minutes < 10 {
            minutesString = "0\(minutes)"
        }
        var secondsString = "\(seconds)"
        if seconds < 10 {
            secondsString = "0\(seconds)"
        }
        //tvTimeRecord.text = "\(minutesString):\(secondsString)"
    }
    @objc func updateAudioMeter(){
        if let audioRecorder = self.recorder{
            audioRecorder.updateMeters()
            let normalizedValue:CGFloat = pow(10.0, CGFloat(audioRecorder.averagePower(forChannel: 0)) / 20)
            if let waveView = self.viewRecord as? QSiriWaveView {
                waveView.update(withLevel: normalizedValue)
            }
        }
    }
    
    func prepareRecording(){
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
            case .authorized: // The user has previously granted access to the audio.
                self.isGranted = true
                self.startRecording()

            case .notDetermined: // The user has not yet been asked for audio access.
                self.isGranted = false
            do {
                try recordingSession.setCategory(.playAndRecord, mode: .default, options: [])
                try recordingSession.setActive(true)
                recordingSession.requestRecordPermission { allowed in
                    
                    //DispatchQueue.main.async {
                        if allowed {
                            self.startRecording()
                        } else {
                            self.showMicrophoneAccessAlert()
                        }
                    //}
                }
            } catch {
                self.showMicrophoneAccessAlert()
            }
            case .denied: // The user has previously denied access.
                self.showMicrophoneAccessAlert()

            case .restricted: // The user can't grant access due to restrictions.
                self.showMicrophoneAccessAlert()
        }
        
        
//        switch AVCaptureDevice.authorizationStatus(for: .audio) {
//            case .authorized: // The user has previously granted access to the audio.
//                self.isGranted = true
//                self.startRecording()
//
//            case .notDetermined: // The user has not yet been asked for audio access.
//                self.isGranted = false
//                self.startRecording()
//            case .denied: // The user has previously denied access.
//                self.showMicrophoneAccessAlert()
//
//            case .restricted: // The user can't grant access due to restrictions.
//                self.showMicrophoneAccessAlert()
//        }
        
//        do {
//            try recordingSession.setCategory(.playAndRecord, mode: .default, options: [])
//            try recordingSession.setActive(true)
//            recordingSession.requestRecordPermission { allowed in
//                DispatchQueue.main.async {
//                    if allowed {
//                        self.startRecording()
//                    } else {
//                        self.showMicrophoneAccessAlert()
//                    }
//                }
//            }
//        } catch {
//            self.showMicrophoneAccessAlert()
//        }
    }
    
    func showMicrophoneAccessAlert(){
        DispatchQueue.main.async(execute: {
            let text = TextConfiguration.sharedInstance.microphoneAccessAlertText
            let cancelTxt = TextConfiguration.sharedInstance.alertCancelText
            let settingTxt = TextConfiguration.sharedInstance.alertSettingText
            QPopUpView.showAlert(withTarget: (self.currentViewController()?.navigationController)!, message: text, firstActionTitle: settingTxt, secondActionTitle: cancelTxt,  hiddenIconFileAttachment: true, isAlert: true,
                                 doneAction: {
                                    self.goToIPhoneSetting()
            },
                                 cancelAction: {}
            )
        })
    }
    
    func goToIPhoneSetting(){
        UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
        let _ = self.currentViewController()?.navigationController?.popViewController(animated: true)
    }
    
    func showPreviewReply(){
        if let data = replyData {
            self.lbReplyPreviewSenderName.text = data.username
            self.lbReplyPreviewSenderName.textColor = colorName
            self.ivReplyPreviewWidth.constant = 45
            
            if data.type == "text" || data.type == "reply"{
                self.lbReplyPreview.text = data.message
                self.ivReplyPreviewWidth.constant = 0
            }else if data.type == "file_attachment"{
                guard let payload = data.payload else {
                    return
                }
                
                if let url = payload["url"] as? String {
                    let ext = data.fileExtension(fromURL:url)
                    if(ext.contains("jpg") || ext.contains("png") || ext.contains("heic") || ext.contains("jpeg") || ext.contains("tif") || ext.contains("gif")){
                        // image
                        guard let payload = data.payload else { return }
                        let caption = payload["caption"] as? String
                        self.lbReplyPreview.text = caption
                        if let url = payload["url"] as? String {
                            self.ivReplyPreview.af_setImage(withURL: URL(string: url) ?? URL(string: "http://")!)
                        }
                    }else{
                        // file
                        var filename = data.fileName(text: data.message)
                        self.lbReplyPreview.text = filename
                        self.ivReplyPreviewWidth.constant = 0
                    }
                }else{
                    //default reply text
                    self.lbReplyPreview.text = data.message
                    self.ivReplyPreviewWidth.constant = 0
                }
            }
            
            if(self.topReplyPreviewCons.constant != 0){
                self.viewReply.isHidden = false
                self.viewReply.alpha = 1
                self.topReplyPreviewCons.constant = 0
                if self.heightView.constant <= 50 {
                    self.customInputBarHeight = self.heightView.constant + 10 + self.replyPreviewCons.constant
                } else {
                    self.customInputBarHeight = self.heightView.constant + self.replyPreviewCons.constant
                }
               
                self.setHeight(self.customInputBarHeight)
            }
        }else{
            self.hidePreviewReply()
        }
        
    }
    
    func hidePreviewReply(){
        self.viewReply.isHidden = true
        self.viewReply.alpha = 0
        self.topReplyPreviewCons.constant = -50
        
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize.init(width: fixedWidth, height: CGFloat(MAXFLOAT)))
        self.heightTextViewCons.constant = newSize.height
        self.heightView.constant = newSize.height + 10.0
        
        self.customInputBarHeight = self.heightView.constant + 10
        self.setHeight(self.customInputBarHeight)
    }
    
    @IBAction func cancelReply(_ sender: Any) {
        self.replyData = nil
        self.hidePreviewReply()
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
}

extension CustomChatInput : UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.sendButton.isHidden = false
        self.viewRecord.alpha = 0
        self.hideUIRecord(isHidden: true)
        if(textView.text == TextConfiguration.sharedInstance.textPlaceholder){
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if(textView.text.isEmpty){
            textView.text = TextConfiguration.sharedInstance.textPlaceholder
            textView.textColor = UIColor.lightGray
            self.sendButton.isHidden = true
            self.viewRecord.alpha = 0
            self.hideUIRecord(isHidden: false)
        }
        self.typing(false, query: textView.text)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.typing(true, query: textView.text)
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize.init(width: fixedWidth, height: CGFloat(MAXFLOAT)))
        if (newSize.height >= 35 && newSize.height <= 170) {
            self.heightTextViewCons.constant = newSize.height
            if self.replyData != nil {
                self.heightView.constant = newSize.height + 20.0 + self.replyPreviewCons.constant
            } else {
                self.heightView.constant = newSize.height + 20.0
            }
            
            self.setHeight(self.heightView.constant)
        }
        
        if (newSize.height >= 170) {
            self.textView.isScrollEnabled = true
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == UIPasteboard.general.string){
            self.typing(true, query: text)
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
               var maximumLabelSize: CGSize = CGSize(width: self.textView.frame.size.width, height: 170)
                var expectedLabelSize: CGSize = self.textView.sizeThatFits(maximumLabelSize)

                if expectedLabelSize.height >= 170 {
                    self.setHeight(170)
                } else if expectedLabelSize.height <= 50 {
                    self.setHeight(50)
                } else {
                    self.setHeight(expectedLabelSize.height)
                }
            })
            
        }else{
            //User did input by keypad
        }
        return true
    }
}

extension UIChatViewController : CustomChatInputDelegate {
    func uploadCamera() {
        UIBarButtonItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.systemBlue], for: .normal)
        
        UIButton.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = UIColor.systemBlue
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = UIColor.systemBlue
        self.view.endEditing(true)
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.authorized
        {
            DispatchQueue.main.async(execute: {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.allowsEditing = false
                picker.mediaTypes = [(kUTTypeImage as String),(kUTTypeMovie as String)]
                
                picker.sourceType = UIImagePickerController.SourceType.camera
                self.present(picker, animated: true, completion: nil)
            })
        }else{
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted :Bool) -> Void in
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    if granted {
                        PHPhotoLibrary.requestAuthorization({(status:PHAuthorizationStatus) in
                            switch status{
                            case .authorized:
                                let picker = UIImagePickerController()
                                picker.delegate = self
                                picker.allowsEditing = false
                                picker.mediaTypes = [(kUTTypeImage as String),(kUTTypeMovie as String)]
                                
                                picker.sourceType = UIImagePickerController.SourceType.camera
                                self.present(picker, animated: true, completion: nil)
                                break
                            case .denied:
                                self.showPhotoAccessAlert()
                                break
                            default:
                                self.showPhotoAccessAlert()
                                break
                            }
                        })
                    }else{
                        DispatchQueue.main.async(execute: {
                            self.showCameraAccessAlert()
                        })
                    }
                }else{
                    //no camera
                }
                
            })
        }
    }
    
    func uploadGalery(isFoto : Bool = true) {
        if #available(iOS 11.0, *) {
            //self.latestNavbarTint = self.currentNavbarTint
            UINavigationBar.appearance().tintColor = UIColor.blue
        }
        
        UIBarButtonItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.systemBlue], for: .normal)
        
        UIButton.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = UIColor.systemBlue
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = UIColor.systemBlue
        
        self.view.endEditing(true)
        let photoPermissions = PHPhotoLibrary.authorizationStatus()
        
        if(photoPermissions == PHAuthorizationStatus.authorized){
            self.goToGaleryPicker(isFoto : isFoto)
        }else if(photoPermissions == PHAuthorizationStatus.notDetermined){
            PHPhotoLibrary.requestAuthorization({(status:PHAuthorizationStatus) in
                switch status{
                case .authorized:
                    self.goToGaleryPicker(isFoto: isFoto)
                    break
                case .denied:
                    self.showPhotoAccessAlert()
                    if #available(iOS 11.0, *) {
                        UINavigationBar.appearance().tintColor = self.latestNavbarTint
                        self.navigationController?.navigationBar.tintColor = self.latestNavbarTint
                    }
                    break
                default:
                    self.showPhotoAccessAlert()
                    if #available(iOS 11.0, *) {
                        UINavigationBar.appearance().tintColor = self.latestNavbarTint
                        self.navigationController?.navigationBar.tintColor = self.latestNavbarTint
                    }
                    break
                }
            })
        }else{
            self.showPhotoAccessAlert()
            if #available(iOS 11.0, *) {
                UINavigationBar.appearance().tintColor = self.latestNavbarTint
                self.navigationController?.navigationBar.tintColor = self.latestNavbarTint
            }
        }
    }
    
    func uploadFile(){
        if #available(iOS 11.0, *) {
            //self.latestNavbarTint = self.currentNavbarTint
            UINavigationBar.appearance().tintColor = UIColor.blue
        }
        
        UIBarButtonItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.systemBlue], for: .normal)
        
        UIButton.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = UIColor.systemBlue
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = UIColor.systemBlue
        
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.item"], in: UIDocumentPickerMode.import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    func goToGaleryPicker(isFoto : Bool = true){
        DispatchQueue.main.async(execute: {
            if isFoto == false {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.allowsEditing = false
                picker.sourceType = UIImagePickerController.SourceType.photoLibrary
                picker.mediaTypes = [kUTTypeMovie as String]
                self.present(picker, animated: true, completion: nil)
            } else {
                if #available(iOS 14, *) {
                    var configuration = PHPickerConfiguration()
                    configuration.selectionLimit = 1
                    configuration.filter = .images
                    let picker = PHPickerViewController(configuration: configuration)
                    picker.delegate = self
                    self.present(picker, animated: true, completion: nil)
                } else {
                    let picker = UIImagePickerController()
                    picker.delegate = self
                    picker.allowsEditing = false
                    picker.sourceType = UIImagePickerController.SourceType.photoLibrary
                    picker.mediaTypes = [kUTTypeImage as String]
                    self.present(picker, animated: true, completion: nil)
                }
            }
        })
    }
    
    func showPhotoAccessAlert(){
        DispatchQueue.main.async(execute: {
            let text = TextConfiguration.sharedInstance.galeryAccessAlertText
            let cancelTxt = TextConfiguration.sharedInstance.alertCancelText
            let settingTxt = TextConfiguration.sharedInstance.alertSettingText
            QPopUpView.showAlert(withTarget: self, message: text, firstActionTitle: settingTxt, secondActionTitle: cancelTxt, hiddenIconFileAttachment: true, isAlert : true,
                                 doneAction: {
                                    self.goToIPhoneSetting()
            },
                                 cancelAction: {}
            )
        })
    }
    
    //Alert
    func goToIPhoneSetting(){
        UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    func showCameraAccessAlert(){
        DispatchQueue.main.async(execute: {
            let text = TextConfiguration.sharedInstance.cameraAccessAlertText
            let cancelTxt = TextConfiguration.sharedInstance.alertCancelText
            let settingTxt = TextConfiguration.sharedInstance.alertSettingText
            QPopUpView.showAlert(withTarget: self, message: text, firstActionTitle: settingTxt, secondActionTitle: cancelTxt, hiddenIconFileAttachment: true, isAlert: true,
                                 doneAction: {
                                    self.goToIPhoneSetting()
            },
                                 cancelAction: {}
            )
        })
    }
    
    func sendMessage(message: CommentModel) {
        let postedComment = message

        self.send(message: postedComment, onSuccess: { (comment) in
            //success
        }) { (error) in
            //error
        }
    }

    func sendAttachment(button buttonAttachment : UIButton) {
        let optionMenu = UIAlertController()
        let cameraAction = UIAlertAction(title: "Take Camera", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.uploadCamera()
        })
        optionMenu.addAction(cameraAction)


        let galleryAction = UIAlertAction(title: "Image from Gallery", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.uploadGalery()
        })
        optionMenu.addAction(galleryAction)
        
        let galleryVideoAction = UIAlertAction(title: "Video from Gallery", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.uploadGalery(isFoto : false)
        })
        optionMenu.addAction(galleryVideoAction)
        
        let fileAction = UIAlertAction(title: "File / Document", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.uploadFile()
        })
        optionMenu.addAction(fileAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in

        })

        optionMenu.addAction(cancelAction)
        
        
        if let presenter = optionMenu.popoverPresentationController {
            presenter.sourceView = buttonAttachment
            presenter.sourceRect = buttonAttachment.bounds
        }
        
        self.present(optionMenu, animated: true, completion: nil)
    }

    
}

// MARK: - UIDocumentPickerDelegate
extension UIChatViewController: UIDocumentPickerDelegate{
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        if #available(iOS 11.0, *) {
            UINavigationBar.appearance().tintColor = self.latestNavbarTint
            self.navigationController?.navigationBar.tintColor = self.latestNavbarTint
        }
        self.postReceivedFile(fileUrl: url)
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        if #available(iOS 11.0, *) {
            UINavigationBar.appearance().tintColor = self.latestNavbarTint
            self.navigationController?.navigationBar.tintColor = self.latestNavbarTint
        }
    }
    
    public func postReceivedFile(fileUrl: URL) {
        let coordinator = NSFileCoordinator()
        coordinator.coordinate(readingItemAt: fileUrl, options: NSFileCoordinator.ReadingOptions.forUploading, error: nil) { (dataURL) in
            do{
                var data:Data = try Data(contentsOf: dataURL, options: NSData.ReadingOptions.mappedIfSafe)
                let mediaSize = Double(data.count) / 1024.0
                var hiddenIconFileAttachment = true
                var skip = false
                if mediaSize > self.maxUploadSizeInKB {
                    self.showFileTooBigAlert()
                    return
                }
                
                var fileName = dataURL.lastPathComponent.replacingOccurrences(of: "%20", with: "_")
                fileName = fileName.replacingOccurrences(of: " ", with: "_")
                
                var popupText = TextConfiguration.sharedInstance.confirmationImageUploadText
                var fileType = QiscusFileType.image
                var thumb:UIImage? = nil
                let fileNameArr = (fileName as String).split(separator: ".")
                let ext = String(fileNameArr.last!).lowercased()
                
                let gif = (ext == "gif" || ext == "gif_")
                let video = (ext == "mp4" || ext == "mp4_" || ext == "mov" || ext == "mov_")
                let isImage = (ext == "jpg" || ext == "jpg_" || ext == "tif" || ext == "heic" || ext == "png" || ext == "png_")
                let isPDF = (ext == "pdf" || ext == "pdf_")
                var usePopup = false
                
                if isImage{
                    var i = 0
                    for n in fileNameArr{
                        if i == 0 {
                            fileName = String(n)
                        }else if i == fileNameArr.count - 1 {
                            fileName = "\(fileName).jpg"
                        }else{
                            fileName = "\(fileName).\(String(n))"
                        }
                        i += 1
                    }
                    let image = UIImage(data: data)!
                    let imageSize = image.size
                    var bigPart = CGFloat(0)
                    if(imageSize.width > imageSize.height){
                        bigPart = imageSize.width
                    }else{
                        bigPart = imageSize.height
                    }
                    
                    var compressVal = CGFloat(1)
                    if(bigPart > 2000){
                        compressVal = 2000 / bigPart
                    }
                    data = image.jpegData(compressionQuality:compressVal)!
                    thumb = UIImage(data: data)
                    usePopup = false
                }else if isPDF{
                    usePopup = true
                    popupText = "Are you sure to send this document?"
                    fileType = QiscusFileType.document
                    if let provider = CGDataProvider(data: data as NSData) {
                        if let pdfDoc = CGPDFDocument(provider) {
                            if let pdfPage:CGPDFPage = pdfDoc.page(at: 1) {
                                var pageRect:CGRect = pdfPage.getBoxRect(.mediaBox)
                                pageRect.size = CGSize(width:pageRect.size.width, height:pageRect.size.height)
                                UIGraphicsBeginImageContext(pageRect.size)
                                if let context:CGContext = UIGraphicsGetCurrentContext(){
                                    context.saveGState()
                                    context.translateBy(x: 0.0, y: pageRect.size.height)
                                    context.scaleBy(x: 1.0, y: -1.0)
                                    context.concatenate(pdfPage.getDrawingTransform(.mediaBox, rect: pageRect, rotate: 0, preserveAspectRatio: true))
                                    context.drawPDFPage(pdfPage)
                                    context.restoreGState()
                                    if let pdfImage:UIImage = UIGraphicsGetImageFromCurrentImageContext() {
                                        thumb = pdfImage
                                        hiddenIconFileAttachment = true
                                    }
                                }
                                UIGraphicsEndImageContext()
                            }
                        }
                    }
                }
                else if gif{
                    let image = UIImage(data: data)!
                    thumb = image
                    let asset = PHAsset.fetchAssets(withALAssetURLs: [dataURL], options: nil)
                    if let phAsset = asset.firstObject {
                        let option = PHImageRequestOptions()
                        option.isSynchronous = true
                        option.isNetworkAccessAllowed = true
                        PHImageManager.default().requestImageData(for: phAsset, options: option) {
                            (gifData, dataURI, orientation, info) -> Void in
                            data = gifData!
                        }
                    }
                    popupText = "Are you sure to send this image?"
                    usePopup = true
                }else if video {
                    fileType = .video
                    
                    if ext == ".mov" || ext == "mov" || ext == "mov_" {
                        skip = true
                        
                        let date = Date()
                        let formatter = DateFormatter.init()
                        formatter.dateFormat = "yyyyMMddHHmmss"
                        let fileName3 = formatter.string(from: date) + ".mp4"
                        
                        let docPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as NSString
                        let videoSandBoxPath = (docPath as String) + "/albumVideo" + fileName3
                        
                        
                        // Transcoding configuration
                        let avAsset = AVURLAsset.init(url: fileUrl, options: nil)
                        
                        let startDate = Date()
                        
                        //Create Export session
                        guard let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetPassthrough) else {
                            return
                        }
                        
                        
                        exportSession.outputURL = URL.init(fileURLWithPath: videoSandBoxPath)
                        exportSession.outputFileType = AVFileType.mp4
                        exportSession.shouldOptimizeForNetworkUse = true
                        let start = CMTimeMakeWithSeconds(0.0, preferredTimescale: 0)
                        let range = CMTimeRangeMake(start: start, duration: avAsset.duration)
                        exportSession.timeRange = range
                        
                        exportSession.exportAsynchronously(completionHandler: {() -> Void in
                            switch exportSession.status {
                            case .failed:
                                print(exportSession.error ?? "NO ERROR")
                            case .cancelled:
                                print("Export canceled")
                            case .completed:
                                //Video conversion finished
                                let endDate = Date()
                                
                                let time = endDate.timeIntervalSince(startDate)
                                print(time)
                                print("Successful!")
                                
                                let dataurl = URL.init(fileURLWithPath: videoSandBoxPath)
                                
                                do {
                                    let video = try Data(contentsOf: dataurl, options: .mappedIfSafe)
                                    
                                    var message = CommentModel()
                                    
                                    DispatchQueue.main.sync(execute: {
                                        QPopUpView.showAlert(withTarget: self, image: thumb, message:"Are you sure to send this video?", isVideoImage: true,
                                                             doneAction: {
                                                                self.send(message: message, onSuccess: { (comment) in
                                                                    //success
                                                                }, onError: { (error) in
                                                                    //error
                                                                })
                                                             },
                                                             cancelAction: {
                                                                //cancel upload
                                                             }, retryAction: {
                                                                //retry upload
                                                                QiscusCore.shared.upload(data: video, filename: fileName3, onSuccess: { (file) in
                                                                    message.type = "file_attachment"
                                                                    message.payload = [
                                                                        "url"       : file.url.absoluteString,
                                                                        "file_name" : file.name,
                                                                        "size"      : file.size,
                                                                        "caption"   : ""
                                                                    ]
                                                                    message.message = "Send Attachment"
                                                                    
                                                                    QPopUpView.sharedInstance.hiddenProgress()
                                                                    
                                                                }, onError: { (error) in
                                                                    
                                                                    let defaults = UserDefaults.standard
                                                                    defaults.set(false, forKey: "hasInternet")
                                                                    NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "unStableConnection"), object: nil)
                                                                    QPopUpView.sharedInstance.showRetry()
                                                                }) { (progress) in
                                                                    print("progress =\(progress)")
                                                                    QPopUpView.sharedInstance.showProgress(progress: progress)
                                                                }
                                                             })
                                        
                                        QiscusCore.shared.upload(data: video, filename: fileName3, onSuccess: { (file) in
                                            message.type = "file_attachment"
                                            message.payload = [
                                                "url"       : file.url.absoluteString,
                                                "file_name" : file.name,
                                                "size"      : file.size,
                                                "caption"   : ""
                                            ]
                                            message.message = "Send Attachment"
                                            
                                            QPopUpView.sharedInstance.hiddenProgress()
                                            
                                        }, onError: { (error) in
                                            let defaults = UserDefaults.standard
                                            defaults.set(false, forKey: "hasInternet")
                                            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "unStableConnection"), object: nil)
                                            QPopUpView.sharedInstance.showRetry()
                                        }) { (progress) in
                                            print("progress =\(progress)")
                                            QPopUpView.sharedInstance.showProgress(progress: progress)
                                        }
                                    })
                                } catch {
                                    print(error)
                                    return
                                }
                                
                            default: break
                            }
                            
                        })
                    }
                    
                    let assetMedia = AVURLAsset(url: dataURL)
                    let thumbGenerator = AVAssetImageGenerator(asset: assetMedia)
                    thumbGenerator.appliesPreferredTrackTransform = true
                    
                    let thumbTime = CMTimeMakeWithSeconds(0, preferredTimescale: 30)
                    let maxSize = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                    thumbGenerator.maximumSize = maxSize
                    
                    do{
                        let thumbRef = try thumbGenerator.copyCGImage(at: thumbTime, actualTime: nil)
                        thumb = UIImage(cgImage: thumbRef)
                        popupText = "Are you sure to send this video?"
                    }catch{
                        print("error creating thumb image")
                    }
                    usePopup = true
                    hiddenIconFileAttachment = true
                }else{
                    hiddenIconFileAttachment = false
                    usePopup = true
                    let textFirst = "Are you sure to send this file?"
                    let textMiddle = "\(fileName as String)"
                    let textLast = TextConfiguration.sharedInstance.questionMark
                    popupText = "\(textFirst) \(textMiddle)"
                    fileType = QiscusFileType.file
                    thumb = nil
                }
                
                if skip == false {
                    if usePopup {
                        let startDate = Date()
                        QiscusCore.shared.synchronize { (comments) in
                            let now = startDate
                            
                            let currentDate = Date()
                            let diffComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: now, to: currentDate)
                            let seconds = diffComponents.second ?? 0
                            
                            if seconds >= 5 {
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
                        
                        
                        var message = CommentModel()
                        
                        QPopUpView.showAlert(withTarget: self, image: thumb, message:popupText, isVideoImage: video, hiddenIconFileAttachment: hiddenIconFileAttachment,
                        doneAction: {
                            self.send(message: message, onSuccess: { (comment) in
                            //success
                        }, onError: { (error) in
                            //error
                        })
                        },
                        cancelAction: {
                            //cancel upload
                        },
                        retryAction: {
                            //retry upload
                            QiscusCore.shared.upload(data: data, filename: fileName, onSuccess: { (file) in
                                message.type = "file_attachment"
                                message.payload = [
                                    "url"       : file.url.absoluteString,
                                    "file_name" : file.name,
                                    "size"      : file.size,
                                    "caption"   : ""
                                ]
                                message.message = "Send Attachment"
                                
                                QPopUpView.sharedInstance.hiddenProgress()
                                
                            }, onError: { (error) in
                                let defaults = UserDefaults.standard
                                defaults.set(false, forKey: "hasInternet")
                                NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "unStableConnection"), object: nil)
                                QPopUpView.sharedInstance.showRetry()
                            }) { (progress) in
                                print("progress =\(progress)")
                                QPopUpView.sharedInstance.showProgress(progress: progress)
                            }
                        })
                        
                        QiscusCore.shared.upload(data: data, filename: fileName, onSuccess: { (file) in
                            message.type = "file_attachment"
                            message.payload = [
                                "url"       : file.url.absoluteString,
                                "file_name" : file.name,
                                "size"      : file.size,
                                "caption"   : ""
                            ]
                            message.message = "Send Attachment"
                            
                            QPopUpView.sharedInstance.hiddenProgress()
                            
                        }, onError: { (error) in
                            let defaults = UserDefaults.standard
                            defaults.set(false, forKey: "hasInternet")
                            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "unStableConnection"), object: nil)
                            QPopUpView.sharedInstance.showRetry()
                        }) { (progress) in
                            print("progress =\(progress)")
                            QPopUpView.sharedInstance.showProgress(progress: progress)
                        }
                    }else{
                        let uploader = QiscusUploaderVC(nibName: "QiscusUploaderVC", bundle: nil)
                        uploader.chatView = self
                        uploader.data = data
                        uploader.fileName = fileName
                        self.navigationController?.pushViewController(uploader, animated: true)
                    }
                }
            }catch _{
                //finish loading
                //self.dismissLoading()
            }
        }
    }
}

extension UIChatViewController: PHPickerViewControllerDelegate {
    
    @available(iOS 14, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        if #available(iOS 11.0, *) {
            UINavigationBar.appearance().tintColor = self.latestNavbarTint
            self.navigationController?.navigationBar.tintColor = self.latestNavbarTint
        }
        
        guard !results.isEmpty else {
            self.dismiss(animated:true, completion: nil)
            return
        }
        
        var imageName:String = "\(NSDate().timeIntervalSince1970 * 1000).jpg"
        
        let itemProviders = results.map(\.itemProvider)
        
        if itemProviders.count == 0{
            self.dismiss(animated:true, completion: nil)
            return
        }
        
        for item in itemProviders {
            if item.canLoadObject(ofClass: UIImage.self) {
                item.loadObject(ofClass: UIImage.self) { (image, error) in
                    DispatchQueue.main.async {
                        if let image = image as? UIImage {
                            var data = image.pngData()
                            
                            let imageSize = image.size
                            var bigPart = CGFloat(0)
                            if(imageSize.width > imageSize.height){
                                bigPart = imageSize.width
                            }else{
                                bigPart = imageSize.height
                            }
                            
                            var compressVal = CGFloat(1)
                            if(bigPart > 2000){
                                compressVal = 2000 / bigPart
                            }
                            
                            data = image.jpegData(compressionQuality:compressVal)
                            
                            if data != nil {
                                let mediaSize = Double(data!.count) / 1024.0
                                if mediaSize > self.maxUploadSizeInKB {
                                    picker.dismiss(animated: true, completion: {
                                        self.showFileTooBigAlert()
                                    })
                                    return
                                } else {
                                    self.dismiss(animated:true, completion: nil)
                                    
                                    picker.dismiss(animated: true, completion: {
                                        
                                    })
                                    
                                    let uploader = QiscusUploaderVC(nibName: "QiscusUploaderVC", bundle: nil)
                                    uploader.chatView = self
                                    uploader.data = data
                                    uploader.fileName = imageName
                                    self.navigationController?.pushViewController(uploader, animated: true)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// Image Picker
extension UIChatViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func showFileTooBigAlert(){
        let alertController = UIAlertController(title: "Fail to upload", message: "File too big", preferredStyle: .alert)
        let galeryActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ -> Void in }
        alertController.addAction(galeryActionButton)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let fileType:String = info[.mediaType] as! String
        let time = Double(Date().timeIntervalSince1970)
        let timeToken = UInt64(time * 10000)
        
        if fileType == "public.image"{
            
            var imageName:String = "\(NSDate().timeIntervalSince1970 * 1000).jpg"
            let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            var data = image.pngData()
            
            if let imageURL = info[UIImagePickerController.InfoKey.referenceURL] as? URL{
                imageName = imageURL.lastPathComponent
                
                let imageNameArr = imageName.split(separator: ".")
                let imageExt:String = String(imageNameArr.last!).lowercased()
                
                let gif:Bool = (imageExt == "gif" || imageExt == "gif_")
                let png:Bool = (imageExt == "png" || imageExt == "png_")
                
                if png{
                    data = image.pngData()!
                }else if gif{
                    let asset = PHAsset.fetchAssets(withALAssetURLs: [imageURL], options: nil)
                    if let phAsset = asset.firstObject {
                        let option = PHImageRequestOptions()
                        option.isSynchronous = true
                        option.isNetworkAccessAllowed = true
                        PHImageManager.default().requestImageData(for: phAsset, options: option) {
                            (gifData, dataURI, orientation, info) -> Void in
                            data = gifData
                        }
                    }
                }else{
                    let result = PHAsset.fetchAssets(withALAssetURLs: [imageURL], options: nil)
                    let asset = result.firstObject
                    imageName = "\((asset?.value(forKey: "filename"))!)"
                    imageName = imageName.replacingOccurrences(of: "HEIC", with: "jpg")
                    let imageSize = image.size
                    var bigPart = CGFloat(0)
                    if(imageSize.width > imageSize.height){
                        bigPart = imageSize.width
                    }else{
                        bigPart = imageSize.height
                    }
                    
                    var compressVal = CGFloat(1)
                    if(bigPart > 2000){
                        compressVal = 2000 / bigPart
                    }
                    
                    data = image.jpegData(compressionQuality:compressVal)
                }
            }else{
                let imageSize = image.size
                var bigPart = CGFloat(0)
                if(imageSize.width > imageSize.height){
                    bigPart = imageSize.width
                }else{
                    bigPart = imageSize.height
                }
                
                var compressVal = CGFloat(1)
                if(bigPart > 2000){
                    compressVal = 2000 / bigPart
                }
                
                data = image.jpegData(compressionQuality:compressVal)
            }
            
            if data != nil {
                let mediaSize = Double(data!.count) / 1024.0
                if mediaSize > self.maxUploadSizeInKB {
                    picker.dismiss(animated: true, completion: {
                        self.showFileTooBigAlert()
                    })
                    return
                }
                
                dismiss(animated:true, completion: nil)
                
                let uploader = QiscusUploaderVC(nibName: "QiscusUploaderVC", bundle: nil)
                uploader.chatView = self
                uploader.data = data
                uploader.fileName = imageName
                self.navigationController?.pushViewController(uploader, animated: true)
                picker.dismiss(animated: true, completion: {
                    
                })
                
                
            }
            
        }else if fileType == "public.movie" {
            let mediaURL = info[UIImagePickerController.InfoKey.mediaURL] as! URL
            let fileName = mediaURL.lastPathComponent
            
            let mediaData = try? Data(contentsOf: mediaURL)
            let mediaSize = Double(mediaData!.count) / 1024.0
            if mediaSize > self.maxUploadSizeInKB {
                picker.dismiss(animated: true, completion: {
                    self.showFileTooBigAlert()
                })
                return
            }
            //create thumb image
            let assetMedia = AVURLAsset(url: mediaURL)
            let thumbGenerator = AVAssetImageGenerator(asset: assetMedia)
            thumbGenerator.appliesPreferredTrackTransform = true
            
            let thumbTime = CMTimeMakeWithSeconds(0, preferredTimescale: 30)
            let maxSize = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
            thumbGenerator.maximumSize = maxSize
            
            picker.dismiss(animated: true, completion: {
                
            })
            
            
            let startDate = Date()
            QiscusCore.shared.synchronize { (comments) in
                let now = startDate
                
                let currentDate = Date()
                let diffComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: now, to: currentDate)
                let seconds = diffComponents.second ?? 0
                
                if seconds >= 5 {
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
            
            do{
                let thumbRef = try thumbGenerator.copyCGImage(at: thumbTime, actualTime: nil)
                let thumbImage = UIImage(cgImage: thumbRef)
                
                
                var checkFileName = fileName.replacingOccurrences(of: "%20", with: "_")
                checkFileName = fileName.replacingOccurrences(of: " ", with: "_")
                
                let fileNameArr = (checkFileName as String).split(separator: ".")
                let ext = String(fileNameArr.last!).lowercased()
                
                if (ext == ".mov" || ext == "mov" || ext == "mov_") {
                    let date = Date()
                    let formatter = DateFormatter.init()
                    formatter.dateFormat = "yyyyMMddHHmmss"
                    let fileName3 = formatter.string(from: date) + ".mp4"
                    
                    let docPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as NSString
                    let videoSandBoxPath = (docPath as String) + "/albumVideo" + fileName3
                    
                    
                    // Transcoding configuration
                    let avAsset = AVURLAsset.init(url: mediaURL, options: nil)
                    
                    let startDate = Date()
                    
                    //Create Export session
                    guard let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetPassthrough) else {
                        return
                    }
                    
                    
                    exportSession.outputURL = URL.init(fileURLWithPath: videoSandBoxPath)
                    exportSession.outputFileType = AVFileType.mp4
                    exportSession.shouldOptimizeForNetworkUse = true
                    let start = CMTimeMakeWithSeconds(0.0, preferredTimescale: 0)
                    let range = CMTimeRangeMake(start: start, duration: avAsset.duration)
                    exportSession.timeRange = range
                    
                    exportSession.exportAsynchronously(completionHandler: {() -> Void in
                        switch exportSession.status {
                        case .failed:
                            print(exportSession.error ?? "NO ERROR")
                        case .cancelled:
                            print("Export canceled")
                        case .completed:
                            //Video conversion finished
                            let endDate = Date()
                            
                            let time = endDate.timeIntervalSince(startDate)
                            print(time)
                            print("Successful!")
                            
                            let dataurl = URL.init(fileURLWithPath: videoSandBoxPath)
                            
                            do {
                                let video = try Data(contentsOf: dataurl, options: .mappedIfSafe)
                                
                                var message = CommentModel()
                                
                                DispatchQueue.main.sync(execute: {
                                    QPopUpView.showAlert(withTarget: self, image: thumbImage, message:"Are you sure to send this video?", isVideoImage: true,
                                                         doneAction: {
                                                            self.send(message: message, onSuccess: { (comment) in
                                                                //success
                                                            }, onError: { (error) in
                                                                //error
                                                            })
                                                         },
                                                         cancelAction: {
                                                            //cancel upload
                                                         }, retryAction: {
                                                            //retry upload
                                                            QiscusCore.shared.upload(data: video, filename: fileName3, onSuccess: { (file) in
                                                                message.type = "file_attachment"
                                                                message.payload = [
                                                                    "url"       : file.url.absoluteString,
                                                                    "file_name" : file.name,
                                                                    "size"      : file.size,
                                                                    "caption"   : ""
                                                                ]
                                                                message.message = "Send Attachment"
                                                                
                                                                QPopUpView.sharedInstance.hiddenProgress()
                                                                
                                                            }, onError: { (error) in
                                                                
                                                                let defaults = UserDefaults.standard
                                                                defaults.set(false, forKey: "hasInternet")
                                                                NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "unStableConnection"), object: nil)
                                                                QPopUpView.sharedInstance.showRetry()
                                                            }) { (progress) in
                                                                print("progress =\(progress)")
                                                                QPopUpView.sharedInstance.showProgress(progress: progress)
                                                            }
                                                         })
                                    
                                    QiscusCore.shared.upload(data: video, filename: fileName3, onSuccess: { (file) in
                                        message.type = "file_attachment"
                                        message.payload = [
                                            "url"       : file.url.absoluteString,
                                            "file_name" : file.name,
                                            "size"      : file.size,
                                            "caption"   : ""
                                        ]
                                        message.message = "Send Attachment"
                                        
                                        QPopUpView.sharedInstance.hiddenProgress()
                                        
                                    }, onError: { (error) in
                                        let defaults = UserDefaults.standard
                                        defaults.set(false, forKey: "hasInternet")
                                        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "unStableConnection"), object: nil)
                                        QPopUpView.sharedInstance.showRetry()
                                    }) { (progress) in
                                        print("progress =\(progress)")
                                        QPopUpView.sharedInstance.showProgress(progress: progress)
                                    }
                                })
                            } catch {
                                print(error)
                                return
                            }
                            
                        default: break
                        }
                        
                    })
                }else{
                    var message = CommentModel()
                    
                    
                    QPopUpView.showAlert(withTarget: self, image: thumbImage, message:"Are you sure to send this video?", isVideoImage: true,
                                         doneAction: {
                                            self.send(message: message, onSuccess: { (comment) in
                                                //success
                                            }, onError: { (error) in
                                                //error
                                            })
                                         },
                                         cancelAction: {
                                            //cancel upload
                                         }, retryAction: {
                                            //retry upload
                                            QiscusCore.shared.upload(data: mediaData!, filename: fileName, onSuccess: { (file) in
                                                message.type = "file_attachment"
                                                message.payload = [
                                                    "url"       : file.url.absoluteString,
                                                    "file_name" : file.name,
                                                    "size"      : file.size,
                                                    "caption"   : ""
                                                ]
                                                message.message = "Send Attachment"
                                                
                                                QPopUpView.sharedInstance.hiddenProgress()
                                                
                                            }, onError: { (error) in
                                                
                                                let defaults = UserDefaults.standard
                                                defaults.set(false, forKey: "hasInternet")
                                                NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "unStableConnection"), object: nil)
                                                QPopUpView.sharedInstance.showRetry()
                                            }) { (progress) in
                                                print("progress =\(progress)")
                                                QPopUpView.sharedInstance.showProgress(progress: progress)
                                            }
                                         })
                    
                    QiscusCore.shared.upload(data: mediaData!, filename: fileName, onSuccess: { (file) in
                        message.type = "file_attachment"
                        message.payload = [
                            "url"       : file.url.absoluteString,
                            "file_name" : file.name,
                            "size"      : file.size,
                            "caption"   : ""
                        ]
                        message.message = "Send Attachment"
                        
                        QPopUpView.sharedInstance.hiddenProgress()
                        
                    }, onError: { (error) in
                        
                        let defaults = UserDefaults.standard
                        defaults.set(false, forKey: "hasInternet")
                        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "unStableConnection"), object: nil)
                        QPopUpView.sharedInstance.showRetry()
                    }) { (progress) in
                        print("progress =\(progress)")
                        QPopUpView.sharedInstance.showProgress(progress: progress)
                    }
                }
            }catch{
                print("error creating thumb image")
            }
        }
        
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

