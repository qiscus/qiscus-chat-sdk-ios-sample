//
//  ScanBarcodeVC.swift
//  Example
//
//  Created by Qiscus on 29/07/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyJSON
import QiscusCore
import Alamofire

class ScanBarcodeVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var viewCamera: UIView!
    @IBOutlet weak var ivPopUpBackground: UIImageView!
    @IBOutlet weak var viewPopupHelp: UIView!
    @IBOutlet weak var btContactUs: UIButton!
    @IBOutlet weak var btHelp: UIButton!
    @IBOutlet weak var btAction: UIButton!
    @IBOutlet weak var ivTitle: UIImageView!
    @IBOutlet weak var ivIcon: UIImageView!
    @IBOutlet weak var ic_icon_seconds: UIImageView!
    @IBOutlet weak var ivIndicator: UIImageView!
    @IBOutlet weak var viewPopup: UIView!
    @IBOutlet weak var lbSubtitle: UILabel!
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    @IBOutlet weak var viewScanner: UIView!
    let defaults = UserDefaults.standard
    // show alert message while cannot connect with qiscus sdk
    var withMessage: String? {
        didSet {
            guard let message = withMessage else { return }
            if !(message.isEmpty) {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                    //self.showError(message: message)
                    
                })
            }
        }
    }
    var counter = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.checkFirstTime()
    }
    
    func checkFirstTime(){
        let firstTime = defaults.bool(forKey: "firstTimeInstall")
        
        if firstTime == true {
            self.viewPopup.isHidden = true
            self.viewScanner.isHidden = false
        }
        
    }
    
    func setupUI(){
        self.btAction.layer.cornerRadius = self.btAction.frame.height / 2
        self.btContactUs.layer.cornerRadius = self.btContactUs.frame.height / 2
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeRight.direction = .right
        self.viewPopup.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeLeft.direction = .left
        self.viewPopup.addGestureRecognizer(swipeLeft)
        
        
        self.navigationController?.setStatusBar(backgroundColor: ColorConfiguration.defaultColorTosca)
        self.navigationController?.isNavigationBarHidden = true
//        captureSession = AVCaptureSession()
//
//        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
//        let videoInput: AVCaptureDeviceInput
//
//        do {
//            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
//        } catch {
//            return
//        }
//
//        if (captureSession.canAddInput(videoInput)) {
//            captureSession.addInput(videoInput)
//        } else {
//            failed()
//            return
//        }
//
//        let metadataOutput = AVCaptureMetadataOutput()
//
//        if (captureSession.canAddOutput(metadataOutput)) {
//            captureSession.addOutput(metadataOutput)
//
//            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
//            metadataOutput.metadataObjectTypes = [.qr]
//        } else {
//            failed()
//            return
//        }
//
//        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        previewLayer.frame = view.bounds
//        previewLayer.videoGravity = .resizeAspectFill
//        view.layer.addSublayer(previewLayer)
//
//
//        //cara 1
////        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
////        previewLayer.frame = viewCamera.layer.frame
////        previewLayer.videoGravity = .resizeAspectFill
////        view.layer.addSublayer(previewLayer)
//
//        //cara2
////        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
////        previewLayer.frame = UIScreen.main.bounds
////        previewLayer.videoGravity = .resizeAspectFill
////        viewCamera.layer.addSublayer(previewLayer)
//
//
//
//        captureSession.startRunning()
//
//        self.view.bringSubviewToFront(viewPopup)
//        self.view.bringSubviewToFront(viewScanner)
//        self.view.bringSubviewToFront(viewPopupHelp)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = viewCamera.frame
        previewLayer.videoGravity = .resizeAspectFill
        viewCamera.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
        
        self.view.bringSubviewToFront(viewPopup)
        self.view.bringSubviewToFront(viewScanner)
        self.view.bringSubviewToFront(viewPopupHelp)
        
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case .right:
                if counter > 1 {
                    counter -= 1
                }
                
                self.setupCounter()
                
                print("Swiped right = \(counter)")
            case .down:
                print("Swiped down")
            case .left:
                if counter < 5 {
                    counter += 1
                }
                
                self.setupCounter()
               
                print("Swiped left = \(counter)")
            case .up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    
    func setupCounter(){
        switch counter {
            case 1:
                setupUIPopUp1()
                break;
            case 2:
                setupUIPopUp2()
                break;
            case 3:
                setupUIPopUp3()
                break
            case 4:
                setupUIPopUp4()
                break;
            case 5:
                setupUIPopUp5()
            default:
                setupUIPopUp1()
                break;
        }
    }
    
    func setupUIPopUp1(){
        self.ivPopUpBackground.tintColor = UIColor.white
        self.ivPopUpBackground.image = UIImage(named: "ic_popupview_scanner")?.withRenderingMode(.alwaysTemplate)
        self.ivPopUpBackground.backgroundColor = UIColor.white
        self.ivPopUpBackground.roundedCorners(top: true)
        
        self.ivIcon.isHidden = false
        self.ic_icon_seconds.isHidden = true
        self.ivIcon.image = UIImage(named: "ic_new_logo_multichannel")
        self.ivTitle.image = UIImage(named: "ic_popupview_title")
        self.btAction.setTitle("Next", for: .normal)
        self.ivIndicator.image = UIImage(named: "ic_popupview_scanner_indicator_first")
        self.lbSubtitle.text = "Integrate and access multiple communication channels on a single dashboard - make conversations more effective and efficient"
    }
    
    func setupUIPopUp2(){
        self.ivPopUpBackground.tintColor = UIColor(red: 230/255.0, green: 244/255.0, blue: 227/255.0, alpha: 1)
        self.ivPopUpBackground.image = UIImage(named: "ic_popupview_scanner")?.withRenderingMode(.alwaysTemplate)
        self.ivPopUpBackground.backgroundColor = UIColor(red: 230/255.0, green: 244/255.0, blue: 227/255.0, alpha: 1)
        self.ivPopUpBackground.roundedCorners(top: true)
        
        self.ivIcon.isHidden = true
        self.ic_icon_seconds.isHidden = false
        self.ic_icon_seconds.image = UIImage(named: "ic_logo_social_media")
        self.ivTitle.image = UIImage(named: "ic_social_media")
        self.btAction.setTitle("Next", for: .normal)
        self.ivIndicator.image = UIImage(named: "ic_popupview_scanner_indicator_seconds")
        self.lbSubtitle.text = "Connect your social media accounts to Qiscus Omnichannel CS Chat, receive chats from the customer and reply it directly"
    }
    
    func setupUIPopUp3(){
        self.ivPopUpBackground.tintColor = UIColor(red: 255/255.0, green: 250/255.0, blue: 236/255.0, alpha: 1)
        self.ivPopUpBackground.image = UIImage(named: "ic_popupview_scanner")?.withRenderingMode(.alwaysTemplate)
        self.ivPopUpBackground.backgroundColor = UIColor(red: 255/255.0, green: 250/255.0, blue: 236/255.0, alpha: 1)
        self.ivPopUpBackground.roundedCorners(top: true)
        self.ivIcon.isHidden = true
        self.ic_icon_seconds.isHidden = false
        self.ic_icon_seconds.image = UIImage(named: "ic_logo_filter_chat")
        self.ivTitle.image = UIImage(named: "ic_filter_chat")
        self.btAction.setTitle("Next", for: .normal)
        self.ivIndicator.image = UIImage(named: "ic_popupview_scanner_indicator_third")
        self.lbSubtitle.text = "Filter the chats by platform type or the chat status itself. Moreover, you can mark chat list as solved or pending resolution."
    }
    
    func setupUIPopUp4(){
        self.ivPopUpBackground.tintColor = UIColor(red: 239/255.0, green: 247/255.0, blue: 252/255.0, alpha: 1)
        self.ivPopUpBackground.image = UIImage(named: "ic_popupview_scanner")?.withRenderingMode(.alwaysTemplate)
        self.ivPopUpBackground.backgroundColor = UIColor(red: 239/255.0, green: 247/255.0, blue: 252/255.0, alpha: 1)
        self.ivPopUpBackground.roundedCorners(top: true)
        self.ivIcon.isHidden = true
        self.ic_icon_seconds.isHidden = false
        self.ic_icon_seconds.image = UIImage(named: "ic_logo_bot")
        self.ivTitle.image = UIImage(named: "ic_bot_text")
        self.btAction.setTitle("Next", for: .normal)
        self.ivIndicator.image = UIImage(named: "ic_popupview_scanner_indicator_four")
        self.lbSubtitle.text = "The Qiscus Omnichannel CS Chat Solution is enhanced even further by Bot Integration. It is a chatting process managed by Artificial Intelligence (AI) directly"
    }
    
    func setupUIPopUp5(){
        self.ivPopUpBackground.tintColor = UIColor.white
        self.ivPopUpBackground.image = UIImage(named: "ic_popupview_scanner")?.withRenderingMode(.alwaysTemplate)
        self.ivPopUpBackground.backgroundColor = UIColor.white
        self.ivPopUpBackground.roundedCorners(top: true)
        
        self.ivIcon.isHidden = true
        self.ic_icon_seconds.isHidden = false
        self.ic_icon_seconds.image = UIImage(named: "ic_logo_are_you_ready")
        self.ivTitle.image = UIImage(named: "ic_are_you_ready")
        self.btAction.setTitle("Let’s Start", for: .normal)
        self.ivIndicator.image = UIImage(named: "ic_popupview_scanner_indicator_five")
        self.lbSubtitle.text = "To use this app, please login to Qiscus Omnichannel Chat in your web browser, click the mobile button on the bottom left of the screen and scan the QR code."
    }
    
    @IBAction func actionContactUs(_ sender: Any) {
        guard let url = URL(string: "https://support.qiscus.com/hc/en-us/requests/new") else {
          return //be safe
        }

        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func actionClosePopupHelp(_ sender: Any) {
        self.viewPopupHelp.isHidden = true
    }
    
    @IBAction func actionBtHelp(_ sender: Any) {
        self.viewPopupHelp.isHidden = false
        self.viewPopupHelp.backgroundColor = UIColor.white
        self.viewPopupHelp.roundedCorners(top: true)
    }
    
    @IBAction func actionBtNextStart(_ sender: Any) {
        if counter == 5 {
            self.viewPopup.isHidden = true
            self.viewScanner.isHidden = false
      
            defaults.set(true, forKey: "firstTimeInstall")
        }else{
            if counter < 5 {
                counter += 1
            }
            
            self.setupCounter()
        }
    }
    
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = ColorConfiguration.defaultColorTosca
            appearance.titleTextAttributes = [.font: UIFont.boldSystemFont(ofSize: 18.0),
                                              .foregroundColor: UIColor.white]

            // Customizing our navigation bar
            navigationController?.navigationBar.tintColor =  ColorConfiguration.defaultColorTosca
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        } else {
            // Fallback on earlier versions
        }
        
        self.getLatestVersion()
    }
    
    func getLatestVersion(){
        let param : [String: Any] = ["type" : 2]
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v2/mobile_version/latest", method: .get, parameters: param, headers: nil).responseJSON { (response) in
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    print(" response.response?.statusCode \( response.response?.statusCode)")
                } else {
                    //success
                    let payload = JSON(response.result.value)
                    let data = payload["data"]["mobile_version"]
                    
                    let forceUpdate = data["force_update"].bool ?? false
                    let version = data["version"].string ?? ""
                    
                    
                    if let versionApp = Bundle.main.infoDictionary!["CFBundleShortVersionString"]{
                        if versionApp as! String != version {
                            //show
                            let vc = AlertForceUpdateVC()
                            vc.modalPresentationStyle = .overFullScreen
                            vc.isForceUpdate = forceUpdate
                            self.navigationController?.present(vc, animated: false, completion: {
                                
                            })
                        }
                    }
                    
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
            } else {
                //failed
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
        
        dismiss(animated: true)
    }
    
    func found(code: String) {
        //{"app_id":"karm-gzu41e4e4dv9fu3f","identity_token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiIsInZlciI6InYyIn0.eyJpc3MiOiJrYXJtLWd6dTQxZTRlNGR2OWZ1M2YiLCJwcm4iOiJrYXJtLWd6dTQxZTRlNGR2OWZ1M2ZfYWRtaW5AcWlzbW8uY29tIiwiaWF0IjoxNjA1MTE1MTE0LCJuYmYiOjE2MDUxMTUxMTQsImV4cCI6MTYwNTExNTIzNCwibmNlIjoibUpnd29HOFlLTjBxSHdNZXhKakZFZHZkMldQODZ2UTE3YUx4a1BxVyIsIm5hbWUiOiJLZXkgQWNjb3V0IFFpc2N1cyIsImF2YXRhcl91cmwiOiIifQ.4DOKMJ7VQ-18i8RyAr8uxgOxSKkvFs9ANmNM03_ixqc","qismo_key":"rWmq7a","qismo_url":"https://multichannel.qiscus.com/","qismo_token":"A5wmVwtjhD3CIiIlQVCA","user_type":"1","long_lived_token": "A5wmVwtjhD3CIiIlQVCA"}
        //let payload = JSON.init(parseJSON: code)
//        let appId = "karm-gzu41e4e4dv9fu3f"//payload["app_id"].stringValue
//        let identityToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiIsInZlciI6InYyIn0.eyJpc3MiOiJrYXJtLWd6dTQxZTRlNGR2OWZ1M2YiLCJwcm4iOiJrYXJtLWd6dTQxZTRlNGR2OWZ1M2ZfYWRtaW5AcWlzbW8uY29tIiwiaWF0IjoxNjA1MTE1MTE0LCJuYmYiOjE2MDUxMTUxMTQsImV4cCI6MTYwNTExNTIzNCwibmNlIjoibUpnd29HOFlLTjBxSHdNZXhKakZFZHZkMldQODZ2UTE3YUx4a1BxVyIsIm5hbWUiOiJLZXkgQWNjb3V0IFFpc2N1cyIsImF2YXRhcl91cmwiOiIifQ.4DOKMJ7VQ-18i8RyAr8uxgOxSKkvFs9ANmNM03_ixqc"//payload["identity_token"].stringValue
//        let qismo_key = "rWmq7a"//payload["qismo_key"].stringValue
//        let longLiveToken = "A5wmVwtjhD3CIiIlQVCA"//payload["long_lived_token"].stringValue
//        let qismoToken = "A5wmVwtjhD3CIiIlQVCA"
//
        
        var data = code
        
        if data.contains("version") == true {
            if let dotRange = data.range(of: "}") {
                data.removeSubrange(dotRange.lowerBound..<data.endIndex)
                data = data + "}"
                
                let payload = JSON.init(parseJSON: data)
                
                let appId = payload["app_id"].stringValue
                var qismo_url = payload["qismo_url"].stringValue
                let longLiveToken = payload["long_lived_token"].string ?? ""
                
                if qismo_url.last == "/"{
                    qismo_url.removeLast()
                }
                
                UserDefaults.standard.setLongLivedToken(value: longLiveToken)
                UserDefaults.standard.setAppID(value: appId)
                UserDefaults.standard.setBaseURL(value: qismo_url)
                
                QiscusCore.setup(WithAppID: appId)
                
                QiscusCore.getJWTNonce { nonce in
                    
                    
                    let header = ["Authorization": longLiveToken] as [String : String]
                    
                    let params = ["nonce": nonce.nonce] as [String : Any]
                    
                    Alamofire.request("\(QiscusHelper.getBaseURL())/api/v2/auth/mobile_login", method: .post, parameters: params, headers: header as! HTTPHeaders).responseJSON { (response) in
                        print("response call \(response)")
                        if response.result.value != nil {
                            if (response.response?.statusCode)! >= 300 {
                                //failed
                            } else {
                                //success
                                
                                let result = response.result.value
                                let payload = JSON(result)
                                print("check json ini =\(payload)")
                                
                                let identityToken = payload["data"]["identity_token"].stringValue
                                let qismo_key = payload["data"]["qismo_key"].stringValue
                                let qismoToken = payload["data"]["qismo_token"].string ?? ""
                                let userType = payload["data"]["user_type"].int ?? 2

                                UserDefaults.standard.setLongLivedToken(value: longLiveToken)
                                UserDefaults.standard.setAuthenticationToken(value: qismoToken)
                                UserDefaults.standard.setUserType(value: userType)
                                let app = UIApplication.shared.delegate as! AppDelegate
                                app.validateUserToken(appId: appId,identityToken: identityToken, qismo_key : qismo_key)
                               
                            }
                        } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                            //failed
                        } else {
                            //failed
                        }
                    }
                    
                } onError: { error in
                    //error get jwt nonce
                }
            }else{
                //failed
            }
        } else {
            
            let payload = JSON.init(parseJSON: data)
            
            let appId = payload["app_id"].string ?? ""
            let identityToken = payload["identity_token"].stringValue
            let qismo_key = payload["qismo_key"].stringValue
            var qismo_url = payload["qismo_url"].stringValue
           
            if qismo_url.last == "/"{
                qismo_url.removeLast()
            }
            let longLiveToken = payload["long_lived_token"].string ?? ""
            let qismoToken = payload["qismo_token"].string ?? ""
            let userType = payload["user_type"].string ?? "2"
            var userTypeInt = 2
            if userType == "2" {
                userTypeInt = 2
            } else if userType == "1"{
                userTypeInt = 1
            }else if userType == "3"{
                userTypeInt = 3
            }
            
            if appId.isEmpty == true {
                return
            }else{
                UserDefaults.standard.setAppID(value: appId)
                UserDefaults.standard.setBaseURL(value: qismo_url)
                UserDefaults.standard.setLongLivedToken(value: longLiveToken)
                UserDefaults.standard.setAuthenticationToken(value: qismoToken)
                UserDefaults.standard.setUserType(value: userTypeInt)
                let app = UIApplication.shared.delegate as! AppDelegate
                app.validateUserToken(appId: appId,identityToken: identityToken, qismo_key : qismo_key)
            }
            
            
        }

    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
