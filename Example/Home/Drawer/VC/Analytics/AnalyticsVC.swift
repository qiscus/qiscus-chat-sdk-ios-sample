//
//  AnalyticsVC.swift
//  Example
//
//  Created by Qiscus on 01/07/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import WebKit
import XLPagerTabStrip

class AnalyticsVC: ButtonBarPagerTabStripViewController, UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate, WKNavigationDelegate {
    @IBOutlet weak var lbSelected: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var tvSearchAgent: UITextField!
    @IBOutlet weak var tableViewSelectAnalyticsType: UITableView!
    @IBOutlet weak var heightTableViewSelectAnalyticsType: NSLayoutConstraint!
    @IBOutlet weak var viewSelectAnalytics: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewForWebView: UIView!
    @IBOutlet weak var viewNoCustomAnalytics: UIView!
    @IBOutlet weak var btContactUs: UIButton!
    @IBOutlet weak var noDataSearchAgent: UIView!
    @IBOutlet weak var lbNoCustomAnalytics: UILabel!
    
    var agentsData: [AgentModel] = [AgentModel]()
    var countSelectAnalytics = 1
    var isActiveTypeOveralAgent = false
    var isActiveCustomAnalytics = false
    var arraySelectAnalyticsType = [String]()
    var webView = WKWebView()
    var progressView = UIProgressView(progressViewStyle: UIProgressView.Style.bar)
    var urlCustomAnalytics = ""
    var isReload = false
    
    //wa
    @IBOutlet weak var btWA: UIButton!
    @IBOutlet weak var btWACredits: UIButton!
    @IBOutlet weak var viewFrontWebView: UIView!
    @IBOutlet weak var viewPager: UIView!
    var resultsWAChannelModel = [WAChannelModel]()
    @IBOutlet weak var viewWAChannels: UIView!
    @IBOutlet weak var lbWAChannels: UILabel!
    @IBOutlet weak var tableViewWAChannels: UITableView!
    @IBOutlet weak var tableViewWAChannelsHeight: NSLayoutConstraint!
    override func viewDidLoad() {
        settings.style.selectedBarHeight = 3
        settings.style.buttonBarItemLeftRightMargin = 0

        //settings.style.buttonBarBackgroundColor = UIColor.red//ColorConfiguration.defaultColorTosca
        settings.style.buttonBarItemBackgroundColor = ColorConfiguration.defaultColorTosca
        settings.style.selectedBarBackgroundColor = UIColor.white
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 15)
        
        super.viewDidLoad()

        self.setupDataWAChannels()
        self.setupNavBar()
        self.setupSearch()
        self.setupTableView()
        
        if let userType = UserDefaults.standard.getUserType(){
            if userType != 2{
                self.getListAgents()
            }else{
                self.lbNoCustomAnalytics.text = "Custom analytics is one of the services provided by Qiscus Omnichannel to support customized analytics according to your needs. Please contact your admin"
                self.btContactUs.isHidden = true
            }
        }
        
        self.btWA.layer.cornerRadius = self.btWA.layer.frame.size.height / 2
        self.btWA.backgroundColor = ColorConfiguration.defaultColorTosca
        self.btWA.setTitleColor(UIColor.white, for: .normal)
        
        self.btWACredits.layer.borderWidth = 1
        self.btWACredits.layer.borderColor = ColorConfiguration.defaultColorTosca.cgColor
        self.btWACredits.layer.cornerRadius = self.btWA.layer.frame.size.height / 2
        self.btWACredits.setTitleColor(ColorConfiguration.defaultColorTosca, for: .normal)
        self.btWACredits.backgroundColor = UIColor.white
        
        
        self.viewWAChannels.layer.shadowColor = UIColor.black.cgColor
        self.viewWAChannels.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.viewWAChannels.layer.shadowOpacity = 0.3
        self.viewWAChannels.layer.shadowRadius = 1.5
        self.viewWAChannels.layer.cornerRadius = 8
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTapWAChannels(_:)))
        viewWAChannels.addGestureRecognizer(tap)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.progressView.removeFromSuperview()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @objc func handleTapWAChannels(_ sender: UITapGestureRecognizer? = nil) {
        self.actionTableView()
    }
    
    func actionTableView(){
        if tableViewWAChannels.isHidden == true {
            self.tableViewWAChannels.isHidden = false
            self.containerView.frame = CGRect(x: self.containerView.frame.origin.x, y: self.containerView.frame.origin.y + CGFloat(self.resultsWAChannelModel.count * 50), width: self.containerView.frame.width, height: self.containerView.frame.height - 10)
        }else{
            self.tableViewWAChannels.isHidden = true
            self.containerView.frame = CGRect(x: self.containerView.frame.origin.x, y: self.containerView.frame.origin.y - CGFloat(self.resultsWAChannelModel.count * 50), width: self.containerView.frame.width, height: self.containerView.frame.height - 10)
        }
    }
    
    func hideWAchannel(){
        self.btWA.isHidden = true
        self.btWACredits.isHidden = true
        
        self.btWA.layer.cornerRadius = self.btWA.layer.frame.size.height / 2
        self.btWA.backgroundColor = ColorConfiguration.defaultColorTosca
        self.btWA.setTitleColor(UIColor.white, for: .normal)
        
        self.btWACredits.layer.borderWidth = 1
        self.btWACredits.layer.borderColor = ColorConfiguration.defaultColorTosca.cgColor
        self.btWACredits.layer.cornerRadius = self.btWA.layer.frame.size.height / 2
        self.btWACredits.setTitleColor(ColorConfiguration.defaultColorTosca, for: .normal)
        self.btWACredits.backgroundColor = UIColor.white
        
        let status = UserDefaults.standard.getStatusFeatureSelfTopupCredit()
        if  status == 1{
            self.containerView.frame = CGRect(x: self.viewFrontWebView.frame.origin.x, y: self.viewFrontWebView.frame.origin.y + 40, width: self.containerView.frame.width, height: self.viewFrontWebView.frame.height - 40)
        }
    }
    
    func showWAchannel(){
        let status = UserDefaults.standard.getStatusFeatureSelfTopupCredit()
        if  status == 1{
            self.btWACredits.isHidden = false
            self.btWA.isHidden = false
            
            self.containerView.frame = CGRect(x: self.viewFrontWebView.frame.origin.x, y: self.viewFrontWebView.frame.origin.y + 105, width: self.viewFrontWebView.frame.width, height: self.viewFrontWebView.frame.height - 105)
        }else{
            self.btWACredits.isHidden = true
        }
    }
    
    @IBAction func waCreditsAction(_ sender: Any) {
        self.btWACredits.layer.cornerRadius = self.btWACredits.layer.frame.size.height / 2
        self.btWACredits.backgroundColor = ColorConfiguration.defaultColorTosca
        self.btWACredits.setTitleColor(UIColor.white, for: .normal)
        
        self.btWA.layer.borderWidth = 1
        self.btWA.layer.borderColor = ColorConfiguration.defaultColorTosca.cgColor
        self.btWA.layer.cornerRadius = self.btWA.layer.frame.size.height / 2
        self.btWA.setTitleColor(ColorConfiguration.defaultColorTosca, for: .normal)
        self.btWA.backgroundColor = UIColor.white
        
        self.containerView.frame = CGRect(x: self.viewFrontWebView.frame.origin.x, y: self.viewFrontWebView.frame.origin.y + 155, width: self.viewFrontWebView.frame.width, height: self.viewFrontWebView.frame.height - 155)
        
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "waCreditsAction"), object: nil)
    }
    
    @IBAction func waAction(_ sender: Any) {
        self.btWA.layer.cornerRadius = self.btWA.layer.frame.size.height / 2
        self.btWA.backgroundColor = ColorConfiguration.defaultColorTosca
        self.btWA.setTitleColor(UIColor.white, for: .normal)
        
        self.btWACredits.layer.borderWidth = 1
        self.btWACredits.layer.borderColor = ColorConfiguration.defaultColorTosca.cgColor
        self.btWACredits.layer.cornerRadius = self.btWA.layer.frame.size.height / 2
        self.btWACredits.setTitleColor(ColorConfiguration.defaultColorTosca, for: .normal)
        self.btWACredits.backgroundColor = UIColor.white
        
        self.containerView.frame = CGRect(x: self.viewFrontWebView.frame.origin.x, y: self.viewFrontWebView.frame.origin.y + 105, width: self.viewFrontWebView.frame.width, height: self.viewFrontWebView.frame.height - 105)
        
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "waAction"), object: nil)
    }
    
    func setupDataWAChannels(){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v2/channels", method: .get, parameters: nil, headers: header as! HTTPHeaders).responseJSON { (response) in
            print("response call \(response)")
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //failed
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.setupDataWAChannels()
                            } else {
                                
                                return
                            }
                        }
                    }else{
                        //show error
                        let error = JSON(response.result.value)["errors"].string ?? "Something wrong"
                        
                        let vc = AlertAMFailedUpdate()
                        vc.errorMessage = error
                        vc.modalPresentationStyle = .overFullScreen
                        
                        self.navigationController?.present(vc, animated: false, completion: {
                            
                        })
                    }
                } else {
                    //success
                    let json = JSON(response.result.value)
                    let waChannels = json["data"]["wa_channels"].array
                    
                    if waChannels?.count != 0 {
                        for data in waChannels! {
                            let dataWA = WAChannelModel(json: data)
                            self.resultsWAChannelModel.append(dataWA)
                        }

                        UserDefaults.standard.setSelectWAChannelsAnalytics(value: self.resultsWAChannelModel.first!.id)
                        
                        self.lbWAChannels.text = self.resultsWAChannelModel.first!.name
                        
                        self.tableViewWAChannelsHeight.constant = CGFloat(50 * self.resultsWAChannelModel.count)
                        self.tableViewWAChannels.reloadData()
                    }
                    
                    
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
            } else {
                //failed
            }
        }
    }
    
    @IBAction func contactUsAction(_ sender: Any) {
        guard let url = URL(string: "https://www.qiscus.com/contact") else {
          return //be safe
        }

        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func changeAnalyticsType(_ sender: Any) {
        if tableViewSelectAnalyticsType.isHidden == true{
            tableViewSelectAnalyticsType.isHidden = false
        }else{
            tableViewSelectAnalyticsType.isHidden = true
        }
    }
    
    func setupWebViewCustomAnalytics(){
        self.containerView.isHidden = true
        self.buttonBarView.isHidden = true
        
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        self.webView.tag = 123
        self.progressView.tag = 345
        
        if ( self.viewForWebView.viewWithTag(123) == nil ){
            self.viewForWebView.addSubview(webView)
        }
        
        if ( self.viewForWebView.viewWithTag(345) == nil ){
            self.viewForWebView.addSubview(progressView)
        }
        
        let constraints = [
            NSLayoutConstraint(item: webView, attribute: .height, relatedBy: .equal, toItem: viewForWebView, attribute: .height, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal, toItem: viewForWebView, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: webView, attribute: .width, relatedBy: .equal, toItem: viewForWebView, attribute: .width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: webView, attribute: .leading, relatedBy: .equal, toItem: viewForWebView, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.progressView, attribute: .top, relatedBy: .equal, toItem: self.viewForWebView, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.progressView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.progressView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0)
            
        ]
        self.view.addConstraints(constraints)
        self.view.layoutIfNeeded()
        
        self.webView.navigationDelegate = self
        
        if urlCustomAnalytics.isEmpty == true {
            self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: NSKeyValueObservingOptions.new, context: nil)
            self.webView.removeObserver(self, forKeyPath: "estimatedProgress")
            self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: NSKeyValueObservingOptions.new, context: nil)
            self.getURLCustomAnalaytics()
        }else{
            self.viewFrontWebView.isHidden = false
            self.viewNoCustomAnalytics.isHidden = true
            self.webView.load(URLRequest(url: URL(string: urlCustomAnalytics)!))
        }
        
    }
    
    func setupNavBar(){
        self.backButton.setImage(UIImage(named: "ic_back")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
        self.backButton.tintColor = UIColor.white
    }
    
    func setupSearch(){
        self.viewSearch.layer.borderWidth = 1
        self.viewSearch.layer.borderColor = UIColor(red: 196/255.0, green: 196/255.0, blue: 196/255.0, alpha:1.0).cgColor
        self.viewSearch.layer.cornerRadius = 4
        self.viewSelectAnalytics.layer.cornerRadius = 4
        self.btContactUs.layer.cornerRadius = self.btContactUs.frame.height / 2
        
        //textField
        self.tvSearchAgent.delegate = self
    }
    
    func setupOverallAgentAndAgentAnalytics(){
        buttonBarView.selectedBar.backgroundColor = UIColor.white
        buttonBarView.backgroundColor = ColorConfiguration.defaultColorTosca
        containerView.bounces = false
        
        self.view.backgroundColor = UIColor.white
        if #available(iOS 11.0, *) {
            self.edgesForExtendedLayout = []
        } else {
            self.edgesForExtendedLayout = []
        }
        
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)
            newCell?.label.textColor = UIColor.white
        }
        
        let buttonBarViewHeight = self.buttonBarView.frame.size.height
        buttonBarView.frame = CGRect(x: viewPager.frame.origin.x, y: viewPager.frame.origin.y - 30, width: buttonBarView.frame.width, height: buttonBarView.frame.height)
        
        
        var containerViewRect = self.viewPager.frame
        containerViewRect.origin = self.viewPager.frame.origin
        containerViewRect.size.height = containerViewRect.size.height
        
        self.containerView.frame = containerViewRect
        
        self.containerView.frame = CGRect(x: self.containerView.frame.origin.x, y: self.containerView.frame.origin.y + 14, width: self.containerView.frame.width, height: self.containerView.frame.height - 10)
        
        
        self.containerView.isHidden = false
        
        self.view.bringSubviewToFront(self.tableViewSelectAnalyticsType)
    }
    
    
    func setupTableView(){
        if let statusFeatureOverallAgentAnalytics = UserDefaults.standard.getStatusFeatureOverallAgentAnalytics(){
            if statusFeatureOverallAgentAnalytics == 1{
                self.countSelectAnalytics += 1
                self.isActiveTypeOveralAgent = true
                self.arraySelectAnalyticsType.append("Overall agent analytics")
                self.setupOverallAgentAndAgentAnalytics()
            }else{
                self.viewFrontWebView.isHidden = true
                self.containerView.isHidden = true
                self.buttonBarView.isHidden = true
            }
        }else{
            self.viewFrontWebView.isHidden = true
            self.containerView.isHidden = true
            self.buttonBarView.isHidden = true
        }
        if let userType = UserDefaults.standard.getUserType(){
            if userType != 2{
                self.arraySelectAnalyticsType.append("Analytics on each agent")
            }else{
                self.arraySelectAnalyticsType.append("Analytics agent")
                self.viewFrontWebView.isHidden = false
                self.containerView.isHidden = false
                self.buttonBarView.isHidden = false
                
                self.setupOverallAgentAndAgentAnalytics()
            }
        }else{
            self.arraySelectAnalyticsType.append("Analytics on each agent")
        }
        
        
        if let statusFeatureCustomAnalytics = UserDefaults.standard.getStatusFeatureCustomAnalytics() {
            if  statusFeatureCustomAnalytics != 2{
                self.countSelectAnalytics += 1
                self.isActiveCustomAnalytics = true
                self.arraySelectAnalyticsType.append("Custom analytics")
            }else{
                self.isActiveCustomAnalytics = false
            }
        }else{
            self.isActiveCustomAnalytics = false
        }
       
        
        //tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "AgentAnalyticsCell", bundle: nil), forCellReuseIdentifier: "AgentAnalyticsCellIdentifire")
        self.tableView.tableFooterView = UIView()
        
        
        self.tableViewSelectAnalyticsType.delegate = self
        self.tableViewSelectAnalyticsType.dataSource = self
        self.tableViewSelectAnalyticsType.register(UINib(nibName: "SelectAnalyticsCell", bundle: nil), forCellReuseIdentifier: "SelectAnalyticsCellIdentifire")
        self.tableViewSelectAnalyticsType.tableFooterView = UIView()
        
        self.tableViewWAChannels.delegate = self
        self.tableViewWAChannels.dataSource = self
        self.tableViewWAChannels.register(UINib(nibName: "SelectAnalyticsCell", bundle: nil), forCellReuseIdentifier: "SelectAnalyticsCellIdentifire")
        self.tableViewWAChannels.tableFooterView = UIView()
        
        self.heightTableViewSelectAnalyticsType.constant = CGFloat((55 * self.countSelectAnalytics))
        
        if self.countSelectAnalytics == 3 {
            self.lbSelected.text = "Overall agent analytics"
        }else{
            if let userType = UserDefaults.standard.getUserType(){
                if userType != 2{
                    self.lbSelected.text = "Overall agent analytics"
                }else{
                    self.lbSelected.text = "Analytics agent"
                }
            }else{
                self.lbSelected.text = "Overall agent analytics"
            }
            
        }
    }
    
    func searchAgents() {
        NSObject.cancelPreviousPerformRequests(withTarget: self,
                                               selector: #selector(self.getListAgents),
                                               object: nil)
        
        perform(#selector(self.getListAgents),
                with: nil, afterDelay: 0.5)
        
    }
    
    @objc func getListAgents(){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        
        let param = ["page": 1,
                     "limit": 50,
                     "search" : self.tvSearchAgent.text ?? "",
                     "scope" : "name",
                     "user_type_scope" : "agent"
        ] as [String : Any]
        
        var isAdminOrSPV = "admin"
        if let userType = UserDefaults.standard.getUserType(){
            if userType == 1  {
               //admin
                isAdminOrSPV = "admin"
            }else if userType == 2{
                //agent
                isAdminOrSPV = "admin"
            }else{
                //spv
                isAdminOrSPV = "spv"
            }
        }
        
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v2/\(isAdminOrSPV)/agents", method: .get, parameters: param, headers: header as! HTTPHeaders).responseJSON { (response) in
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //error
                    
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.getListAgents()
                            } else {
                                self.noDataSearchAgent.isHidden = false
                                return
                            }
                        }
                    }
                    
                } else {
                    //success
                    let payload = JSON(response.result.value)
                    if let agents = payload["data"]["agents"].array {
                        var results = [AgentModel]()
                        for agent in agents {
                            let data = AgentModel(json: agent)
                            results.append(data)
                        }
                        
                        self.agentsData = results
                        if self.agentsData.count == 0 {
                            self.noDataSearchAgent.isHidden = false
                        }else{
                            self.noDataSearchAgent.isHidden = true
                        }
                       
                        self.tableView.reloadData()
                        
                    }else{
                        self.noDataSearchAgent.isHidden = false
                    }
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
                self.noDataSearchAgent.isHidden = false
            } else {
                //failed
                self.noDataSearchAgent.isHidden = false
            }
        }
    }
    
    func getURLCustomAnalaytics(){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        
        let param = ["app_code": UserDefaults.standard.getAppID() ?? "",
                     "type" : "custom_analytic"
        ] as [String : Any]
        
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v1/analytics", method: .get, parameters: param, headers: header as! HTTPHeaders).responseJSON { (response) in
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //error
                    
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.getURLCustomAnalaytics()
                            } else {
                                //failed
                                self.viewFrontWebView.isHidden = true
                            }
                        }
                    }else if response.response?.statusCode == 400{
                       //show ui disable
                        self.viewFrontWebView.isHidden = true
                        self.viewNoCustomAnalytics.isHidden = false
                    }else{
                        self.viewNoCustomAnalytics.isHidden = true
                        self.viewFrontWebView.isHidden = true
                    }
                    
                } else {
                    self.viewFrontWebView.isHidden = false
                    self.viewNoCustomAnalytics.isHidden = true
                    //success
                    let payload = JSON(response.result.value)
                    let url = payload["data"]["analytics_url"].string ?? "https://"
                    self.urlCustomAnalytics = url
                    self.viewFrontWebView.isHidden = false
                    self.webView.load(URLRequest(url: URL(string: url)!))
                    
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                self.viewFrontWebView.isHidden = true
            } else {
                self.viewFrontWebView.isHidden = true
            }
        }
    }
    
    
    //tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.tableView == tableView {
            return self.agentsData.count
        }else if self.tableViewWAChannels == tableView {
            return self.resultsWAChannelModel.count
        }else{
            return countSelectAnalytics
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            let data = self.agentsData[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "AgentAnalyticsCellIdentifire", for: indexPath) as! AgentAnalyticsCell
            cell.viewAgent.layer.shadowColor = UIColor.black.cgColor
            cell.viewAgent.layer.shadowOffset = CGSize(width: 1, height: 1)
            cell.viewAgent.layer.shadowOpacity = 0.3
            cell.viewAgent.layer.shadowRadius = 1.5
            cell.viewAgent.layer.cornerRadius = 8
            cell.setupUIAgent(data: data)
            
            return cell
        }else if tableView == self.tableViewWAChannels{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectAnalyticsCellIdentifire", for: indexPath) as! SelectAnalyticsCell
            cell.lbTypeAnalytics.text = self.resultsWAChannelModel[indexPath.row].name
            cell.lbTypeAnalytics.font = UIFont.systemFont(ofSize: 14.0)
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectAnalyticsCellIdentifire", for: indexPath) as! SelectAnalyticsCell
            cell.lbTypeAnalytics.text = arraySelectAnalyticsType[indexPath.row]
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableView {
            if self.agentsData.count != 0 {
                let vc = AnalyticsAnotherAgent()
                vc.agentId = self.agentsData[indexPath.row].id
                vc.agentSDKEmail = self.agentsData[indexPath.row].sdkEmail
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else if tableView == self.tableViewWAChannels {
            if self.resultsWAChannelModel.count != 0 {
                UserDefaults.standard.setSelectWAChannelsAnalytics(value: self.resultsWAChannelModel[indexPath.row].id)
                
                self.lbWAChannels.text = self.resultsWAChannelModel[indexPath.row].name
                
                self.actionTableView()
                
                NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "waCreditsAction"), object: nil)
            }
        }else{
            let data = arraySelectAnalyticsType[indexPath.row]
            self.tableViewSelectAnalyticsType.isHidden = true
            
            if data.contains("Custom analytics") == true{
                if let statusFeatureCustomAnalytics = UserDefaults.standard.getStatusFeatureCustomAnalytics() {
                    if  statusFeatureCustomAnalytics == 1{
                        self.setupWebViewCustomAnalytics()
                        self.lbSelected.text = data
                    }else{
                        let vc = AlertDisableFeatureFilterAgent()
                        vc.errorMessage = "This feature has been disabled because it is not available in the plan that you are currently using."
                        vc.modalPresentationStyle = .overFullScreen
                        
                        self.navigationController?.present(vc, animated: false, completion: {
                            
                        })
                    }
                }else{
                    self.setupWebViewCustomAnalytics()
                    self.lbSelected.text = data
                }
               
            }else if data.contains("Analytics on each agent") == true{
                self.viewNoCustomAnalytics.isHidden = true
                self.viewFrontWebView.isHidden = true
                self.containerView.isHidden = true
                self.buttonBarView.isHidden = true
                self.lbSelected.text = data
            }else{
                self.viewNoCustomAnalytics.isHidden = true
                self.viewFrontWebView.isHidden = false
                self.containerView.isHidden = false
                self.buttonBarView.isHidden = false
                self.lbSelected.text = data
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
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
    
    
    //
    // MARK: - PagerTabStripDataSource
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let child_1 = OverallAgentGeneral()
        let child_2 = OverallAgentPerformance()
        let child_3 = OverallAgentChats()
        let child_4 = OverallAgentWA()
        child_4.vc = self
        let child_5 = OverallAgentOthers()
        let child_6 = PerformanceAgentVC()
        child_6.agentId = UserDefaults.standard.getAccountId() ?? 0
        child_6.agentSDKEmail = UserDefaults.standard.getEmailMultichannel() ?? ""
        let child_7 = ChatAgentVC()
        child_7.agentId =  UserDefaults.standard.getAccountId() ?? 0
        let child_8 = OtherAnalyticsVC()
        child_8.agentSDKEmail = UserDefaults.standard.getEmailMultichannel() ?? ""
        child_8.agentId =  UserDefaults.standard.getAccountId() ?? 0
        
        var childViewControllers = [child_1, child_2, child_3, child_4, child_5]
        
        if let userType = UserDefaults.standard.getUserType(){
            if userType != 2{
                if let statusShowWA = UserDefaults.standard.getStatusFeatureAnalyticsWA(){
                    if statusShowWA == 1 {
                        guard isReload else {
                            return [child_1, child_2, child_3, child_4, child_5]
                        }
                        childViewControllers = [child_1, child_2, child_3, child_4, child_5]
                    }else{
                        guard isReload else {
                            return [child_1, child_2, child_3, child_5]
                        }
                        childViewControllers = [child_1, child_2, child_3, child_5]
                    }
                }else{
                    guard isReload else {
                        return [child_1, child_2, child_3, child_5]
                    }
                    childViewControllers = [child_1, child_2, child_3, child_5]
                }
            }else{
                guard isReload else {
                    return [child_6, child_7, child_8]
                }
                childViewControllers = [child_6, child_7, child_8]
            }
        }else{
            guard isReload else {
                return [child_1, child_2, child_3, child_4, child_5]
            }
            childViewControllers = [child_1, child_2, child_3, child_4, child_5]
        }
        
        
        for index in childViewControllers.indices {
            let nElements = childViewControllers.count - index
            let n = (Int(arc4random()) % nElements) + index
            if n != index {
                childViewControllers.swapAt(index, n)
            }
        }
        let nItems = 1 + (arc4random() % 8)
        return Array(childViewControllers.prefix(Int(nItems)))
        
        
    }
    
    override func reloadPagerTabStripView() {
        isReload = true
        if arc4random() % 2 == 0 {
            pagerBehaviour = .progressive(skipIntermediateViewControllers: arc4random() % 2 == 0, elasticIndicatorLimit: arc4random() % 2 == 0 )
        } else {
            pagerBehaviour = .common(skipIntermediateViewControllers: arc4random() % 2 == 0)
        }
        super.reloadPagerTabStripView()
    }

}

extension AnalyticsVC : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true;
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true;
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true;
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        self.searchAgents()
        
        return true;
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
}
