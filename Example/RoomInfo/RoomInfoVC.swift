//
//  RoomInfoVC.swift
//  Example
//
//  Created by Qiscus on 05/03/19.
//  Copyright © 2019 Qiscus. All rights reserved.
//

import UIKit
import QiscusCore
import Photos
import MobileCoreServices
import Alamofire
import AlamofireImage
import SwiftyJSON

class RoomInfoVC: UIViewController {
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var lbRoomName: UILabel!
    @IBOutlet weak var btIconEditName: UIButton!
    @IBOutlet weak var btIconAvatar: UIButton!
    @IBOutlet weak var lbChannelType: UILabel!
    @IBOutlet weak var lbAdditionalInformationCount: UILabel!
    @IBOutlet weak var lbUserID: UILabel!
    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var maxUploadSizeInKB:Double = Double(100) * Double(1024)
    var lastAvatarURL: URL? = nil
    var room : RoomModel? = nil
    var participants = [MemberModel]()
    var isChannelWA : Bool = false
    var isPhoneNumberWa : String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupRoomInfo()
    }

    @IBAction func addParticipant(_ sender: Any) {
        if let room = self.room{
            let vc = CreateNewGroupVC()
            vc.fromRoomInfo = true
            vc.roomID = room.id
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func clickAddtionalInformation(_ sender: Any) {
        
    }
    
    @IBAction func clickNotes(_ sender: Any) {
        
    }
    
    @IBAction func changeRoomAvatar(_ sender: Any) {
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
        
        if let presenter = optionMenu.popoverPresentationController {
            presenter.sourceView = btIconAvatar
            presenter.sourceRect = btIconAvatar.bounds
        }
        
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    @IBAction func changeRoomName(_ sender: Any) {
        let vc = EditRoomNameVC()
        vc.room = room
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setupRoomInfo(){
        if let room = self.room{
            //always check from local db
            if let room = QiscusCore.database.room.find(id: room.id){
                self.lbRoomName.text = room.name
                
                if let avatar = room.avatarUrl {
                    if avatar.absoluteString.contains("https://image.flaticon.com/icons/svg/145/145867.svg") == true{
                        self.ivAvatar.af_setImage(withURL: URL(string:"https://d1edrlpyc25xu0.cloudfront.net/ziv-nqsjtf0zdqf6kfk7s/image/upload/w_320,h_320,c_limit/r7byw7m9e4/default-wa.png")!)
                    }else{
                        self.ivAvatar.af_setImage(withURL: room.avatarUrl ?? URL(string: "http://")!)
                    }
                }else{
                    self.ivAvatar.af_setImage(withURL: room.avatarUrl ?? URL(string: "http://")!)
                }
                
                if let participants = room.participants{
                    self.participants = participants
                }
            }
            
            self.tableView.reloadData()
            
            //load from rest
            QiscusCore.shared.getParticipant(roomUniqeId: (self.room?.uniqueId)!, onSuccess: { (participants) in
                self.participants.removeAll()
                self.participants = participants
                self.tableView.reloadData()
                
            }, onError: { (error) in
                //error
            })
            
            
            if !room.options!.isEmpty{
                let json = JSON.init(parseJSON: room.options!)
                print("check ini =\(json)")
                let channelType = json["channel"].string ?? "qiscus"
                if channelType.lowercased() == "qiscus"{
                    self.btIconAvatar.setImage(UIImage(named: "ic_qiscus"), for: .normal)
                    self.lbChannelType.text = "Qiscus Widget"
                }else if channelType.lowercased() == "telegram"{
                    self.btIconAvatar.setImage(UIImage(named: "ic_telegram"), for: .normal)
                    self.lbChannelType.text = "Telegram"
                }else if channelType.lowercased() == "line"{
                    self.btIconAvatar.setImage(UIImage(named: "ic_line"), for: .normal)
                    self.lbChannelType.text = "Line"
                }else if channelType.lowercased() == "fb"{
                    self.btIconAvatar.setImage(UIImage(named: "ic_fb"), for: .normal)
                     self.lbChannelType.text = "Facebook"
                }else if channelType.lowercased() == "wa"{
                    self.btIconAvatar.setImage(UIImage(named: "ic_wa"), for: .normal)
                    self.isChannelWA = true
                    self.lbChannelType.text = "WhatsApp"
                }else{
                    self.btIconAvatar.setImage(UIImage(named: "ic_qiscus"), for: .normal)
                    self.lbChannelType.text = "Qiscus Widget"
                }
                
            }
            
            self.lbAdditionalInformationCount.layer.cornerRadius = self.lbAdditionalInformationCount.frame.size.width / 2
            self.lbAdditionalInformationCount.clipsToBounds = true
            
            self.getCustomerInfo()
            
        }
    }
    
    func getCustomerInfo(){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v1/qiscus/room/\(room!.id)/user_info", method: .get, parameters: nil, headers: header as! HTTPHeaders).responseJSON { (response) in
            print("response call \(response)")
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //failed
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.getCustomerInfo()
                            } else {
                                return
                            }
                        }
                    }
                } else {
                    //success
                    let json = JSON(response.result.value)
                    print("response.result.value =\(json)")
                    var data = json["data"]["extras"].dictionary
                    var userID = json["data"]["user_id"].string ?? ""
                    var channelName = json["data"]["channel_name"].string ?? ""
                    
                    if let userType = UserDefaults.standard.getUserType(){
//                        if userType == 2 {
//                            if self.isChannelWA == true {
//                                self.isPhoneNumberWa = userID
//                                self.lbUserID.text = self.starifyNumber(number: userID)
//                            }else{
//                                self.lbUserID.text = userID
//                            }
//
//                            self.tableView.reloadData()
//                        }else{
                            //admin / supervisor
                            self.lbUserID.text = userID
                        //}
                    }
                   
                    if !channelName.isEmpty && self.lbChannelType.text != nil {
                         self.lbChannelType.text = "\(self.lbChannelType.text!) - \(channelName)"
                    }
                   
                    if let dataUser = data {
                        let userProperties = dataUser["user_properties"]?.array
                        var count = 0
                        if let countAdditional = userProperties{
                            count = countAdditional.count
                        }
                        
                        self.lbAdditionalInformationCount.text = "\(count)"
                    }
 
                    print("response.result.value2 =\(data)")
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
            } else {
                //failed
            }
        }
    }
    
    func starifyNumber(number: String) -> String {
        let intLetters = number.prefix(number.count - 5)
        let endLetters = number.suffix(0)
        
        let numberOfStars = number.count - (intLetters.count + endLetters.count)
        var starString = ""
        for _ in 1...numberOfStars {
            starString += "*"
        }
        let finalNumberToShow: String = intLetters + starString + endLetters
        return finalNumberToShow
    }
    
    func setupUI(){
        //setup navigationBar
        self.title = "Chat & Customer Info"
        let backButton = self.backButton(self, action: #selector(ProfileVC.goBack))
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.leftBarButtonItems = [backButton]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 7/255, green: 185/255, blue: 155/255, alpha: 1)]
        
        //table view
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "ContactCell", bundle: nil), forCellReuseIdentifier: "ContactCellIdentifire")
        
        //setup color icon
        btIconEditName.tintColor = UIColor(red: 106/255, green: 106/255, blue: 106/255, alpha: 1)
        
        btIconEditName.setImage(UIImage(named: "ic_edit")?.withRenderingMode(.alwaysTemplate), for: .normal)
        
        loadingIndicator.isHidden = true
    }
    
    private func backButton(_ target: UIViewController, action: Selector) -> UIBarButtonItem{
        let backIcon = UIImageView()
        backIcon.contentMode = .scaleAspectFit
        
        let image = UIImage(named: "ic_back")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        backIcon.image = image
        backIcon.tintColor = UIColor(red: 39/255, green: 182/255, blue: 157/255, alpha: 1)
        
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

extension RoomInfoVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.participants.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCellIdentifire", for: indexPath) as! ContactCell
        
        let contact = self.participants[indexPath.row]
        cell.configureWithData(contact: contact, isPhoneNumberWa: self.isPhoneNumberWa)
        
        let image = UIImage(named: "ar_cancel")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        cell.ivCheck.image = image
        cell.ivCheck.tintColor = UIColor.red
        cell.ivCheck.backgroundColor = UIColor.clear
        cell.ivCheck.isHidden = true
        cell.roomId = self.room?.id
        cell.delegate = self
        cell.removeParticipant = true
        
        self.tableView.tableFooterView = UIView()
        
        return cell
    }
}

extension RoomInfoVC : ContactCellDelegate {
    func reloadTableView() {
        QiscusCore.shared.getParticipant(roomUniqeId: (self.room?.uniqueId)!, onSuccess: { (participants) in
            let alertController = UIAlertController(title: "Success", message: "Success remove participant", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { alert -> Void in
                self.participants.removeAll()
                self.participants = participants
                self.tableView.reloadData()
            })
            
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true) {
                
            }
            
        }, onError: { (error) in
            //error
        })
    }
}


// Image Picker
extension RoomInfoVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
                    QiscusCore.shared.updateRoom(withID: (self.room?.id)!, name: nil, avatarURL: fileURL.url, options: nil, onSuccess: { (roomModel) in
                        self.loadingIndicator.stopAnimating()
                        self.loadingIndicator.isHidden = true
                        self.ivAvatar.af_setImage(withURL: roomModel.avatarUrl!)
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

