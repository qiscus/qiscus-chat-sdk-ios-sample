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

    public var mediaURL = "https://"
    var pathURL : URL = URL(string : "https://")!
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
    }
    
    func setupUI() {
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 7/255, green: 185/255, blue: 155/255, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

        self.navigationItem.setTitleWithSubtitle(title: "Play Audio", subtitle: "")
        
        let shareButton = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(PlayOgaVC.share))
        self.navigationItem.rightBarButtonItem = shareButton
    }

    func setupAudio() {
        self.uiVIew.layer.cornerRadius = 16
        self.lbTime.text = "Play"
        mediaplayer.delegate = self
        mediaplayer.drawable = self.view

        self.togglePlayButton.setBackgroundImage(UIImage(named: "play_audio")?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.togglePlayButton.tintColor = UIColor(red: 39/255, green: 182/255, blue: 157/255, alpha: 1)

        QiscusCore.shared.download(url: URL(string: self.mediaURL)!, onSuccess: { (url) in
            self.pathURL = url
            self.navigationItem.setTitleWithSubtitle(title: "Play Audio", subtitle: url.lastPathComponent)
            self.mediaplayer.media = VLCMedia(url: url)
        }) { (progress) in

        }

    }
    
    @objc func share(){
        if let url = URL(string: mediaURL) {
            let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }
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

