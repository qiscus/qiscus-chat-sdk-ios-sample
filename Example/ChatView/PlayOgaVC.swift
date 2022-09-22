//
//  PlayOgaVC.swift
//  Example
//
//  Created by Qiscus on 23/11/20.
//  Copyright © 2020 Qiscus. All rights reserved.
//

import UIKit
import AVFoundation
import QiscusCore
import MobileVLCKit

class PlayOgaVC: UIViewController, VLCMediaPlayerDelegate {

    @IBOutlet private weak var togglePlayButton: UIButton!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var uiVIew: UIView!
    @IBOutlet weak var viewLoading: UIView!
    @IBOutlet weak var lbLoading: UILabel!
    
    public var mediaURL = "https://"
    var pathURL : URL = URL(string : "https://")!
    var actionButton = UIBarButtonItem()
    var mediaplayer = VLCMediaPlayer()
    var isPause = false
    var isPlaying = false {
        didSet {
            if isPlaying {
                self.lbTime.text = "Stop"
                self.togglePlayButton.setBackgroundImage(UIImage(named: "ic_stop")?.withRenderingMode(.alwaysTemplate), for: .normal)
                self.togglePlayButton.tintColor = UIColor(red: 39/255, green: 182/255, blue: 157/255, alpha: 1)
            } else {
                self.lbTime.text = "Play"
                self.togglePlayButton.setBackgroundImage(UIImage(named: "play_audio")?.withRenderingMode(.alwaysTemplate), for: .normal)
                self.togglePlayButton.tintColor = UIColor(red: 39/255, green: 182/255, blue: 157/255, alpha: 1)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAudio()
        setupLoading()
    }
    
    func setupUI() {
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 7/255, green: 185/255, blue: 155/255, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

        self.navigationItem.setTitleWithSubtitle(title: "Play Audio", subtitle: "")
        actionButton = self.actionButton(self, action:  #selector(PlayOgaVC.goActionButton))
        self.navigationItem.rightBarButtonItem = actionButton
    }
    
    private func actionButton(_ target: UIViewController, action: Selector) -> UIBarButtonItem{
        let menuIcon = UIImageView()
        menuIcon.contentMode = .scaleAspectFit
        
        let image = UIImage(named: "ic_dot_menu")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        menuIcon.image = image
        menuIcon.tintColor = UIColor.white
        
        menuIcon.frame = CGRect(x: 0,y: 0,width: 30,height: 30)
        
        let actionButton = UIButton(frame:CGRect(x: 0,y: 0,width: 30,height: 30))
        actionButton.addSubview(menuIcon)
        actionButton.addTarget(target, action: action, for: UIControl.Event.touchUpInside)
        return UIBarButtonItem(customView: actionButton)
    }
    
    
    func setupLoading(){
        self.uiVIew.isHidden = true
        self.viewLoading.isHidden = false
        self.lbLoading.text = "Please wait, still downloading . . ."
    }
    
    func hiddenLoading(){
        self.uiVIew.isHidden = false
        self.viewLoading.isHidden = true
    }

    func setupAudio() {
        self.uiVIew.layer.cornerRadius = 16
        self.lbTime.text = "Play"
        mediaplayer.delegate = self
        mediaplayer.drawable = self.view

        self.togglePlayButton.setBackgroundImage(UIImage(named: "play_audio")?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.togglePlayButton.tintColor = UIColor(red: 39/255, green: 182/255, blue: 157/255, alpha: 1)

        if let url = URL(string: self.mediaURL) {
            QiscusCore.shared.download(url: url, onSuccess: { (url) in
                self.pathURL = url
                DispatchQueue.main.async {
                    self.hiddenLoading()
                    self.navigationItem.setTitleWithSubtitle(title: "Play Audio", subtitle: url.lastPathComponent)
                    self.mediaplayer.media = VLCMedia(url: url)
                }
            }) { (progress) in
                DispatchQueue.main.async {
                    self.lbLoading.text = "Please wait, still downloading . . . \(Int(progress) * 100) %"
                }
                
            }
        }

    }
    
    @objc func share(){
        UIBarButtonItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.systemBlue], for: .normal)
        
        UIButton.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = UIColor.systemBlue
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = UIColor.systemBlue
        

        var progressCount = 0
        if let url = URL(string: self.mediaURL) {
            DispatchQueue.global(qos: .background).sync {
                QiscusCore.shared.download(url: url) { path in
                    
                    DispatchQueue.main.async {
                        self.hiddenLoading()
                        
                        
                        let file = [path]
                        let activityViewController = UIActivityViewController(activityItems: file, applicationActivities: nil)
                        activityViewController.popoverPresentationController?.sourceView = self.view
                        
                        self.present(activityViewController, animated: true, completion: {
                            
                        })
                    }
                    
                   
                } onProgress: { progress in
                    if progressCount < (Int(progress * 100)) {
                        progressCount = (Int(progress * 100))
                        DispatchQueue.main.async {
                            self.lbLoading.text = "Please wait . . . \(Int(progress) * 100) %"
                        }
                    }
                }
            }
        }

    }
    
    func download(){
        if let url = URL(string: mediaURL) {
            QiscusCore.shared.download(url: url) { (urlLocal) in
                self.showAlertWith(title: "Saved!", message: "File has been saved to your document in folder Qiscus Omnichannel Chat.")
            } onProgress: { (progress) in

            }
        }
    }
    
    func showAlertWith(title: String, message: String){
        DispatchQueue.main.async {
            let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.navigationController?.present(ac, animated: true, completion: {
                //success
            })
        }
        
    }
        
    
    @objc func goActionButton() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Share Audio", style: .default , handler:{ (UIAlertAction)in
            self.share()
        }))
        
        alert.addAction(UIAlertAction(title: "Download Audio", style: .default , handler:{ (UIAlertAction)in
            self.download()
        }))
        
//        alert.addAction(UIAlertAction(title: "Play Audio in VLC APP", style: .default , handler:{ (UIAlertAction)in
//            let appURL = URL(string: "vlc-x-callback://x-callback-url/stream?url=\(self.mediaURL)")!
//            let application = UIApplication.shared
//
//            if application.canOpenURL(appURL) {
//                application.open(appURL)
//            } else {
//                let urlStr = "itms-apps://itunes.apple.com/app/apple-store/id650377962"
//                if #available(iOS 10.0, *) {
//                    UIApplication.shared.open(URL(string: urlStr)!, options: [:]) { (isSuccess) in
//
//                    }
//
//                } else {
//                    UIApplication.shared.openURL(URL(string: urlStr)!)
//                }
//            }
//        }))
//
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
            
        }))
        
        
        if let presenter = alert.popoverPresentationController {
            presenter.barButtonItem = actionButton
        }
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mediaplayer.stop()
    }

    func updateTogglePlayButton() {
        if (mediaplayer.isPlaying) {
            isPlaying = true
        }else{
            isPlaying = false

        }
    }
//
    // MARK: - Actions
    @IBAction func togglePlayButtonClicked(_ sender: Any) {
        if (mediaplayer.isPlaying) {
            mediaplayer.stop()
            isPlaying = false
            isPause = true
        } else {
            self.mediaplayer.media = VLCMedia(url: pathURL)
            isPlaying = true
            isPause = false
            mediaplayer.play()
        }

    }
    
    func mediaPlayerStateChanged(_ aNotification: Notification!) {
        if mediaplayer.state == .stopped {
            isPlaying = false
            isPause = false
        }
    }
    
    func mediaPlayerTimeChanged(_ aNotification: Notification!) {
       
    }

}

