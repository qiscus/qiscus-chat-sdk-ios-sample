//
//  AMProfileAvatarCell.swift
//  Example
//
//  Created by Qiscus on 09/02/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire
import QiscusCore
import Photos
import MobileCoreServices
import AVFoundation
import PhotosUI
import SwiftyJSON

protocol AMProfileAvatarCellDelegate{
    func updateAvatarURL(avatarURL: URL)
}

class AMProfileAvatarCell: UITableViewCell {
    @IBOutlet weak var btIconAvatar: UIButton!
    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    var viewVC = UIView()
    var VC = UIViewController()
    var maxUploadSizeInKB:Double = Double(100) * Double(1024)
    var lastAvatarURL: URL? = nil
    var fullName : String = ""
    var emailAddress : String = ""
    var companyName : String = ""
    var address : String = ""
    var phoneNumber : String = ""
    var dataAlterBillEmail = [String]()
    var delegate: AMProfileAvatarCellDelegate? = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ivAvatar.layer.cornerRadius = ivAvatar.frame.width/2
        btIconAvatar.layer.cornerRadius = btIconAvatar.frame.width/2
        self.loadingIndicator.isHidden = true
    }
    
    func setupData(urlImage : URL, dataFullName : String, dataEmailAddress: String, companyName: String = "", address: String = "", phoneNumber: String = "", dataAlterBillEmail : [String] = [""]){
        self.ivAvatar.af_setImage(withURL: urlImage)
        self.lastAvatarURL = urlImage
        self.fullName = dataFullName
        self.emailAddress = dataEmailAddress
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func uploadAvatarAction(_ sender: Any) {
        let popupVC = AlertMenuUploadVC()
        popupVC.width = viewVC.frame.size.width
        popupVC.topCornerRadius = 15
        popupVC.presentDuration = 0.30
        popupVC.dismissDuration = 0.30
        popupVC.shouldDismissInteractivelty = true
        popupVC.delegate = self
        VC.present(popupVC, animated: true, completion: nil)
    }
    
    func uploadCamera() {
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.authorized
        {
            DispatchQueue.main.async(execute: {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.allowsEditing = false
                picker.mediaTypes = [(kUTTypeImage as String)]
                
                picker.sourceType = UIImagePickerController.SourceType.camera
                picker.navigationBar.tintColor = #colorLiteral(red: 0.5176470588, green: 0.7607843137, blue: 0.3803921569, alpha: 1)
                self.VC.present(picker, animated: true, completion: nil)
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
                                self.VC.present(picker, animated: true, completion: nil)
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
            if #available(iOS 14, *) {
                var configuration = PHPickerConfiguration()
                configuration.selectionLimit = 1
                configuration.filter = .images
                let picker = PHPickerViewController(configuration: configuration)
                picker.delegate = self
                self.VC.present(picker, animated: true, completion: nil)
            } else {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.allowsEditing = false
                picker.sourceType = UIImagePickerController.SourceType.photoLibrary
                picker.mediaTypes = [kUTTypeImage as String]
                picker.navigationBar.tintColor = #colorLiteral(red: 0.5176470588, green: 0.7607843137, blue: 0.3803921569, alpha: 1)
                self.VC.present(picker, animated: true, completion: nil)
            }
        })
    }
    
    func showPhotoAccessAlert(){
        DispatchQueue.main.async(execute: {
            let text = TextConfiguration.sharedInstance.galeryAccessAlertText
            let cancelTxt = TextConfiguration.sharedInstance.alertCancelText
            let settingTxt = TextConfiguration.sharedInstance.alertSettingText
            QPopUpView.showAlert(withTarget: self.VC, message: text, firstActionTitle: settingTxt, secondActionTitle: cancelTxt, hiddenIconFileAttachment: true, isAlert: true,
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
        let _ = self.VC.navigationController?.popViewController(animated: true)
    }
    
    func showCameraAccessAlert(){
        DispatchQueue.main.async(execute: {
            let text = TextConfiguration.sharedInstance.cameraAccessAlertText
            let cancelTxt = TextConfiguration.sharedInstance.alertCancelText
            let settingTxt = TextConfiguration.sharedInstance.alertSettingText
            QPopUpView.showAlert(withTarget: self.VC, message: text, firstActionTitle: settingTxt, secondActionTitle: cancelTxt, hiddenIconFileAttachment: true, isAlert: true,
                                 doneAction: {
                                    self.goToIPhoneSetting()
                                 },
                                 cancelAction: {}
            )
        })
    }
    
    func changeProfileAvatar(avatarURL : URL){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        var param: [String: Any] = [
            "name": self.fullName,
            "email" : self.emailAddress,
            "avatar_url": avatarURL.absoluteString
        ]
        
        var agentAdminSpv = "admin"
        if let userType = UserDefaults.standard.getUserType(){
            if userType == 1  {
                //admin
                agentAdminSpv = "admin"
                
                param["company_name"] = self.companyName
                param["address"] = self.address
                param["phone_number"] = self.phoneNumber
                param["billing_emails"] = self.dataAlterBillEmail
            }else if userType == 2{
                //agent
                agentAdminSpv = "agent"
            }else{
                //spv
                agentAdminSpv = "agent" // using this base
            }
        }
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v1/\(agentAdminSpv)/update_profile", method: .post, parameters: param,  encoding: JSONEncoding.default, headers: header as! HTTPHeaders).responseJSON { (response) in
            print("response call \(response)")
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //failed
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                if let delegate = self.delegate {
                                    delegate.updateAvatarURL(avatarURL : avatarURL)
                                }
                                self.changeProfileAvatar(avatarURL: avatarURL)
                            } else {
                                self.loadingIndicator.stopAnimating()
                                self.loadingIndicator.isHidden = true
                                self.ivAvatar.af_setImage(withURL: self.lastAvatarURL!)
                                return
                            }
                        }
                    }else{
                        self.loadingIndicator.stopAnimating()
                        self.loadingIndicator.isHidden = true
                        self.ivAvatar.af_setImage(withURL: self.lastAvatarURL!)
                        return
                    }
                } else {
                    //success
                    self.loadingIndicator.stopAnimating()
                    self.loadingIndicator.isHidden = true
                    self.ivAvatar.af_setImage(withURL: avatarURL)
                    //show alert success
                    
                    let vc = AlertAMSuccessUpdate()
                    vc.modalPresentationStyle = .overFullScreen
                    
                    self.VC.navigationController?.present(vc, animated: false, completion: {
                        
                    })
                    
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
                self.loadingIndicator.stopAnimating()
                self.loadingIndicator.isHidden = true
                self.ivAvatar.af_setImage(withURL: self.lastAvatarURL!)
            } else {
                //failed
                self.loadingIndicator.stopAnimating()
                self.loadingIndicator.isHidden = true
                self.ivAvatar.af_setImage(withURL: self.lastAvatarURL!)
            }
        }
    }
    
}

extension AMProfileAvatarCell : AlertMenuUploadVCDelegate {
    func openCamera(){
        self.uploadCamera()
    }
    func openGallery(){
        self.uploadGalery()
    }
}


extension AMProfileAvatarCell: PHPickerViewControllerDelegate {
    @available(iOS 14, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        guard !results.isEmpty else { return }
        
        var imageName:String = "\(NSDate().timeIntervalSince1970 * 1000).jpg"
        
        let itemProviders = results.map(\.itemProvider)
        
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
                                }
                                
                                self.VC.dismiss(animated:true, completion: nil)
                                
                                picker.dismiss(animated: true, completion: {
                                    
                                })
                                
                                self.ivAvatar.image = image
                                self.loadingIndicator.isHidden = false
                                self.loadingIndicator.startAnimating()
                                QiscusCore.shared.upload(data: data!, filename: imageName, onSuccess: { (fileURL) in
                                    self.changeProfileAvatar(avatarURL: fileURL.url)
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
                }
            }
        }
    }
}


// Image Picker
extension AMProfileAvatarCell : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func showFileTooBigAlert(){
        let alertController = UIAlertController(title: "Failed to upload", message: "File too big", preferredStyle: .alert)
        let galeryActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ -> Void in }
        alertController.addAction(galeryActionButton)
        self.VC.present(alertController, animated: true, completion: nil)
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
                
                self.VC.dismiss(animated:true, completion: nil)
                
                picker.dismiss(animated: true, completion: {
                    
                })
                
                self.ivAvatar.image = image
                self.loadingIndicator.isHidden = false
                self.loadingIndicator.startAnimating()
                QiscusCore.shared.upload(data: data!, filename: imageName, onSuccess: { (fileURL) in
                    self.changeProfileAvatar(avatarURL: fileURL.url)
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
        self.VC.dismiss(animated: true, completion: nil)
    }
}

