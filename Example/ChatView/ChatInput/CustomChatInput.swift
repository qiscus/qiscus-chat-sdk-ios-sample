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
import PhotosUI

protocol CustomChatInputDelegate {
    func sendAttachment()
    func sendMessage(message: CommentModel)
    func updateMessage(message: CommentModel)
}

class CustomChatInput: UIChatInput {
    
    @IBOutlet weak var heightView: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var attachButton: UIButton!
    @IBOutlet weak var heightTextViewCons: NSLayoutConstraint!
    @IBOutlet weak var textView: UITextView!
    var chatInputDelegate : CustomChatInputDelegate? = nil
    var defaultInputBarHeight: CGFloat = 34.0
    var customInputBarHeight: CGFloat = 34.0
    var colorName : UIColor = UIColor.black
    var replyData:CommentModel?
    var isEditMessage : Bool = false
    var editMessage:CommentModel?
    //reply
    
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
        //self.textView.layer.cornerRadius = self.textView.frame.size.height / 2
        //self.textView.clipsToBounds = true
        self.textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        self.viewReply.layer.cornerRadius = 8

        self.sendButton.tintColor = ColorConfiguration.sendButtonColor
        self.attachButton.tintColor = ColorConfiguration.attachmentButtonColor
        self.attachButton.setImage(UIImage(named: "ic_attachment")?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.sendButton.setImage(UIImage(named: "ic_send")?.withRenderingMode(.alwaysTemplate), for: .normal)
    }
    
    @IBAction func clickSend(_ sender: Any) {
        guard let text = self.textView.text else {return}
        if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && text != TextConfiguration.sharedInstance.textPlaceholder {
            if isEditMessage == false {
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
            } else {
                
                if let updateMessage = editMessage {
                    updateMessage.message = text
                    self.chatInputDelegate?.updateMessage(message: updateMessage)
                }
                
                self.editMessage = nil
                self.isEditMessage = false
            }
        }
        
        self.textView.text = ""
        self.hidePreviewReply()
    }
    
    @IBAction func clickAttachment(_ sender: Any) {
         self.chatInputDelegate?.sendAttachment()
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
                            self.ivReplyPreview.af.setImage(withURL: URL(string: url) ?? URL(string: "http://")!)
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
                self.customInputBarHeight = self.heightView.constant + self.replyPreviewCons.constant
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

extension UIChatViewController : CustomChatInputDelegate {
    func uploadCamera() {
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
    
    func uploadGalery() {
        if #available(iOS 11.0, *) {
            //self.latestNavbarTint = self.currentNavbarTint
            UINavigationBar.appearance().tintColor = UIColor.blue
        }
        
        self.view.endEditing(true)
        let photoPermissions = PHPhotoLibrary.authorizationStatus()
        
        if(photoPermissions == PHAuthorizationStatus.authorized){
            self.goToGaleryPicker()
        }else if(photoPermissions == PHAuthorizationStatus.notDetermined){
            PHPhotoLibrary.requestAuthorization({(status:PHAuthorizationStatus) in
                switch status{
                case .authorized:
                    self.goToGaleryPicker()
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
          //  self.latestNavbarTint = self.currentNavbarTint
            UINavigationBar.appearance().tintColor = UIColor.blue
        }
        
        let documentPicker = UIDocumentPickerViewController(documentTypes: self.UTIs, in: UIDocumentPickerMode.import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    func goToGaleryPicker(){
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
            picker.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    func showPhotoAccessAlert(){
        DispatchQueue.main.async(execute: {
            let text = TextConfiguration.sharedInstance.galeryAccessAlertText
            let cancelTxt = TextConfiguration.sharedInstance.alertCancelText
            let settingTxt = TextConfiguration.sharedInstance.alertSettingText
            QPopUpView.showAlert(withTarget: self, message: text, firstActionTitle: settingTxt, secondActionTitle: cancelTxt,
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
            QPopUpView.showAlert(withTarget: self, message: text, firstActionTitle: settingTxt, secondActionTitle: cancelTxt,
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
    
    func updateMessage(message: CommentModel) {
        let postedComment = message

        self.updateMessageSend(message: postedComment, onSuccess: { (comment) in
            //success
        }) { (error) in
            //error
        }
    }

    func sendAttachment() {
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
        
        let fileAction = UIAlertAction(title: "File / Document", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.uploadFile()
        })
        optionMenu.addAction(fileAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in

        })

        optionMenu.addAction(cancelAction)
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
                }else{
                    usePopup = true
                    let textFirst = TextConfiguration.sharedInstance.confirmationFileUploadText
                    let textMiddle = "\(fileName as String)"
                    let textLast = TextConfiguration.sharedInstance.questionMark
                    popupText = "\(textFirst) \(textMiddle) \(textLast)"
                    fileType = QiscusFileType.file
                }
                
                if usePopup {
                    QPopUpView.showAlert(withTarget: self, image: thumb, message:popupText, isVideoImage: video,
                                         doneAction: {
                                            
                                            let file = FileUploadModel()
                                            file.data = data
                                            file.name = fileName
                                            
                                            QiscusCore.shared.upload(file: file, onSuccess: { (file) in
                                                self.getProgressBarHeight().constant = 0.0
                                                let message = CommentModel()
                                                message.type = "file_attachment"
                                                message.payload = [
                                                    "url"       : file.url.absoluteString,
                                                    "file_name" : file.name,
                                                    "size"      : file.size,
                                                    "caption"   : ""
                                                ]
                                                message.message = "Send Attachment"
                                                self.send(message: message, onSuccess: { (comment) in
                                                    //success
                                                }, onError: { (error) in
                                                    //error
                                                    self.getProgressBarHeight().constant = 0
                                                })
                                            }, onError: { (error) in
                                                self.getProgressBarHeight().constant = 0
                                            }, progressListener: { (progress) in
                                                print("upload progress :\(progress)")
                                                self.getProgressBarHeight().constant = 2
                                                self.getProgressBar().progress = Float(progress)
                                                if(progress == 1){
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                                        self.getProgressBarHeight().constant = 2
                                                        self.getProgressBar().progress = 0.0
                                                    }
                                                }
                                            })
                                            
                    },
                                         cancelAction: {
                                            
                    })
                }else{
                    QiscusCore.shared.upload(data: data, filename: fileName, onSuccess: { (file) in
                        self.getProgressBarHeight().constant = 0.0
                        let message = CommentModel()
                        message.type = "file_attachment"
                        message.payload = [
                            "url"       : file.url.absoluteString,
                            "file_name" : file.name,
                            "size"      : file.size,
                            "caption"   : ""
                        ]
                        message.message = "Send Attachment"
                        self.send(message: message, onSuccess: { (comment) in
                            //success
                        }, onError: { (error) in
                            self.getProgressBarHeight().constant = 0.0
                        })
                    }, onError: { (error) in
                        self.getProgressBarHeight().constant = 0.0
                    }) { (progress) in
                        print("upload progress: \(progress)")
                        self.getProgressBar().progress = Float(progress)
                        self.getProgressBarHeight().constant = 2
                        if(progress == 1){
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                self.getProgressBarHeight().constant = 0
                                self.getProgressBar().progress = 0.0
                            }
                        }
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
            do{
                let thumbRef = try thumbGenerator.copyCGImage(at: thumbTime, actualTime: nil)
                let thumbImage = UIImage(cgImage: thumbRef)
                
                QPopUpView.showAlert(withTarget: self, image: thumbImage, message:"Are you sure to send this video?", isVideoImage: true,
                                     doneAction: {
                                        let file = FileUploadModel()
                                        file.data = mediaData!
                                        file.name = fileName
                                        QiscusCore.shared.upload(file: file, onSuccess: { (file) in
                                            let message = CommentModel()
                                            message.type = "file_attachment"
                                            message.payload = [
                                                "url"       : file.url.absoluteString,
                                                "file_name" : file.name,
                                                "size"      : file.size,
                                                "caption"   : ""
                                            ]
                                            message.message = "Send Attachment"
                                            self.send(message: message, onSuccess: { (comment) in
                                                //success
                                            }, onError: { (error) in
                                                //error
                                            })
                                        }, onError: { (error) in
                                            //error
                                        }, progressListener: { (progress) in
                                            print("progress =\(progress)")
                                        })
                                        
                },
                                     cancelAction: {
                                        //cancel upload
                }
                )
            }catch{
                print("error creating thumb image")
            }
        }
        
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

