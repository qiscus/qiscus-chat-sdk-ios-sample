//
//  OverallAgentPerformance.swift
//  Example
//
//  Created by Qiscus on 05/07/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import WebKit
import Alamofire
import SwiftyJSON

class OverallAgentPerformance: UIViewController, IndicatorInfoProvider, UIWebViewDelegate, WKNavigationDelegate {
    var webView = WKWebView()
    var progressView = UIProgressView(progressViewStyle: UIProgressView.Style.bar)
    
    // MARK: - IndicatorInfoProvider
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Agent Performance")
    }
    
    
//    deinit{
//        self.webView.removeObserver(self, forKeyPath: "estimatedProgress")
//    }
    // MARK: - UI Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
       
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
        
        self.getURL()
        
        
    }
    
    func getURL(){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        
        let param = ["app_code": UserDefaults.standard.getAppID() ?? "",
                     "type" : "agent-performance"
        ] as [String : Any]
        
        
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v1/analytics", method: .get, parameters: param, headers: header as! HTTPHeaders).responseJSON { (response) in
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //error
                    
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.getURL()
                            } else {
                                //failed
                                self.showAlert(code: "failed refresh token")
                            }
                        }
                    }else{
                        //failed
                        self.showAlert(code: "\((response.response?.statusCode)!)")
                    }
                    
                } else {
                    //success
                    let payload = JSON(response.result.value)
                    let url = payload["data"]["analytics_url"].string ?? "https://"
                    
                    self.webView.load(URLRequest(url: URL(string: url)!))
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
                self.showAlert(code: "\((response.response?.statusCode)!)")
            } else {
                //failed
                self.showAlert()
            }
        }
    }
    
    func showAlert(code : String = ""){
        let vc = AlertAMFailedUpdate()
        vc.errorMessage = "Something when wrong \(code)"
        vc.modalPresentationStyle = .overFullScreen
        
        self.navigationController?.present(vc, animated: false, completion: {
            
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.webView.navigationDelegate = self
        self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: NSKeyValueObservingOptions.new, context: nil)
        
        self.webView.removeObserver(self, forKeyPath: "estimatedProgress")
        self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.progressView.removeFromSuperview()
        super.viewWillDisappear(animated)
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
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int(0.2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
            self.progressView.progress = 0.0
            //self.setupTableMessage(error.localizedDescription)
        }
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.progressView.isHidden = true
        
    }
}
