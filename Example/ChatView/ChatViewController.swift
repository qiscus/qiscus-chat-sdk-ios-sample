//
//  ChatViewController.swift
//  Qiscus
//
//  Created by Qiscus on 07/08/18.
//

import UIKit
import QiscusUI
import QiscusCore
import SwiftyJSON
import ContactsUI
import Photos
import MobileCoreServices

public class ChatViewController: UIChatViewController {
    // UI Config
    var usersColor : [String:UIColor] = [String:UIColor]()
    /**
    Setup maximum size when you send attachment inside chat view, example send video/image from galery. By default maximum size is unlimited.
    */
    var maxUploadSizeInKB:Double = Double(100) * Double(1024)
    
    //TODO NEED TO BE IMPLEMENT
    var isPresence:Bool = false
    var chatDistinctId:String?
    var chatData:String?
    var chatMessage:String?
    
    var chatNewRoomUsers:[String] = [String]()
    var chatUser:String?
    var data:Any?
    var chatRoomId:String?
    //public var chatTarget:CommentModel?
    var didFindLocation = true
    let locationManager = CLLocationManager()
    var presentingLoading = false
    var inputBar = CustomChatInput()
    
    var latestNavbarTint = UINavigationBar.appearance().tintColor
    internal var currentNavbarTint = UINavigationBar.appearance().tintColor
    //static let currentNavbarTint = UINavigationBar.appearance().tintColor
    let picker = UIImagePickerController()
    var UTIs:[String]{
        get{
            return ["public.jpeg", "public.png","com.compuserve.gif","public.text", "public.archive", "com.microsoft.word.doc", "com.microsoft.excel.xls", "com.microsoft.powerpoint.​ppt", "com.adobe.pdf","public.mpeg-4"]
        }
    }
    
    var replyData:CommentModel? = nil {
        didSet{
            inputBar.replyData = replyData
        }
    }
    
    func showLoading(_ text:String = "Loading"){
        if !self.presentingLoading {
            self.presentingLoading = true
            self.showLoading(withText: text)
        }
    }
    func stopLoading(){
        self.presentingLoading = false
        self.dismissLoading()
    }

    public override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    public override func viewDidLoad() {
        self.chatDelegate = self
        // Set delegate before super
        super.viewDidLoad()
        if (room == nil){
            if let roomid = chatRoomId  {
                // loading
                //self.showLoading()
                QiscusCore.shared.getRoom(withID: roomid, onSuccess: { (roomModel, _) in
                    //self.dismissLoading()
                    self.room = roomModel
                    self.setupNavigationTitle()
                }) { (error) in
                    //self.dismissLoading()
                    print("error load room \(String(describing: error.message))")
                }
            }
        }
        
        self.setupUI()
        NotificationCenter.default.addObserver(self, selector:#selector(willEnterFromForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        if let room = self.room{
            if room.participants?.count != 0 {
                if let participants = room.participants {
                    for participant in participants.enumerated(){
                        let email = participant.element.email
                        let color = ColorConfiguration.randomColorLabelName.randomItem()!
                        usersColor[email] = color
                    }
                }
            }
        }
    }
    
    @objc func willEnterFromForeground(){
        self.tabBarController?.tabBar.isHidden = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupUI(){
         self.setupBackgroundChat()
         self.registerCell()
         self.setupNavigationTitle()
         self.setupChatInput()
        
    }
    
    func setupBackgroundChat(){
        self.setBackground(with: AssetsConfiguration.backgroundChat!)
    }
    
    func setupChatInput(){
        picker.delegate = self
    }
    
    @objc private func didSaveContact(_ notification: Notification){
        if let userInfo = notification.userInfo {
            let comment = userInfo["comment"] as! CommentModel
            let payload = JSON(comment.payload)
            let contactValue = payload["value"].stringValue
            
            let con = CNMutableContact()
            con.givenName = payload["name"].stringValue
            if contactValue.contains("@"){
                let email = CNLabeledValue(label: CNLabelHome, value: contactValue as NSString)
                con.emailAddresses.append(email)
            }else{
                let phone = CNLabeledValue(label: CNLabelPhoneNumberMobile, value: CNPhoneNumber(stringValue: contactValue))
                con.phoneNumbers.append(phone)
            }
            
            let unkvc = CNContactViewController.init(forNewContact: con)
            unkvc.message = "New Contact"
            unkvc.contactStore = CNContactStore()
            unkvc.delegate = self
            unkvc.allowsActions = false
            self.navigationController?.navigationBar.backgroundColor = ColorConfiguration.topColor
            self.navigationController?.pushViewController(unkvc, animated: true)
        }
    }
    
    @objc private func didClickInfo(_ notification: Notification){
        if let userInfo = notification.userInfo {
            let comment = userInfo["comment"] as! CommentModel
            
        }
    }
    
    @objc private func didClickForward(_ notification: Notification){
        if let userInfo = notification.userInfo {
            let comment = userInfo["comment"] as! CommentModel

        }
    }
    
    @objc private func didClickShare(_ notification: Notification){
        if let userInfo = notification.userInfo {
            let comment = userInfo["comment"] as! CommentModel
            
            switch comment.type {
            case "file_attachment":
                guard let payload = comment.payload else {
                    return
                }
                let fileURL = payload["url"] as? String
                
                if let fileURL = NSURL(string: fileURL!) {
                    let items:[Any] = [fileURL]
                    let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
                    
                    activityViewController.popoverPresentationController?.sourceView = self.view
                    self.present(activityViewController, animated: true, completion: nil)
                }
                break
            case "text":
                let activityViewController = UIActivityViewController(activityItems: [comment.message], applicationActivities: nil)
                
                activityViewController.popoverPresentationController?.sourceView = self.view
                self.present(activityViewController, animated: true, completion: nil)
                break
            default:
                break
            }
            
        }
    }
    
    func registerCell() {
        self.registerClass(nib: UINib(nibName: "QTextRightCell", bundle:nil), forMessageCellWithReuseIdentifier: "qTextRightCell")
        self.registerClass(nib: UINib(nibName: "QTextLeftCell", bundle:nil), forMessageCellWithReuseIdentifier: "qTextLeftCell")
        self.registerClass(nib: UINib(nibName: "QImageLeftCell", bundle:nil), forMessageCellWithReuseIdentifier: "qImageLeftCell")
        self.registerClass(nib: UINib(nibName: "QImageRightCell", bundle:nil), forMessageCellWithReuseIdentifier: "qImageRightCell")
        self.registerClass(nib: UINib(nibName: "QDocumentLeftCell", bundle:nil), forMessageCellWithReuseIdentifier: "qDocumentLeftCell")
        self.registerClass(nib: UINib(nibName: "QDocumentRightCell", bundle:nil), forMessageCellWithReuseIdentifier: "qDocumentRightCell")
        self.registerClass(nib: UINib(nibName: "QSystemCell", bundle:nil), forMessageCellWithReuseIdentifier: "qSystemCell")
        self.registerClass(nib: UINib(nibName: "QReplyLeftCell", bundle:nil), forMessageCellWithReuseIdentifier: "qReplyLeftCell")
        self.registerClass(nib: UINib(nibName: "QReplyRightCell", bundle:nil), forMessageCellWithReuseIdentifier: "qReplyRightCell")
        self.registerClass(nib: UINib(nibName: "QLocationLeftCell", bundle:nil), forMessageCellWithReuseIdentifier: "qLocationLeftCell")
        self.registerClass(nib: UINib(nibName: "QLocationRightCell", bundle:nil), forMessageCellWithReuseIdentifier: "qLocationRightCell")
        self.registerClass(nib: UINib(nibName: "QContactLeftCell", bundle:nil), forMessageCellWithReuseIdentifier: "qContactLeftCell")
        self.registerClass(nib: UINib(nibName: "QContactRightCell", bundle:nil), forMessageCellWithReuseIdentifier: "qContactRightCell")
        self.registerClass(nib: UINib(nibName: "QAudioLeftCell", bundle:nil), forMessageCellWithReuseIdentifier: "qAudioLeftCell")
        self.registerClass(nib: UINib(nibName: "QAudioRightCell", bundle:nil), forMessageCellWithReuseIdentifier: "qAudioRightCell")
        self.registerClass(nib: UINib(nibName: "QPostbackLeftCell", bundle:nil), forMessageCellWithReuseIdentifier: "postBack")
        self.registerClass(nib: UINib(nibName: "QCarouselCell", bundle:nil), forMessageCellWithReuseIdentifier: "qCarouselCell")
        
    }
    
    private func setupNavigationTitle(){
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = false
        }
        var totalButton = 1
        
        if let leftButtons = self.navigationItem.leftBarButtonItems {
            totalButton += leftButtons.count
        }
        
        if let rightButtons = self.navigationItem.rightBarButtonItems {
            totalButton += rightButtons.count
        }

        self.chatTitleView.labelTitle.font            = self.chatTitleView.labelTitle.font.withSize(14)
        self.chatTitleView.labelSubtitle.font         = self.chatTitleView.labelSubtitle.font.withSize(12)
       
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapFunction))
        self.chatTitleView.labelTitle.isUserInteractionEnabled = true
        self.chatTitleView.labelTitle.addGestureRecognizer(tap)
        
    }
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        print("Tap avatar")
    }
    
    private func backButton(_ target: UIViewController, action: Selector) -> UIBarButtonItem{
        let backIcon = UIImageView()
        backIcon.contentMode = .scaleAspectFit
        
        let image = QiscusUI.image(named: "ic_back")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        backIcon.image = image
        backIcon.tintColor = UINavigationBar.appearance().tintColor
        
        if UIApplication.shared.userInterfaceLayoutDirection == .leftToRight {
            backIcon.frame = CGRect(x: 0,y: 11,width: 13,height: 22)
        }else{
            backIcon.frame = CGRect(x: 22,y: 11,width: 13,height: 22)
        }
        
        let backButton = UIButton(frame:CGRect(x: 0,y: 0,width: 23,height: 44))
        backButton.addSubview(backIcon)
        backButton.addTarget(target, action: action, for: UIControl.Event.touchUpInside)
        return UIBarButtonItem(customView: backButton)
    }
    
    func getType(message: CommentModel) -> QiscusFileType{
        let json = message.payload
        var type = QiscusFileType.file
        guard let payload = message.payload else {
            return type
        }
        let fileURL = payload["url"] as? String
        var filename = CommentModel().fileName(text: fileURL!)
        
        if filename.contains("-"){
            let nameArr = filename.split(separator: "-")
            var i = 0
            for comp in nameArr {
                switch i {
                case 0 : filename = "" ; break
                case 1 : filename = "\(String(comp))"
                default: filename = "\(filename)-\(comp)"
                }
                i += 1
            }
        }
        
        var ext = ""
        if filename.range(of: ".") != nil{
            let fileNameArr = filename.split(separator: ".")
            ext = String(fileNameArr.last!).lowercased()
        }
        
        switch ext {
        case "jpg","jpeg","jpg_","png","png_","gif","gif_", "heic":
            type = QiscusFileType.image
        case "mov","mov_","mp4","mp4_":
            type = QiscusFileType.video
        case "m4a","m4a_","aac","aac_","mp3","mp3_":
            type = QiscusFileType.audio
        case "pdf","pdf_":
            type = QiscusFileType.pdf
        default:
            type = QiscusFileType.file
        }
        
        return type
    }
    
}

extension ChatViewController : UIChatView {
    public func uiChat(viewController: UIChatViewController, performAction action: Selector, forRowAt message: CommentModel, withSender sender: Any?) {
        if action == #selector(UIResponderStandardEditActions.copy(_:)) {
            let pasteboard = UIPasteboard.general
            pasteboard.string = message.message
        }
    }
    
    public func uiChat(viewController: UIChatViewController, canPerformAction action: Selector, forRowAtmessage: CommentModel, withSender sender: Any?) -> Bool {
        switch action.description {
        case "copy:":
            return true
        case "reply:":
            return true
        case "forward:":
            return true
        case "share:":
            return true
        case "info:":
            return true
        case "deleteComment:":
            return true
        case "deleteCommentForMe:":
            return true
        default:
            return false
        }
    }
    
    public func uiChat(viewController: UIChatViewController, cellForMessage message: CommentModel) -> UIBaseChatCell? {
        var colorName:UIColor = UIColor.lightGray
        if let color = usersColor[message.userEmail] {
            colorName = color
        }
        
        let menuConfig = enableMenuConfig()
        
        if message.type == "text" {
            if (message.isMyComment() == true){
                let cell =  self.reusableCell(withIdentifier: "qTextRightCell", for: message) as! QTextRightCell
                cell.menuConfig = menuConfig
                cell.cellMenu = self
                return cell
            }else{
                let cell = self.reusableCell(withIdentifier: "qTextLeftCell", for: message) as! QTextLeftCell
                if self.room?.type == .group {
                    cell.colorName = colorName
                    cell.isPublic = true
                }else {
                    cell.isPublic = false
                }
                cell.cellMenu = self
                return cell
            }
        }else if message.type == "file_attachment" {
            let type = self.getType(message: message)
            switch type {
            case .image:
                if (message.isMyComment() == true){
                    let cell =  self.reusableCell(withIdentifier: "qImageRightCell", for: message) as! QImageRightCell
                    cell.menuConfig = menuConfig
                    cell.cellMenu = self
                    return cell
                }else{
                    let cell = self.reusableCell(withIdentifier: "qImageLeftCell", for: message) as! QImageLeftCell
                        cell.menuConfig = menuConfig
                    if self.room?.type == .group {
                        cell.isPublic = true
                        cell.colorName = colorName
                    }else {
                        cell.isPublic = false
                    }
                    cell.cellMenu = self
                    return cell
                }
            case .video:
                if (message.isMyComment() == true){
                    let cell =  self.reusableCell(withIdentifier: "qDocumentRightCell", for: message) as! QDocumentRightCell
                    cell.menuConfig = menuConfig
                    cell.cellMenu = self
                    return cell
                }else{
                    let cell = self.reusableCell(withIdentifier: "qDocumentLeftCell", for: message) as! QDocumentLeftCell
                    cell.menuConfig = menuConfig
                    cell.cellMenu = self
                    if self.room?.type == .group {
                        cell.colorName = colorName
                        cell.isPublic = true
                    }else {
                        cell.isPublic = false
                    }
                    return cell
                }
            case .audio:
                if (message.isMyComment() == true){
                    let cell = self.reusableCell(withIdentifier: "qAudioRightCell", for: message) as! QAudioRightCell
                    cell.menuConfig = menuConfig
                    cell.cellMenu = self
                    return cell
                }else{
                    let cell = self.reusableCell(withIdentifier: "qAudioLeftCell", for: message) as! QAudioLeftCell
                    cell.menuConfig = menuConfig
                    cell.cellMenu = self
                    if self.room?.type == .group {
                        cell.colorName = colorName
                        cell.isPublic = true
                    }else {
                        cell.isPublic = false
                    }
                    return cell
                }
            case .pdf:
                if (message.isMyComment() == true){
                    let cell =  self.reusableCell(withIdentifier: "qDocumentRightCell", for: message) as! QDocumentRightCell
                    cell.menuConfig = menuConfig
                    return cell
                }else{
                    let cell = self.reusableCell(withIdentifier: "qDocumentLeftCell", for: message) as! QDocumentLeftCell
                    if self.room?.type == .group {
                        cell.colorName = colorName
                        cell.isPublic = true
                    }else {
                        cell.isPublic = false
                    }
                    cell.menuConfig = menuConfig
                    cell.cellMenu = self
                    return cell
                }
            case .document:
                if (message.isMyComment() == true){
                    let cell = self.reusableCell(withIdentifier: "qDocumentRightCell", for: message) as! QDocumentRightCell
                    cell.menuConfig = menuConfig
                    cell.cellMenu = self
                    return cell
                }else{
                    let cell = self.reusableCell(withIdentifier: "qDocumentLeftCell", for: message) as! QDocumentLeftCell
                    if self.room?.type == .group {
                        cell.colorName = colorName
                        cell.isPublic = true
                    }else {
                        cell.isPublic = false
                    }
                    cell.menuConfig = menuConfig
                    cell.cellMenu = self
                    return cell
                }
            default:
                if (message.isMyComment() == true){
                    let cell = self.reusableCell(withIdentifier: "qDocumentRightCell", for: message) as! QDocumentRightCell
                    cell.menuConfig = menuConfig
                    cell.cellMenu = self
                    return cell
                }else{
                    let cell = self.reusableCell(withIdentifier: "qDocumentLeftCell", for: message) as! QDocumentLeftCell
                    if self.room?.type == .group {
                        cell.colorName = colorName
                        cell.isPublic = true
                    }else {
                        cell.isPublic = false
                    }
                    cell.menuConfig = menuConfig
                    cell.cellMenu = self
                    return cell
                }
            }
        }else if message.type == "system_event" {
            return self.reusableCell(withIdentifier: "qSystemCell", for: message) as! QSystemCell
        }else if message.type == "reply" {
            if (message.isMyComment() == true){
                let cell = self.reusableCell(withIdentifier: "qReplyRightCell", for: message) as! QReplyRightCell
                cell.menuConfig = menuConfig
                cell.delegateChat = self
                cell.cellMenu = self
                return cell
            }else{
                let cell = self.reusableCell(withIdentifier: "qReplyLeftCell", for: message) as! QReplyLeftCell
                if self.room?.type == .group {
                    cell.isPublic = true
                    cell.colorName = colorName
                }else {
                    cell.isPublic = false
                }
                cell.delegateChat = self
                cell.menuConfig = menuConfig
                cell.cellMenu = self
                return cell
            }
            
        }else if message.type == "location" {
            if (message.isMyComment() == true){
                let cell =  self.reusableCell(withIdentifier: "qLocationRightCell", for: message) as! QLocationRightCell
                cell.menuConfig = menuConfig
                cell.cellMenu = self
                return cell
            }else{
                let cell = self.reusableCell(withIdentifier: "qLocationLeftCell", for: message) as! QLocationLeftCell
                cell.menuConfig = menuConfig
                cell.colorName = colorName
                cell.cellMenu = self
                return cell
            }
        }else if message.type == "contact_person" {
            if (message.isMyComment() == true){
                let cell =  self.reusableCell(withIdentifier: "qContactRightCell", for: message) as! QContactRightCell
                cell.menuConfig = menuConfig
                cell.cellMenu = self
                return cell
            }else{
                let cell = self.reusableCell(withIdentifier: "qContactLeftCell", for: message) as! QContactLeftCell
                cell.menuConfig = menuConfig
                cell.cellMenu = self
                if self.room?.type == .group {
                    cell.isPublic = true
                    cell.colorName = colorName
                }else {
                    cell.isPublic = false
                }
                return cell
            }
        }else if message.type == "account_linking" {
            let cell = self.reusableCell(withIdentifier: "postBack", for: message) as! QPostbackLeftCell
            cell.delegate = self
            cell.type = .accountLinking
            return cell
        }else if message.type == "buttons" {
            let cell = self.reusableCell(withIdentifier: "postBack", for: message) as! QPostbackLeftCell
            cell.delegate = self
            cell.type = .buttons
            return cell
        }else if message.type == "button_postback_response" {
            let cell =  self.reusableCell(withIdentifier: "qTextRightCell", for: message) as! QTextRightCell
            cell.menuConfig = menuConfig
            cell.cellMenu = self
            return cell
        }else if message.type == "carousel" ||  message.type == "card" {
            let cell =  self.reusableCell(withIdentifier: "qCarouselCell", for: message) as! QCarouselCell
            cell.delegate = self
            return cell
        }else {
            print("message.type =\(message.type)")
            return nil
        }
    }
    
    public func uiChat(viewController: UIChatViewController, didSelectMessage message: CommentModel) {
        //
    }
    
    public func uiChat(viewController: UIChatViewController, firstMessage message: CommentModel, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    public func uiChat(input InViewController: UIChatViewController) -> UIChatInput? {
        let sendImage = UIImage(named: "send")?.withRenderingMode(.alwaysTemplate)
        let attachmentImage = UIImage(named: "share_attachment")?.withRenderingMode(.alwaysTemplate)
        let cancel = UIImage(named: "ar_cancel")?.withRenderingMode(.alwaysTemplate)
        inputBar.sendButton.setImage(sendImage, for: .normal)
        inputBar.attachButton.setImage(attachmentImage, for: .normal)
        inputBar.cancelReplyPreviewButton.setImage(cancel, for: .normal)
        
        inputBar.sendButton.tintColor = ColorConfiguration.topColor
        inputBar.attachButton.tintColor = ColorConfiguration.topColor
         inputBar.cancelReplyPreviewButton.tintColor = ColorConfiguration.topColor
        inputBar.delegate = self
        inputBar.hidePreviewReply()
        return inputBar
    }
    
}

extension ChatViewController: CNContactViewControllerDelegate{
    public func contactViewController(_ viewController: CNContactViewController, shouldPerformDefaultActionFor property: CNContactProperty) -> Bool {
        return true
    }
    
    public func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        viewController.navigationController?.popViewController(animated: true)
    }
}

extension ChatViewController : CustomChatInputDelegate {
    func sendMessage(message: CommentModel) {
        var postedComment = message
    
        self.send(message: postedComment, onSuccess: { (comment) in
            //success
        }) { (error) in
            //error
        }
    }
    
    func sendAttachment() {
        let optionMenu = UIAlertController()
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.uploadFromCamera()
        })
        optionMenu.addAction(cameraAction)
   

        let galleryAction = UIAlertAction(title: "Photo & Video Library", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.uploadImage()
        })
        optionMenu.addAction(galleryAction)
    

        let docAction = UIAlertAction(title: "Document", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.iCloudOpen()
        })
        optionMenu.addAction(docAction)
        
        
        let contactAction = UIAlertAction(title: "Contact", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.getContact()
        })
        optionMenu.addAction(contactAction)
       
        let locationAction = UIAlertAction(title: "Location", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.getLocation()
        })
        optionMenu.addAction(locationAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            
        })
        
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func iCloudOpen(){
        if QiscusCore.connect(){
            if #available(iOS 11.0, *) {
                self.latestNavbarTint = self.currentNavbarTint
                UINavigationBar.appearance().tintColor = UIColor.blue
            }
            
            let documentPicker = UIDocumentPickerViewController(documentTypes: self.UTIs, in: UIDocumentPickerMode.import)
            documentPicker.delegate = self
            documentPicker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            self.present(documentPicker, animated: true, completion: nil)
        }else{
            self.showNoConnectionToast()
        }
    }
    
    func uploadImage(){
        view.endEditing(true)
        if QiscusCore.connect() {
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
                        break
                    default:
                        self.showPhotoAccessAlert()
                        break
                    }
                })
            }else{
                self.showPhotoAccessAlert()
            }
        }else{
            self.showNoConnectionToast()
        }
    }
    
    func goToGaleryPicker(){
        DispatchQueue.main.async(execute: {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            picker.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
            self.present(picker, animated: true, completion: nil)
        })
    }
    
    func uploadFromCamera(){
        view.endEditing(true)
        if QiscusCore.connect(){
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
        }else{
            self.showNoConnectionToast()
        }
    }
    
    private func getContact() {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        contactPicker.displayedPropertyKeys =
            [CNContactGivenNameKey
                , CNContactPhoneNumbersKey]
        self.present(contactPicker, animated: true, completion: nil)
    }
    
    private func getLocation() {
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways, .authorizedWhenInUse:
                self.showLoading("Loading...")
                
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                self.didFindLocation = false
                self.locationManager.startUpdatingLocation()
                break
            case .denied:
                self.showLocationAccessAlert()
                break
            case .restricted:
                self.showLocationAccessAlert()
                break
            case .notDetermined:
                self.showLocationAccessAlert()
                break
            }
        }else{
            self.showLocationAccessAlert()
        }
    }
    
    
    public func postReceivedFile(fileUrl: URL) {
        let coordinator = NSFileCoordinator()
        coordinator.coordinate(readingItemAt: fileUrl, options: NSFileCoordinator.ReadingOptions.forUploading, error: nil) { (dataURL) in
            do{
                var data:Data = try Data(contentsOf: dataURL, options: NSData.ReadingOptions.mappedIfSafe)
                let mediaSize = Double(data.count) / 1024.0
                
                if mediaSize > maxUploadSizeInKB {
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
                    data = image.jpegData(compressionQuality: compressVal)!
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
                    let width = UIScreen.main.bounds.size.width
                    let maxSize = CGSize(width: width, height: width)
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
                                            QiscusCore.shared.upload(data: data, filename: fileName, onSuccess: { (file) in
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
                                                //
                                            }) { (progress) in
                                                print("upload progress: \(progress)")
                                            }
                    },
                                         cancelAction: {
                                            
                    }
                    )
                }else{
//                    let uploader = QiscusUploaderVC(nibName: "QiscusUploaderVC", bundle:nil)
//                    uploader.chatView = self
//                    uploader.data = data
//                    uploader.fileName = fileName
//                    uploader.room = self.chatRoom
//                    self.navigationController?.pushViewController(uploader, animated: true)
                    
                    QiscusCore.shared.upload(data: data, filename: fileName, onSuccess: { (file) in
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
                        //
                    }) { (progress) in
                        print("upload progress: \(progress)")
                    }
                }
                
            }catch _{
                //finish loading
                //self.dismissLoading()
            }
        }
    }
    
    
    //Alert
    func goToIPhoneSetting(){
        UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    func showLocationAccessAlert(){
        DispatchQueue.main.async{autoreleasepool{
            let text = TextConfiguration.sharedInstance.locationAccessAlertText
            let cancelTxt = TextConfiguration.sharedInstance.alertCancelText
            let settingTxt = TextConfiguration.sharedInstance.alertSettingText
            QPopUpView.showAlert(withTarget: self, message: text, firstActionTitle: settingTxt, secondActionTitle: cancelTxt,
                                 doneAction: {
                                    self.goToIPhoneSetting()
            },
                                 cancelAction: {}
            )
            }}
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
    
    func showNoConnectionToast(){
        
    }
}

// Contact Picker
extension ChatViewController : CNContactPickerDelegate {
    public func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        let userName:String = contact.givenName
        let surName:String = contact.familyName
        let fullName:String = userName + " " + surName
        //  user phone number
        let userPhoneNumbers:[CNLabeledValue<CNPhoneNumber>] = contact.phoneNumbers
        let firstPhoneNumber:CNPhoneNumber = userPhoneNumbers[0].value
        let primaryPhoneNumberStr:String = firstPhoneNumber.stringValue
        
        // send contact, with qiscus comment type "contact_person" payload must valit
        let message = CommentModel()
        message.type = "contact_person"
        message.payload = [
            "name"  : fullName,
            "value" : primaryPhoneNumberStr,
            "type"  : "phone"
        ]
        message.message = "Send Contact"
        self.send(message: message, onSuccess: { (comment) in
            //success
        }, onError: { (error) in
            //error
        })
    }
}

// MARK: - UIDocumentPickerDelegate
extension ChatViewController: UIDocumentPickerDelegate{
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
}

// Image Picker
extension ChatViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func showFileTooBigAlert(){
        let alertController = UIAlertController(title: "Fail to upload", message: "File too big", preferredStyle: .alert)
        let galeryActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ -> Void in }
        alertController.addAction(galeryActionButton)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let fileType:String = info[.mediaType] as? String else { return }
        let time = Double(Date().timeIntervalSince1970)
        let timeToken = UInt64(time * 10000)
        
        if fileType == "public.image"{

            var imageName:String = "\(NSDate().timeIntervalSince1970 * 1000).jpg"
            guard let image = info[.originalImage] as? UIImage else { return }
            var data = image.pngData()
            
            if let imageURL = info[.referenceURL] as? URL{
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
                    
                    data = image.jpegData(compressionQuality: compressVal)
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
                
                data = image.jpegData(compressionQuality: compressVal)
            }
            
            if data != nil {
                let mediaSize = Double(data!.count) / 1024.0
                if mediaSize > maxUploadSizeInKB {
                    picker.dismiss(animated: true, completion: {
                        self.showFileTooBigAlert()
                    })
                    return
                }
                
                dismiss(animated:true, completion: nil)
                
                let uploader = QiscusUploaderVC(nibName: "QiscusUploaderVC", bundle:nil)
                uploader.chatView = self
                uploader.data = data
                uploader.fileName = imageName
                self.navigationController?.pushViewController(uploader, animated: true)
                picker.dismiss(animated: true, completion: {
                    
                })
                
                
            }
            
        }else if fileType == "public.movie" {
            let mediaURL = info[.mediaURL] as! URL
            let fileName = mediaURL.lastPathComponent
            
            let mediaData = try? Data(contentsOf: mediaURL)
            let mediaSize = Double(mediaData!.count) / 1024.0
            if mediaSize > maxUploadSizeInKB {
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
            let width = UIScreen.main.bounds.size.width
            let maxSize = CGSize(width: width, height: width)
            thumbGenerator.maximumSize = maxSize
            
            picker.dismiss(animated: true, completion: {
                
            })
            do{
                let thumbRef = try thumbGenerator.copyCGImage(at: thumbTime, actualTime: nil)
                let thumbImage = UIImage(cgImage: thumbRef)
                
                QPopUpView.showAlert(withTarget: self, image: thumbImage, message:"Are you sure to send this video?", isVideoImage: true,
                                     doneAction: {
                                        QiscusCore.shared.upload(data: mediaData!, filename: fileName, onSuccess: { (file) in
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
                                            //
                                        }) { (progress) in
                                            print("upload progress: \(progress)")
                                        }
                },
                                     cancelAction: {
                                        print("cancel upload")
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

extension ChatViewController: CLLocationManagerDelegate {
    
    func newLocationComment(latitude:Double, longitude:Double, title:String?=nil, address:String?=nil)->CommentModel{
        let comment = CommentModel()
        var locTitle = title
        var locAddress = ""
        if address != nil {
            locAddress = address!
        }
        if title == nil {
            var newLat = latitude
            var newLong = longitude
            var latString = "N"
            var longString = "E"
            if latitude < 0 {
                latString = "S"
                newLat = 0 - latitude
            }
            if longitude < 0 {
                longString = "W"
                newLong = 0 - longitude
            }
            let intLat = Int(newLat)
            let intLong = Int(newLong)
            let subLat = Int((newLat - Double(intLat)) * 100)
            let subLong = Int((newLong - Double(intLong)) * 100)
            let subSubLat = Int((newLat - Double(intLat) - Double(Double(subLat)/100)) * 10000)
            let subSubLong = Int((newLong - Double(intLong) - Double(Double(subLong)/100)) * 10000)
            let pLat = Int((newLat - Double(intLat) - Double(Double(subLat)/100) - Double(Double(subSubLat)/10000)) * 100000)
            let pLong = Int((newLong - Double(intLong) - Double(Double(subLong)/100) - Double(Double(subSubLong)/10000)) * 100000)
            
            locTitle = "\(intLat)º\(subLat)\'\(subSubLat).\(pLat)\"\(latString) \(intLong)º\(subLong)\'\(subSubLong).\(pLong)\"\(longString)"
        }
        let url = "http://maps.google.com/maps?daddr=\(latitude),\(longitude)"
        
        let payload = "{ \"name\": \"\(locTitle!)\", \"address\": \"\(locAddress)\", \"latitude\": \(latitude), \"longitude\": \(longitude), \"map_url\": \"\(url)\"}"
        
        
        comment.type = "location"
        comment.payload = JSON(parseJSON: payload).dictionaryObject
      
        return comment
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DispatchQueue.global(qos: .background).async { autoreleasepool{
            manager.stopUpdatingLocation()
            if !self.didFindLocation {
                if let currentLocation = manager.location {
                    let geoCoder = CLGeocoder()
                    let latitude = currentLocation.coordinate.latitude
                    let longitude = currentLocation.coordinate.longitude
                    var address:String?
                    var title:String?
                    
                    geoCoder.reverseGeocodeLocation(currentLocation, completionHandler: { (placemarks, error) in
                        if error == nil {
                            let placeArray = placemarks
                            var placeMark: CLPlacemark!
                            placeMark = placeArray?[0]
                            
                            if let addressDictionary = placeMark.addressDictionary{
                                if let addressArray = addressDictionary["FormattedAddressLines"] as? [String] {
                                    address = addressArray.joined(separator: ", ")
                                }
                                title = addressDictionary["Name"] as? String
                                DispatchQueue.main.async { autoreleasepool{
                                    let message = self.newLocationComment(latitude: latitude, longitude: longitude, title: title, address: address)
                                    message.message = "Send Location"
                                    self.send(message: message, onSuccess: { (comment) in
                                        //success
                                    }, onError: { (error) in
                                        //error
                                    })
                                }}
                            }
                        }
                    })
                    
                }
                self.didFindLocation = true
                self.dismissLoading()
            }
            }}
    }
}

// MARK: Handle Cell Menu
extension ChatViewController : QUIBaseChatCellDelegate {
    func didTap(replay comment: CommentModel) {
        self.replyData = comment
        if usersColor.count != 0{
            if let email = self.replyData?.userEmail, let color = usersColor[email] {
                self.inputBar.colorName = color
            }
        }
        self.inputBar.showPreviewReply()
    }
    
    func didTap(forward comment: CommentModel) {
        //
    }
    
    func didTap(share comment: CommentModel) {
        //
    }
    
    func didTap(info comment: CommentModel) {
        //
    }
    
    func didTap(delete comment: CommentModel) {
        QiscusCore.shared.deleteMessage(uniqueIDs: [comment.uniqId], type: .forEveryone, onSuccess: { (commentsModel) in
            print("success delete comment for everyone")
        }) { (error) in
            print("failed delete comment for everyone")
        }
    }
    
    func didTap(deleteForMe comment: CommentModel) {
        QiscusCore.shared.deleteMessage(uniqueIDs: [comment.uniqId], type: DeleteType.forMe, onSuccess: { (commentsModel) in
            print("success delete comment for me")
        }) { (error) in
            print("failed delete comment for me \(error.message)")
        }
    }
}
