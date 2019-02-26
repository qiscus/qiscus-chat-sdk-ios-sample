//
//  CreateNewGroupVC.swift
//  Example
//
//  Created by Qiscus on 18/02/19.
//  Copyright © 2019 Qiscus. All rights reserved.
//

import UIKit
import QiscusCore
import AlamofireImage
import UICircularProgressRing
import Photos
import MobileCoreServices

class CreateGroupInfoVC: UIViewController, UITextFieldDelegate {
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var progressRing: UICircularProgressRing!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var iconAvatarGroup: UIImageView!
    internal var userGroup: [MemberModel] = []
    var maxUploadSizeInKB:Double = Double(100) * Double(1024)
    var avatarURL:String? = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.addRecognizer()
        
        let dismissRecognizer = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        dismissRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(dismissRecognizer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(CreateGroupInfoVC.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CreateGroupInfoVC.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.5176470588, green: 0.7607843137, blue: 0.3803921569, alpha: 1)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.nameTextField.becomeFirstResponder()
    }
    
    private func setupNext(){
        let nextButton = self.nextButton(self, action: #selector(CreateGroupInfoVC.goNext))
        self.navigationItem.setRightBarButton(nextButton, animated: false)
    }
    
    private func setupUI() {
        self.title = "Group Info"
        
        let backButton = self.backButton(self, action: #selector(CreateGroupInfoVC.goBack))
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.leftBarButtonItems = [backButton]
        
        let nextButton = self.nextButton(self, action: #selector(CreateGroupInfoVC.goNext))
        self.navigationItem.rightBarButtonItems = [nextButton]
        
        //table view
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "ContactCell", bundle: nil), forCellReuseIdentifier: "ContactCellIdentifire")
        
        //MARK: - Config ring progress
        progressRing.fontColor = UIColor.white
        progressRing.innerRingWidth = 3.0
        progressRing.innerRingColor = UIColor(red: 0, green: 150/255, blue: 136/255, alpha: 1)
        progressRing.outerRingWidth = 3.0
        progressRing.outerRingColor = UIColor(red: 208/255, green: 208/255, blue: 208/255, alpha: 1)
        progressRing.isHidden = true
        
        //avatar
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height / 2
        self.iconAvatarGroup.image = UIImage(named: "ic_image_attachment")?.withRenderingMode(.alwaysTemplate)
        self.iconAvatarGroup.tintColor = UIColor.white
        
        //namaGroup textfield
        self.nameTextField.setBottomBorder()
        
    }
    
    private func backButton(_ target: UIViewController, action: Selector) -> UIBarButtonItem{
        let backIcon = UIImageView()
        backIcon.contentMode = .scaleAspectFit
        
        let image = UIImage(named: "ic_back")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        backIcon.image = image
        backIcon.tintColor = #colorLiteral(red: 0.5176470588, green: 0.7607843137, blue: 0.3803921569, alpha: 1)
        
        if UIApplication.shared.userInterfaceLayoutDirection == .leftToRight {
            backIcon.frame = CGRect(x: 0,y: 11,width: 30,height: 25)
        }else{
            backIcon.frame = CGRect(x: 22,y: 11,width: 30,height: 25)
        }
        
        let backButton = UIButton(frame:CGRect(x: 0,y: 0,width: 30,height: 44))
        backButton.addSubview(backIcon)
        backButton.addTarget(target, action: action, for: UIControl.Event.touchUpInside)
        return UIBarButtonItem(customView: backButton)
    }
    
    private func nextButton(_ target: UIViewController, action: Selector) -> UIBarButtonItem{
        let nextIcon = UIImageView()
        nextIcon.contentMode = .scaleAspectFit
        
        let image = UIImage(named: "ic_next")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        nextIcon.image = image
        nextIcon.tintColor = #colorLiteral(red: 0.5176470588, green: 0.7607843137, blue: 0.3803921569, alpha: 1)
        
        if UIApplication.shared.userInterfaceLayoutDirection == .leftToRight {
            nextIcon.frame = CGRect(x: 0,y: 11,width: 30,height: 25)
        }else{
            nextIcon.frame = CGRect(x: 22,y: 11,width: 30,height: 25)
        }
        
        let nextButton = UIButton(frame:CGRect(x: 0,y: 0,width: 30,height: 44))
        nextButton.addSubview(nextIcon)
        nextButton.addTarget(target, action: action, for: UIControl.Event.touchUpInside)
        return UIBarButtonItem(customView: nextButton)
    }
    
    @objc func goBack() {
        view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func goNext() {
        view.endEditing(true)
        if self.checkValidation() == true{
            let participants: [String] = self.userGroup.map{ $0.email}
            let title: String = self.nameTextField.text!
            
            if avatarURL?.isEmpty == true {
                QiscusCore.shared.createGroup(withName: title, participants: participants, avatarUrl: nil, onSuccess: { (room) in
                    let target = UIChatViewController()
                    target.room = room
                    self.navigationController?.pushIgnorePreviousVC(to: target, except: UIChatListViewController.self)
                }) { (error) in
                    print("error create group =\(error.message)")
                }
            }else{
                QiscusCore.shared.createGroup(withName: title, participants: participants, avatarUrl: URL(string: self.avatarURL!), onSuccess: { (room) in
                    let target = UIChatViewController()
                    target.room = room
                    self.navigationController?.pushIgnorePreviousVC(to: target, except: UIChatListViewController.self)
                }) { (error) in
                    print("error create group =\(error.message)")
                }
            }
            
           
        }
    }
    
    func checkValidation() -> Bool {
        let groupName = self.nameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if groupName.isEmpty {
            showValidation(message: "PLEASE_INSERT_GROUP_NAME", focusOn: self.nameTextField)
            return false
        } else {
            return true
        }
    }
    
    func showValidation(message: String, focusOn field: UITextField) {
        endEditing()
        //showError(message: message)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.7, execute: {
            field.becomeFirstResponder()
        })
    }
    
    private func addRecognizer() {
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(CreateGroupInfoVC.imageDidTap(_:)))
        
        self.profileImageView.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func imageDidTap(_ sender: UITapGestureRecognizer) {
        let optionMenu = UIAlertController()
        let cameraAction = UIAlertAction(title: "Take Photo", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.uploadCamera()
        })
        optionMenu.addAction(cameraAction)
        
        
        let galleryAction = UIAlertAction(title: "Image from Gallery", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.uploadGalery()
        })
        optionMenu.addAction(galleryAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            
        })
        
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func uploadCamera() {
        self.view.endEditing(true)
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.authorized
        {
            DispatchQueue.main.async(execute: {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.allowsEditing = false
                picker.mediaTypes = [(kUTTypeImage as String)]
                
                picker.sourceType = UIImagePickerController.SourceType.camera
                picker.navigationBar.tintColor = #colorLiteral(red: 0.5176470588, green: 0.7607843137, blue: 0.3803921569, alpha: 1)
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
                                picker.navigationBar.tintColor = #colorLiteral(red: 0.5176470588, green: 0.7607843137, blue: 0.3803921569, alpha: 1)
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
                    break
                default:
                    self.showPhotoAccessAlert()
                    break
                }
            })
        }else{
            self.showPhotoAccessAlert()
        }
    }
    
    func goToGaleryPicker(){
        DispatchQueue.main.async(execute: {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            picker.mediaTypes = [kUTTypeImage as String]
            picker.navigationBar.tintColor = #colorLiteral(red: 0.5176470588, green: 0.7607843137, blue: 0.3803921569, alpha: 1)
            self.present(picker, animated: true, completion: nil)
        })
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
    
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        let info                        = notification.userInfo!
        let keyboardFrame: CGRect       = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardHeight: CGFloat     = keyboardFrame.size.height
        let fieldPosition: CGFloat      = self.nameTextField.frame.origin.y
        
        if CGFloat(fieldPosition + keyboardHeight) > UIScreen.main.bounds.size.height {
            let scrollAtPosition: CGFloat = -(fieldPosition - keyboardHeight)
            
            UIView.animate(withDuration: 0.1, animations: {
                self.view.frame.origin.y = scrollAtPosition
            })
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        UIView.animate(withDuration: 0.1, animations: {
            self.view.frame.origin.y = 0
        })
    }
    
    @objc func endEditing() {
        self.view.endEditing(true)
    }
    
    
}

extension CreateGroupInfoVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var ids: [String] = userGroup.map{ $0.id }
        if let idx: Int = ids.index(of: userGroup[indexPath.row].id){
            self.userGroup.remove(at: idx)
            self.tableView.reloadData()
            
            if self.userGroup.count == 0 {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

extension CreateGroupInfoVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userGroup.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCellIdentifire", for: indexPath) as! ContactCell
 
        let contact = self.userGroup[indexPath.row]
        cell.configureWithData(contact: contact)
        
        cell.ivCheck.isHidden = false
        cell.ivCheck.layer.cornerRadius = cell.ivCheck.frame.size.height / 2
        cell.ivCheck.image = UIImage(named: "ic_cancel")?.withRenderingMode(.alwaysTemplate)
        cell.ivCheck.tintColor = UIColor.white
        cell.ivCheck.backgroundColor = UIColor.red
        
        self.tableView.tableFooterView = UIView()
        return cell
    }
}

// Image Picker
extension CreateGroupInfoVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
                
                picker.dismiss(animated: true, completion: {
                    
                })
                
                self.profileImageView.image = image
                self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height / 2
                self.iconAvatarGroup.isHidden = true
                QiscusCore.shared.upload(data: data!, filename: imageName, onSuccess: { (fileURL) in
                    self.progressRing.isHidden = true
                    self.avatarURL = fileURL.url.absoluteString
                    self.iconAvatarGroup.isHidden = false
                }, onError: { (error) in
                    self.iconAvatarGroup.isHidden = false
                    self.profileImageView.image = UIImage(named: "ic_avatar_group", in: nil, compatibleWith: nil)!
                    print("error upload avatar =\(error.message)")
                }) { (progress) in
                    self.progressRing.isHidden = false
                    self.progressRing.value = CGFloat(progress) * 100
                }  
            }
        }
        
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
