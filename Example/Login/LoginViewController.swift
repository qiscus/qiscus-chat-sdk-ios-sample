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
        ///{"data":{"identity_token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiIsInZlciI6InYyIn0.eyJpc3MiOiJha28tOXRweW51Nmt4YWxhazFoZ3giLCJwcm4iOiJha28tOXRweW51Nmt4YWxhazFoZ3hfYWRtaW5AcWlzbW8uY29tIiwiaWF0IjoxNjAzODQ2MTU1LCJuYmYiOjE2MDM4NDYxNTUsImV4cCI6MTYwMzg0NjI3NSwibmNlIjoid0VlYmxKT25BUE95aWFtZXA0OWNBMGxqalhqd1hrWThEM1A3ekxaOSIsIm5hbWUiOiJRaXNjdXMgU3VwcG9ydCIsImF2YXRhcl91cmwiOiIifQ.bV-wSTrzeO2obc6I2sIp03HcQ7olf-gaYtXi-HmWdQU","qismo_key":"cmBmUg"}}}
        //let payload = JSON.init(parseJSON: code)
//        let appId = "ako-9tpynu6kxalak1hgx"//payload["app_id"].stringValue
//        let identityToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiIsInZlciI6InYyIn0.eyJpc3MiOiJha28tOXRweW51Nmt4YWxhazFoZ3giLCJwcm4iOiJha28tOXRweW51Nmt4YWxhazFoZ3hfYWRtaW5AcWlzbW8uY29tIiwiaWF0IjoxNjAzODQ2MTU1LCJuYmYiOjE2MDM4NDYxNTUsImV4cCI6MTYwMzg0NjI3NSwibmNlIjoid0VlYmxKT25BUE95aWFtZXA0OWNBMGxqalhqd1hrWThEM1A3ekxaOSIsIm5hbWUiOiJRaXNjdXMgU3VwcG9ydCIsImF2YXRhcl91cmwiOiIifQ.bV-wSTrzeO2obc6I2sIp03HcQ7olf-gaYtXi-HmWdQU"//payload["identity_token"].stringValue
//        let qismo_key = "cmBmUg"//payload["qismo_key"].stringValue
//        let longLiveToken = ""//payload["long_lived_token"].stringValue
        
        let payload = JSON.init(parseJSON: code)
        let appId = payload["app_id"].stringValue
        let identityToken = payload["identity_token"].stringValue
        let qismo_key = payload["qismo_key"].stringValue
        let longLiveToken = payload["long_lived_token"].string ?? ""
        let qismoToken = payload["qismo_token"].string ?? ""
        UserDefaults.standard.setLongLivedToken(value: longLiveToken)
        UserDefaults.standard.setAuthenticationToken(value: qismoToken)
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
