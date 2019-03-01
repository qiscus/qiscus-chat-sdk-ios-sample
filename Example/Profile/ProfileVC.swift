//
//  ProfileVC.swift
//  Example
//
//  Created by Qiscus on 28/02/19.
//  Copyright © 2019 Qiscus. All rights reserved.
//

import UIKit
import QiscusCore
import AlamofireImage
import Photos
import MobileCoreServices

class ProfileVC: UIViewController {

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var lbUniqueID: UILabel!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var ivIconLogout: UIImageView!
    @IBOutlet weak var ivIconUniqueID: UIImageView!
    @IBOutlet weak var ivIconName: UIImageView!
    @IBOutlet weak var btIconEditName: UIButton!
    @IBOutlet weak var btIconAvatar: UIButton!
    @IBOutlet weak var ivAvatar: UIImageView!
    var maxUploadSizeInKB:Double = Double(100) * Double(1024)
    var fromEditNameVC : Bool = false
    var lastAvatarURL: URL? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupProfile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(fromEditNameVC == true){
           self.fromEditNameVC = false
           self.setupProfile()
        }
    }
    
    func setupProfile(){
        //load fromDB
        if let profile = QiscusCore.getProfile(){
            self.lbName.text = profile.username
            self.lbUniqueID.text = profile.email
            self.ivAvatar.af_setImage(withURL: profile.avatarUrl)
            self.lastAvatarURL = profile.avatarUrl
        }
        
        //load from server
        QiscusCore.shared.getProfile(onSuccess: { (profile) in
            self.lbName.text = profile.username
            self.lbUniqueID.text = profile.email
            self.ivAvatar.af_setImage(withURL: profile.avatarUrl)
            self.lastAvatarURL = profile.avatarUrl
        }, onError: { (error) in
            //error
        })
    }
    
    func setupUI(){
        //setup navigationBar
        self.title = "Profile"
        let backButton = self.backButton(self, action: #selector(ProfileVC.goBack))
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.leftBarButtonItems = [backButton]
        
        
        //setup color icon
        ivIconLogout.tintColor = #colorLiteral(red: 1, green: 0.231372549, blue: 0.368627451, alpha: 1)
        ivIconUniqueID.tintColor = ColorConfiguration.baseColor
        ivIconName.tintColor = ColorConfiguration.baseColor
        btIconEditName.tintColor = #colorLiteral(red: 0.5921568627, green: 0.5921568627, blue: 0.5921568627, alpha: 1)
        btIconAvatar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        ivIconLogout.image = UIImage(named: "ic_logout")?.withRenderingMode(.alwaysTemplate)
        ivIconUniqueID.image = UIImage(named: "ic_id")?.withRenderingMode(.alwaysTemplate)
        ivIconName.image = UIImage(named: "ic_contact")?.withRenderingMode(.alwaysTemplate)
        btIconAvatar.setImage(UIImage(named: "ic_image_attachment")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btIconEditName.setImage(UIImage(named: "ic_edit")?.withRenderingMode(.alwaysTemplate), for: .normal)
        
        loadingIndicator.isHidden = true
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
    
    @objc func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func logout(_ sender: Any) {
        QiscusCore.logout { (error) in
//            let local = UserDefaults.standard
//            local.removeObject(forKey: "AppID")
//            local.synchronize()
            let app = UIApplication.shared.delegate as! AppDelegate
            app.auth()
        }
    }
    
    @IBAction func changeAvatar(_ sender: Any) {
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
    
    @IBAction func editName(_ sender: Any) {
        if let name = self.lbName.text {
            self.fromEditNameVC = true
            let vc = EditNameVC()
            vc.name = name
            self.navigationController?.pushViewController(vc, animated: true)
        }
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
}


// Image Picker
extension ProfileVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func showFileTooBigAlert(){
        let alertController = UIAlertController(title: "Failed to upload", message: "File too big", preferredStyle: .alert)
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
                
                self.ivAvatar.image = image
                self.loadingIndicator.isHidden = false
                self.loadingIndicator.startAnimating()
                QiscusCore.shared.upload(data: data!, filename: imageName, onSuccess: { (fileURL) in
                    QiscusCore.shared.updateProfile(username: (QiscusCore.getProfile()?.username)!, avatarUrl: fileURL.url, onSuccess: { (userModel) in
                        self.loadingIndicator.stopAnimating()
                        self.loadingIndicator.isHidden = true
                        self.ivAvatar.af_setImage(withURL: userModel.avatarUrl)
                    }, onError: { (error) in
                        //error
                        self.ivAvatar.af_setImage(withURL: self.lastAvatarURL!)
                        self.loadingIndicator.stopAnimating()
                        self.loadingIndicator.isHidden = true
                    })
                }, onError: { (error) in
                    self.ivAvatar.af_setImage(withURL: self.lastAvatarURL!)
                    self.loadingIndicator.stopAnimating()
                    self.loadingIndicator.isHidden = true
                    print("error upload avatar =\(error.message)")
                }) { (progress) in
                    print("progress upload =\(progress)")
                }
            }
        }
        
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
