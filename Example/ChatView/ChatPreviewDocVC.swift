//
//  ChatPreviewDocVC.swift
//  qonsultant
//
//  Created by Ahmad Athaullah on 7/27/16.
//  Copyright © 2016 qiscus. All rights reserved.
//

import UIKit
import WebKit
import SwiftyJSON
import QiscusCore

class ChatPreviewDocVC: UIViewController, UIWebViewDelegate, WKNavigationDelegate {
    @IBOutlet weak var heightProgressViewCons: NSLayoutConstraint!
    @IBOutlet weak var labelProgress: UILabel!
    @IBOutlet weak var progressViewShare: UIView!
    @IBOutlet weak var containerProgressView: UIView!
    var webView = WKWebView()
    var url: String = ""
    var fileName: String = ""
    var progressView = UIProgressView(progressViewStyle: UIProgressView.Style.bar)
    var roomName:String = ""
    
    var accountLinking = false
    var accountData:JSON?
    var accountLinkURL:String = ""
    var accountRedirectURL:String = ""
    let maxProgressHeight:Double = 40
    deinit{
//        self.webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    // MARK: - UI Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        UIBarButtonItem.appearance().setTitleTextAttributes([.foregroundColor: ColorConfiguration.defaultColorGreen], for: .normal)
        
        UIButton.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = ColorConfiguration.defaultColorGreen
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = ColorConfiguration.defaultColorGreen
        
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.backgroundColor = ColorConfiguration.defaultColorGreen
        
        self.navigationController?.navigationBar.barTintColor = ColorConfiguration.defaultColorGreen
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: ColorConfiguration.defaultColorGreen]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Light", size: 14)! ]
        self.navigationController?.navigationBar.barTintColor = ColorConfiguration.defaultColorGreen
        
        self.webView.navigationDelegate = self
//        self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: NSKeyValueObservingOptions.new, context: nil)
        if !self.accountLinking {
            let shareButton = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(ChatPreviewDocVC.share))
            shareButton.tintColor = ColorConfiguration.defaultColorGreen
            self.navigationItem.rightBarButtonItem = shareButton
            
        }
        
        let backButton = self.backButton(self, action: #selector(ChatPreviewDocVC.goBack))
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.leftBarButtonItems = [backButton]
        
        self.progressViewShare.layer.cornerRadius = self.progressViewShare.frame.size.height / 2
        self.containerProgressView.layer.cornerRadius = self.containerProgressView.frame.size.height / 2
        self.labelProgress.layer.cornerRadius = self.labelProgress.frame.size.height / 2
    }
    
    private func backButton(_ target: UIViewController, action: Selector) -> UIBarButtonItem{
        let backIcon = UIImageView()
        backIcon.contentMode = .scaleAspectFit
        
        let image = UIImage(named: "ic_back")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        backIcon.image = image
        backIcon.tintColor = ColorConfiguration.defaultColorGreen
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: NSKeyValueObservingOptions.new, context: nil)
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        
        if !accountLinking {
            self.navigationItem.setTitleWithSubtitle(title: self.roomName, subtitle: self.fileName)
        }else{
            if let data = accountData {
                self.title = data["params"]["view_title"].string ?? self.roomName
                self.accountLinkURL = data["url"].string ?? "https://"
                self.accountRedirectURL = data["redirect_url"].string ?? "https://"
            }
        }
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(webView)
        self.view.addSubview(progressView)
        
        let constraints = [
            NSLayoutConstraint(item: webView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: webView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: webView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.progressView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.progressView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.progressView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0)
            
        ]
        view.addConstraints(constraints)
        view.layoutIfNeeded()
        
        //self.webView.backgroundColor = UIColor.red
        
        if self.url.isEmpty == true || self.url == nil {
            self.url = "https://"
        }
        
        if !self.accountLinking{
            if let openURL = URL(string: self.url.replacingOccurrences(of: " ", with: "%20")){
                self.webView.load(URLRequest(url: openURL))
                
                
                
            }
        }else{
            if let openURL = URL(string:  self.accountLinkURL.replacingOccurrences(of: " ", with: "%20")) {
                self.webView.load(URLRequest(url: openURL))
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.progressView.removeFromSuperview()
        super.viewWillDisappear(animated)
        self.webView.removeObserver(self, forKeyPath: "estimatedProgress")
        UIBarButtonItem.appearance().setTitleTextAttributes([.foregroundColor: ColorConfiguration.defaultColorGreen], for: .normal)
        UIButton.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = ColorConfiguration.defaultColorGreen
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = ColorConfiguration.defaultColorGreen
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - WebView Delegate
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let objectSender = object as? WKWebView {
            if (keyPath! == "estimatedProgress") && (objectSender == self.webView) {
                progressView.isHidden = self.webView.estimatedProgress == 1
                progressView.setProgress(Float(self.webView.estimatedProgress), animated: true)
            }else{
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            }
        }else{
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int(0.2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
            self.progressView.progress = 0.0
        }
        
        if self.fileExtension(fromURL: url) == "gif"{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 ) { [weak self] in
                    self?.centerContentIfRequired()
                }
        }
    }
    
    private func centerContentIfRequired(){
        //
        let checkSize = webView.scrollView.contentSize
        
        // Check if PDF height is less than 50% of screen height
        // or any logic you want
        if checkSize.height < UIScreen.main.bounds.height
        {
            let offsetY = (checkSize.height / 2.0) - webView.center.y
            webView.scrollView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: false)
            webView.scrollView.isScrollEnabled = false
            webView.isHidden = false
        }
    }
    
    func fileExtension(fromURL url:String) -> String{
        var ext = ""
        if url.range(of: ".") != nil{
            let fileNameArr = url.split(separator: ".")
            ext = String(fileNameArr.last!).lowercased()
            if ext.contains("?"){
                let newArr = ext.split(separator: "?")
                ext = String(newArr.first!).lowercased()
            }
        }
        return ext
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int(0.2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
            self.progressView.progress = 0.0
            //self.setupTableMessage(error.localizedDescription)
        }
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(WKNavigationActionPolicy.allow)
        if self.accountLinking {
            if let urlToLoad = webView.url {
                let urlString = urlToLoad.absoluteString
                if urlString == self.accountRedirectURL.replacingOccurrences(of: " ", with: "%20") {
                    let _ = self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.progressView.isHidden = true
        
    }
    
    // MARK: - Navigation
    @objc func goBack(_ sender: AnyObject) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    @objc func share(){
        self.navigationItem.rightBarButtonItem = nil
        UIBarButtonItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.systemBlue], for: .normal)
        
        UIButton.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = UIColor.systemBlue
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = UIColor.systemBlue
        
        self.view.bringSubviewToFront(self.containerProgressView)
        self.containerProgressView.isHidden = false
        self.labelProgress.isHidden = false
        self.progressViewShare.isHidden = false
        self.labelProgress.text = "0 %"
        var progressCount = 0
        if let url = URL(string: url) {
            DispatchQueue.global(qos: .background).sync {
                QiscusCore.shared.download(url: url) { path in
                    
                    DispatchQueue.main.async {
                        self.containerProgressView.isHidden = true
                        self.labelProgress.isHidden = true
                        self.progressViewShare.isHidden = true
                        
                        
                        if !self.accountLinking {
                            let shareButton = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(ChatPreviewDocVC.share))
                            shareButton.tintColor = ColorConfiguration.defaultColorGreen
                            self.navigationItem.rightBarButtonItem = shareButton
                            
                        }
                        
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
                            self.labelProgress.text = "\(Int(progress * 100)) %"
                            self.heightProgressViewCons.constant = CGFloat(50)
                            UIView.animate(withDuration: 0.65, animations: {
                                self.progressViewShare.layoutIfNeeded()
                            })
                        }
                    }
                }
            }
        }
    }
}
