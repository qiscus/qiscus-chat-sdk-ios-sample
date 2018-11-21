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
import QiscusUI
enum QUploaderType {
    case image
    case video
}

class QiscusUploaderVC: UIViewController, UIScrollViewDelegate,UITextViewDelegate {

    @IBOutlet weak var labelUploading: UILabel!
    @IBOutlet weak var heightProgressViewCons: NSLayoutConstraint!
    @IBOutlet weak var labelProgress: UILabel!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var containerProgressView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var imageCollection: UICollectionView!
    @IBOutlet weak var inputBottom: NSLayoutConstraint!
    @IBOutlet weak var mediaCaption: UITextView!
    @IBOutlet weak var minInputHeight: NSLayoutConstraint!
    @IBOutlet weak var mediaBottomMargin: NSLayoutConstraint!
    
    var chatView:ChatViewController?
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        self.sendButton.tintColor = ColorConfiguration.topColor
        self.cancelButton.setTitle("Cancel", for: .normal)
        //self.mediaCaption.chatInputDelegate = self
        self.mediaCaption.font = UIConfiguration.chatFont
        
        imageCollection.dataSource = self
        imageCollection.delegate = self
        imageCollection.register(UINib(nibName: "MultipleImageCell", bundle:nil), forCellWithReuseIdentifier: "MultipleImageCell")
        imageCollection.backgroundColor = UIColor.clear
        imageCollection.isHidden = true
        imageCollection.allowsSelection = true
        self.deleteButton.isHidden = true
        self.sendButton.isEnabled = false
        self.sendButton.isHidden = true
        if self.fileName != nil && self.data != nil && self.imageData.count == 0 {
            QiscusCore.shared.upload(data: data!, filename: fileName!, onSuccess: { (file) in
                self.sendButton.isEnabled = true
                self.sendButton.isHidden = false
                self.labelUploading.isHidden = true
                let message = CommentModel()
                message.type = "file_attachment"
                message.payload = [
                    "url"       : file.url.absoluteString,
                    "file_name" : file.name,
                    "size"      : file.size,
                    "caption"   : ""
                ]
                message.message = "Send Attachment"
                self.imageData.append(message)
            }, onError: { (error) in
                //
            }) { (progress) in
                print("upload progress: \(progress)")
                self.labelProgress.text = "\(Int(progress * 100)) %"
                self.labelProgress.isHidden = false
                self.containerProgressView.isHidden = false
                self.progressView.isHidden = false
                
                let newHeight = progress * self.maxProgressHeight
                self.heightProgressViewCons.constant = CGFloat(newHeight)
                UIView.animate(withDuration: 0.65, animations: {
                    self.progressView.layoutIfNeeded()
                })
            }
            
        }
        
        for gesture in self.view.gestureRecognizers! {
            self.view.removeGestureRecognizer(gesture)
        }
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
    
    @IBAction func deleteImage(_ sender: UIButton) {
        sender.isHidden = self.imageData.count == 2
//        self.imageData.remove(at: self.selectedImageIndex)
//        self.selectedImageIndex = self.selectedImageIndex != 0 ? self.selectedImageIndex - 1 : 0
//        self.imageCollection.reloadData()
//        self.imageCollection.selectItem(at: IndexPath(row: self.selectedImageIndex, section: 0), animated: true, scrollPosition: .bottom)
//        self.imageView.loadAsync(fromLocalPath: (self.imageData[self.selectedImageIndex].file?.localThumbPath)!, onLoaded: { (image, _) in
//            self.imageView.image = image
//        })
    }
    @IBAction func addMoreImage(_ sender: UIButton) {
        self.goToGaleryPicker()
    }
    
//    func prepareMessageImage(){
//        QiscusCore.shared.upload(data: data!, filename: fileName!, onSuccess: { (file) in
//            let message = CommentModel()
//            message.type = "file_attachment"
//            message.payload = [
//                "url"       : file.url.absoluteString,
//                "file_name" : file.name,
//                "size"      : file.size,
//                "caption"   : ""
//            ]
//            message.message = "Send Attachment"
//        }, onError: { (error) in
//            //
//        }) { (progress) in
//            print("upload progress: \(progress)")
//        }
//    }
    
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
            
//            let firstComment = self.room!.prepareImageComment(filename: self.fileName!, caption: self.mediaCaption.value, data: self.data!)
//            self.imageData.removeFirst()
//            self.imageData.insert(firstComment, at: 0)
//            for comment in imageData {
//                self.room!.add(newComment: comment)
//                self.room!.upload(comment: comment, onSuccess: { (roomResult, commentResult) in
//
//                }, onError: { (roomResult, commentResult, error) in
//                    print("Error: \(error)")
//                })
//            }
            
           
        }
    }
    
    // MARK: - Keyboard Methode
    @objc func keyboardWillHide(_ notification: Notification){
        let info: NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        
        let animateDuration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        self.inputBottom.constant = self.imageData.count > 1 ? self.imageCollection.frame.height : 0
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
    
    func goToGaleryPicker(){
        DispatchQueue.main.async(execute: {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            picker.mediaTypes = [kUTTypeImage as String]
            self.present(picker, animated: true, completion: nil)
        })
    }
}

extension QiscusUploaderVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func showFileTooBigAlert(){
        let alertController = UIAlertController(title: "Fail to upload", message: "File too big", preferredStyle: .alert)
        let galeryActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ -> Void in }
        alertController.addAction(galeryActionButton)
        self.present(alertController, animated: true, completion: nil)
    }
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let time = Double(Date().timeIntervalSince1970)
        guard let fileType:String = info[.mediaType] as? String else { return }
            //picker.dismiss(animated: true, completion: nil)

            if fileType == "public.image"{
                var imageName:String = ""
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
                }

                if data != nil {
                    let mediaSize = Double(data!.count) / 1024.0
                    if mediaSize > maxUploadSizeInKB {
                        picker.dismiss(animated: true, completion: {
                            self.showFileTooBigAlert()
                        })
                        return
                    }
                    
                    QiscusCore.shared.upload(data: data!, filename: imageName, onSuccess: { (file) in
                        let message = CommentModel()
                        message.type = "file_attachment"
                        message.payload = [
                            "url"       : file.url.absoluteString,
                            "file_name" : file.name,
                            "size"      : file.size,
                            "caption"   : ""
                        ]
                        message.message = "Send Attachment"
                        self.imageData.append(message)
                    }, onError: { (error) in
                        //
                    }) { (progress) in
                        print("upload progress: \(progress)")
                    }

                   // imageData.append(self.generateComment(fileName: imageName, data: data!, mediaCaption: ""))
                    self.inputBottom.constant = self.imageCollection.frame.height
                    UIView.animate(withDuration: 1, delay: 0, options: UIView.AnimationOptions(), animations: {
                        self.view.layoutIfNeeded()

                    }, completion: nil)
                    picker.dismiss(animated: true, completion: nil)
                    self.imageCollection.reloadData()
                    imageCollection.isHidden = false
                    self.deleteButton.isHidden = false
                }
            }
    }
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension QiscusUploaderVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageData.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let imagePath = self.imageData[indexPath.row].file?.localThumbPath
//        self.imageView.loadAsync(fromLocalPath: imagePath!, onLoaded: { (image, _) in
//            self.imageView.image = image
//        })
//        self.selectedImageIndex = indexPath.row
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let comment = self.imageData[indexPath.row]
        //let imagePath = comment.file?.localThumbPath

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MultipleImageCell", for: indexPath) as! MultipleImageCell
//        cell.ivMedia.loadAsync(fromLocalPath: imagePath!, onLoaded: { (image, _) in
//            cell.ivMedia.image = image
//        })

        return cell
    }
}
