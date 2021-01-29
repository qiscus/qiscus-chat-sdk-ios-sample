//
//  LoginQRController.swift
//  qiscus-sdk-ios-sample-v2
//
//  Created by UziApel on 17/07/18.
//  Copyright © 2018 Qiscus Technology. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyJSON

class LoginViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        self.title = "Scan Your QR Code Here"
        view.backgroundColor = UIColor.black
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
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        
        
        captureSession.startRunning()
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
        let payload = JSON.init(parseJSON: code)
        print("arief check ini \(payload)")
        let appId = payload["app_id"].stringValue
        let identityToken = payload["identity_token"].stringValue
        let qismo_key = payload["qismo_key"].stringValue
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
        
        UserDefaults.standard.setLongLivedToken(value: longLiveToken)
        UserDefaults.standard.setAuthenticationToken(value: qismoToken)
        UserDefaults.standard.setUserType(value: userTypeInt)
        let app = UIApplication.shared.delegate as! AppDelegate
        app.validateUserToken(appId: appId,identityToken: identityToken, qismo_key : qismo_key)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
