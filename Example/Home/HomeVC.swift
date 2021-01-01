//
//  HomeVC.swift
//  Example
//
//  Created by Qiscus on 13/12/20.
//  Copyright © 2020 Qiscus. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import QiscusCore
import Alamofire
import AlamofireImage
import ExpandingMenu
import SwiftyJSON


class HomeVC: ButtonBarPagerTabStripViewController {
    
    @IBOutlet weak var heightStackView: NSLayoutConstraint!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var viewSearchBar: UIView!
    @IBOutlet weak var viewNoResultSearchRoomMessage: UIView!
    @IBOutlet weak var viewAlertSearchRoomMessage: UIView!
    @IBOutlet weak var lbAlertSearchRoomMessage: UILabel!
    @IBOutlet weak var viewAlertDisableSearchRoomMessage: UIView!
    @IBOutlet weak var lbAlertDisableSearchRoomMessage: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableViewSearch: UITableView!
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var tvSearch: UITextField!
    @IBOutlet weak var bottomTableViewTagHeightConst: NSLayoutConstraint!
    @IBOutlet weak var btCloseSearch: UIButton!
    
    @IBOutlet weak var btTabCustomers: UIButton!
    @IBOutlet weak var btTabMessages: UIButton!
    
    var isReload = false
    var firstTimeLoadSearch = false
    var isTabCustomerSelected = true
    var timer : Timer?
    let sideBar = SideBar(viewModel: "SideBarViewModel")
    var defaults = UserDefaults.standard
    var searchCustomerRooms = [CustomerRoom]()
    var searchCustomerComments = [CommentModel]()
    var defaultButtonBarView = CGRect()
    var defaultContainerView = CGRect()
    
    //feature config
    var featuresData = [FeaturesModel]()
    //1 show, 2 hide, 3 disabled
    var statusSearchMessageFeature = 1
    var statusSearchRoomFeature = 1
    var alertMessageFilterActive = "Cannot perform search message while the filter is active. Please inactive the filter to continue use search messages"
    var alertMessageOtherAll = "Cannot perform search message while stay on this tab. Please going to All tab to continue use search messages"
    var alertMessageOtherOngoing = "Cannot perform search message while stay on this tab. Please going to Ongoing tab to continue use search messages"
    var alertMessageDisable = "This feature has been disabled because it is not available in the plan that you are currently using."
    
    var showGetCustomer = true
    
    override func viewDidLoad() {
        settings.style.selectedBarHeight = 3
        settings.style.buttonBarItemLeftRightMargin = 0
        
        settings.style.buttonBarBackgroundColor = UIColor.white
        settings.style.buttonBarItemBackgroundColor = UIColor.white
        settings.style.selectedBarBackgroundColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1)
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 15)
        
        super.viewDidLoad()
        self.setupUI()
        self.setupSearch()
        self.setupUINavBar()
        self.getCountCustomer()
        self.getLatestVersion()
        
        if (self.timer != nil) {
            self.timer?.invalidate()
            self.timer = nil
        }
        self.timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(getCountCustomer), userInfo: nil, repeats: true)
        
       
        RDNavigationDrawer.left(target: self, view: sideBar, percentage: 80)
        
        if UserDefaults.standard.getAfterLogin() == true {
            UserDefaults.standard.setAfterLogin(value: false)
            if let userType = UserDefaults.standard.getUserType(){
                if userType == 2 {
                    getProfileInfo()
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) { () -> Void in
            self.moveToViewController(at: self.defaults.integer(forKey: "lastTab"), animated: false)
            
            self.defaultButtonBarView = self.buttonBarView.frame
            self.defaultContainerView = self.containerView.frame
        }
    }
    
    func setupSearch(){
        self.viewSearch.layer.borderWidth = 1
        self.viewSearch.layer.borderColor = UIColor(red: 196/255.0, green: 196/255.0, blue: 196/255.0, alpha:1.0).cgColor
        self.viewSearch.layer.cornerRadius = 4
        
        //textField
        self.tvSearch.delegate = self
        self.btCloseSearch.imageEdgeInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
    }
    
    func getProfileInfo(){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v1/agent/get_profile", method: .get, parameters: nil, headers: header as! HTTPHeaders).responseJSON { (response) in
            print("response call \(response)")
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //failed
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.getProfileInfo()
                            } else {
                                return
                            }
                        }
                    }
                } else {
                    //success
                    let json = JSON(response.result.value)
                    print("response.result.value =\(json)")
                    var data = json["data"]["is_available"].bool ?? false
                    
                    //show alert
                    
                    let vc = AlertOnlineOfflineFirstLoginAgent()
                    vc.modalPresentationStyle = .overFullScreen
                    vc.isAvailable = data
                    
                    self.navigationController?.present(vc, animated: false, completion: {
                        
                    })
                    
                    
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
            } else {
                //failed
            }
        }
    }
    
    func changeToOnline(){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        
        var param: [String: Any] = [
            "is_available": true
        ]
        
        
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v1/set_availability", method: .post, parameters: param, encoding: JSONEncoding.default, headers: header as! HTTPHeaders).responseJSON { (response) in
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //error
                    
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.changeToOnline()
                            } else {
                                return
                            }
                        }
                    }
                    
                } else {
                    //success
                    
                    let vc = AlertAvailabilityAgent()
                    vc.modalPresentationStyle = .overFullScreen
                    vc.isAvailable = true
                    
                    self.navigationController?.present(vc, animated: false, completion: {
                        
                    })
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
            } else {
                //failed
            }
        }
    }
    
    func getLatestVersion(){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
       
        
        let param : [String: Any] = ["type" : 2]
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v2/mobile_version/latest", method: .get, parameters: param, headers: header as! HTTPHeaders).responseJSON { (response) in
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                   self.createFloatingButton(count: 0)
                    print(" response.response?.statusCode \( response.response?.statusCode)")
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.getLatestVersion()
                            } else {
                                return
                            }
                        }
                    }
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
    
    
    @objc func getCountCustomer(){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
       // var agentOrAdmin = "agent"
        if let userType = UserDefaults.standard.getUserType(){
            if userType == 2 {
                //agentOrAdmin = "agent"
                Alamofire.request("\(QiscusHelper.getBaseURL())/api/v2/agent/service/total_unserved", method: .get, parameters: nil, headers: header as! HTTPHeaders).responseJSON { (response) in
                    if response.result.value != nil {
                        if (response.response?.statusCode)! >= 300 {
                           self.createFloatingButton(count: 0)
                            print(" response.response?.statusCode \( response.response?.statusCode)")
                            if response.response?.statusCode == 401 {
                                RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                                    if success == true {
                                        self.getCountCustomer()
                                    } else {
                                        return
                                    }
                                }
                            }
                        } else {
                            //success
                            let payload = JSON(response.result.value)
                            let count = payload["data"]["total_unresolved"].int ?? 0
                            
                            self.createFloatingButton(count: count)
                            
                        }
                    } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                        //failed
                        self.createFloatingButton(count: 0)
                    } else {
                        //failed
                       self.createFloatingButton(count: 0)
                    }
                }
            }else if userType == 1{
                //agentOrAdmin = "admin"
                Alamofire.request("\(QiscusHelper.getBaseURL())/api/v1/admin/service/get_unresolved_count", method: .get, parameters: nil, headers: header as! HTTPHeaders).responseJSON { (response) in
                    if response.result.value != nil {
                        if (response.response?.statusCode)! >= 300 {
                           self.createFloatingButton(count: 0)
                            print(" response.response?.statusCode \( response.response?.statusCode)")
                            if response.response?.statusCode == 401 {
                                RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                                    if success == true {
                                        self.getCountCustomer()
                                    } else {
                                        return
                                    }
                                }
                            }
                        } else {
                            //success
                            let payload = JSON(response.result.value)
                            let count = payload["data"]["total_unresolved"].int ?? 0
                            
                            self.createFloatingButton(count: count)
                            
                        }
                    } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                        //failed
                        self.createFloatingButton(count: 0)
                    } else {
                        //failed
                       self.createFloatingButton(count: 0)
                    }
                }
            }else {
                //agentOrAdmin = "spv"
                Alamofire.request("\(QiscusHelper.getBaseURL())/api/v2/spv/service/total_unserved", method: .get, parameters: nil, headers: header as! HTTPHeaders).responseJSON { (response) in
                    if response.result.value != nil {
                        if (response.response?.statusCode)! >= 300 {
                           self.createFloatingButton(count: 0)
                            print(" response.response?.statusCode \( response.response?.statusCode)")
                            if response.response?.statusCode == 401 {
                                RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                                    if success == true {
                                        self.getCountCustomer()
                                    } else {
                                        return
                                    }
                                }
                            }
                        } else {
                            //success
                            let payload = JSON(response.result.value)
                            let count = payload["data"]["total_unserved"].int ?? 0
                            
                            self.createFloatingButton(count: count)
                            
                        }
                    } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                        //failed
                        self.createFloatingButton(count: 0)
                    } else {
                        //failed
                       self.createFloatingButton(count: 0)
                    }
                }
            }
        }
    }
    
    func createFloatingButton(count: Int){
        if let viewWithTag = self.view.viewWithTag(222) {
            viewWithTag.removeFromSuperview()
        }
        
        if self.viewSearch.isHidden == true || self.showGetCustomer == true {
            let button = UIButton()
            
            if UIDevice().userInterfaceIdiom == .phone {
                switch UIScreen.main.nativeBounds.height {
                case 1920, 2208:
                    button.frame = CGRect(x: self.view.frame.size.width - 105 , y: self.view.frame.size.height - 105, width: 100, height: 100)
                default:
                    button.frame = CGRect(x: self.view.frame.size.width - 80 , y: self.view.frame.size.height - 80, width: 75, height: 75)
                }
            }else{
                button.frame = CGRect(x: self.view.frame.size.width - 105 , y: self.view.frame.size.height - 105, width: 100, height: 100)
            }
            
            if let userType = UserDefaults.standard.getUserType(){
                if userType == 2 {
                    if (count == 0){
                        button.setImage(UIImage(named: "ic_agent_floating_no"), for: .normal)
                    }else{
                        button.setImage(UIImage(named: "ic_agent_floating"), for: .normal)
                    }
                }else{
                    if (count == 0){
                        button.setImage(UIImage(named: "ic_admin_floating_no"), for: .normal)
                    }else{
                        button.setImage(UIImage(named: "ic_admin_floating"), for: .normal)
                    }
                    
                }
            }else{
                button.setImage(UIImage(named: "ic_agent_floating_no"), for: .normal)
            }
            button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
            button.layer.shadowColor = UIColor(red: 0.35, green: 0.44, blue: 0.25, alpha: 0.25).cgColor
            button.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
            button.layer.shadowOpacity = 1.0
            button.layer.shadowRadius = 4
            self.view.addSubview(button)

            button.tag = 222
            self.view.addSubview(button)
            self.view.viewWithTag(222)?.bringSubviewToFront(self.view)
        }
    }
    
    @objc func buttonAction(sender: UIButton!) {
        let popupVC = UIBottomPopupVC()
        popupVC.width = self.view.frame.size.width
        popupVC.topCornerRadius = 15
        popupVC.presentDuration = 0.30
        popupVC.dismissDuration = 0.30
        popupVC.shouldDismissInteractivelty = true
        //popupVC.popupDelegate = self
        self.present(popupVC, animated: true, completion: nil)
    }
    @IBAction func closeSearchAction(_ sender: Any) {
        self.viewAlertDisableSearchRoomMessage.isHidden = true
        self.viewSearch.isHidden = true
        self.showGetCustomer = true
        self.tvSearch.text = ""
        self.tvSearch.endEditing(true)
        self.stackView.isHidden = true
        self.heightStackView.constant = 0
        self.firstTimeLoadSearch = false
        
        self.searchCustomerRooms.removeAll()
        self.tableViewSearch.reloadData()
        
        buttonBarView.frame = self.defaultButtonBarView
        self.containerView.frame = self.defaultContainerView
        self.containerView.isHidden = false
        self.tableViewSearch.isHidden = true
        self.viewNoResultSearchRoomMessage.isHidden = true
        self.loadingIndicator.isHidden = true
        self.viewSearchBar.isHidden = true
        self.showGetCustomer = true
        self.title = "Inbox"
        self.getCountCustomer()
    }
    
    func showAlert(_ title: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Keyboard Methode
    @objc func keyboardWillHide(_ notification: Notification){
        let info: NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        
        let animateDuration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        self.bottomTableViewTagHeightConst.constant = 0
        UIView.animate(withDuration: animateDuration, delay: 0, options: UIView.AnimationOptions(), animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification){
        let info:NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let keyboardSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let keyboardHeight: CGFloat = keyboardSize.height
        let animateDuration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        
        self.bottomTableViewTagHeightConst.constant = 0 - keyboardHeight
        UIView.animate(withDuration: animateDuration, delay: 0, options: UIView.AnimationOptions(), animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func setupUI(){
        NotificationCenter.default.addObserver(self, selector: #selector(HomeVC.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeVC.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.tableViewSearch.isHidden = true
        self.viewSearchBar.isHidden = true
        
        
        buttonBarView.selectedBar.backgroundColor = UIColor(red: 7/255, green: 185/255, blue: 155/255, alpha: 1)
        buttonBarView.backgroundColor = UIColor.white//UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1)
        containerView.bounces = false
        
        self.view.backgroundColor = UIColor.white//UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1)
        if #available(iOS 11.0, *) {
            self.edgesForExtendedLayout = []
        } else {
            self.edgesForExtendedLayout = []
        }
        
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.45)
            newCell?.label.textColor = UIColor(red: 7/255, green: 185/255, blue: 155/255, alpha: 1)
            
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "reloadTabs"), object: nil)
        }
        
        let attributedWithTextColor: NSAttributedString = self.alertMessageDisable.attributedStringWithColor(["disabled"], color: UIColor.black, sizeFont : 17)

        self.lbAlertDisableSearchRoomMessage.attributedText = attributedWithTextColor
        
        self.viewSearch.isHidden = true
        self.showGetCustomer = true
    }
    
    func setupUINavBar(){
        self.title = "Inbox"
        
        var buttonDrawer = UIButton(type: .custom)
        buttonDrawer.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        buttonDrawer.widthAnchor.constraint(equalToConstant: 30).isActive = true
        buttonDrawer.heightAnchor.constraint(equalToConstant: 30).isActive = true
        buttonDrawer.setImage(UIImage(named: "ic_drawer"), for: .normal)
        buttonDrawer.addTarget(self, action: #selector(openMenu), for: .touchUpInside)
        
        let barButtonDrawer = UIBarButtonItem(customView: buttonDrawer)
        
        let actionSearchButton = self.actionSearchButton(self, action: #selector(HomeVC.openSearchUI))
        let actionFilterButton = self.actionFilterButton(self, action: #selector(HomeVC.openFilter))
        let actionResolvedALLWAButton = self.actionResolvedALLWAButton(self, action: #selector(HomeVC.openResolvedALLWA))
        
        if let userType = UserDefaults.standard.getUserType(){
            if userType != 2{
                //admin //spv
                if defaults.bool(forKey: "ic_resolved_all_WA_active") != false{
                  // self.navigationItem.rightBarButtonItems = [actionFilterButton, actionSearchButton, actionResolvedALLWAButton]
                   self.navigationItem.rightBarButtonItems = [actionFilterButton, actionSearchButton]
                }else{
                    self.navigationItem.rightBarButtonItems = [actionFilterButton, actionSearchButton]
                }
            }else{
                //agent
                self.navigationItem.rightBarButtonItems = [actionFilterButton, actionSearchButton]
            }
        }else{
            self.navigationItem.rightBarButtonItems = [actionFilterButton, actionSearchButton]
        }
        
       
        
        //assign button to navigationbar
        self.navigationItem.leftBarButtonItem = barButtonDrawer
    }
    
    private func actionSearchButton(_ target: UIViewController, action: Selector) -> UIBarButtonItem{
        let menuIcon = UIImageView()
        menuIcon.contentMode = .scaleAspectFit
        
        let image = UIImage(named: "ic_search_normal")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        menuIcon.image = image
        menuIcon.tintColor = UIColor.white
        
        menuIcon.frame = CGRect(x: 0,y: 0,width: 20,height: 30)
        
        let actionButton = UIButton(frame:CGRect(x: 0,y: 0,width: 30,height: 30))
        actionButton.addSubview(menuIcon)
        actionButton.addTarget(target, action: action, for: UIControl.Event.touchUpInside)
        return UIBarButtonItem(customView: actionButton)
    }
    
    private func actionFilterButton(_ target: UIViewController, action: Selector) -> UIBarButtonItem{
        let menuIcon = UIImageView()
        menuIcon.contentMode = .scaleAspectFit
        var image = UIImage(named: "ic_filter_active")
        if defaults.string(forKey: "filter") != nil || defaults.string(forKey: "filterTag") != nil || defaults.array(forKey: "filterAgent") != nil{
           
            image = UIImage(named: "ic_filter_active")
            menuIcon.image = image
            
            menuIcon.frame = CGRect(x: 0,y: 0,width: 30,height: 30)
        }else{
            image = UIImage(named: "ic_filter_no_active")
            menuIcon.image = image
            
            menuIcon.frame = CGRect(x: 0,y: 0,width: 20,height: 30)
        }
      
      
        
        let actionButton = UIButton(frame:CGRect(x: 0,y: 0,width: 30,height: 30))
        actionButton.addSubview(menuIcon)
        actionButton.addTarget(target, action: action, for: UIControl.Event.touchUpInside)
        return UIBarButtonItem(customView: actionButton)
    }
    
    private func actionResolvedALLWAButton(_ target: UIViewController, action: Selector) -> UIBarButtonItem{
        let menuIcon = UIImageView()
        menuIcon.contentMode = .scaleAspectFit
        var image = UIImage(named: "ic_resolved_all_wa")
        menuIcon.image = image
        menuIcon.frame = CGRect(x: 0,y: 0,width: 25,height: 30)
       
        let actionButton = UIButton(frame:CGRect(x: 0,y: 0,width: 30,height: 30))
        actionButton.addSubview(menuIcon)
        actionButton.addTarget(target, action: action, for: UIControl.Event.touchUpInside)
        return UIBarButtonItem(customView: actionButton)
    }
    
    @objc func openMenu() {
        RDNavigationDrawer.sideToggle()
    }
    
    @objc func openFilter() {
        let vc = FilterVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func openResolvedALLWA() {
        let vc = ResolvedALLWAVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func openSearchUI() {
        let buttonBarViewHeight = self.buttonBarView.frame.size.height
        buttonBarView.frame = CGRect(origin: buttonBarView.frame.origin, size: CGSize(width: 0.0, height: 0.0))

        var containerViewRect = self.containerView.frame
        containerViewRect.origin = buttonBarView.frame.origin
        containerViewRect.size.height = containerViewRect.size.height + buttonBarViewHeight
        self.containerView.frame = containerViewRect
        self.containerView.isHidden = true
        
        
        self.title = "Search"
        
        self.tableViewSearch.isHidden = false
        self.viewSearchBar.isHidden = false
        self.firstTimeLoadSearch = false
        self.viewSearchBar.addBorderBottom(size: 1, color: UIColor(red: 232/255.0, green: 232/255.0, blue: 232/255.0, alpha:1.0))
        self.tvSearch.text = ""
        self.viewSearch.isHidden = false
        self.isTabCustomerSelected = true
        
        self.tableViewSearch.delegate = self
        self.tableViewSearch.dataSource = self
        self.tableViewSearch.register(UIChatListViewCell.nib, forCellReuseIdentifier: UIChatListViewCell.identifier)
        self.tableViewSearch.register(UIChatListSearchMessageViewCell.nib, forCellReuseIdentifier: UIChatListSearchMessageViewCell.identifier)
        self.getCustomerRooms()
    }
    
    @objc func profileButtonPressed() {
        let vc = ProfileVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - PagerTabStripDataSource
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        var child_1 = UIViewController()
        if defaults.string(forKey: "filter") != nil || defaults.string(forKey: "filterTag") != nil || defaults.array(forKey: "filterAgent") != nil {
            child_1 = UIChatListALLViewController()
        }else{
            child_1 = UIChatListViewController()
        }
        let child_3 = UIChatListUnservedViewController()
        let child_4 = UIChatListServedViewController()
        let child_5 = UIChatListResolvedViewController()
        let child_6 = UIChatListALLViewController()
        
        if let userType = UserDefaults.standard.getUserType(){
            if userType == 2 {
                guard isReload else {
                    return [child_1, child_5]
                }
                
                var childViewControllers = [child_1, child_5]
                
                for index in childViewControllers.indices {
                    let nElements = childViewControllers.count - index
                    let n = (Int(arc4random()) % nElements) + index
                    if n != index {
                        childViewControllers.swapAt(index, n)
                    }
                }
                let nItems = 1 + (arc4random() % 8)
                return Array(childViewControllers.prefix(Int(nItems)))
            }else if userType == 1{
                guard isReload else {
                    return [child_1, child_3, child_4, child_5]
                }
                
                var childViewControllers = [child_1, child_3, child_4, child_5]
                
                for index in childViewControllers.indices {
                    let nElements = childViewControllers.count - index
                    let n = (Int(arc4random()) % nElements) + index
                    if n != index {
                        childViewControllers.swapAt(index, n)
                    }
                }
                let nItems = 1 + (arc4random() % 8)
                return Array(childViewControllers.prefix(Int(nItems)))
            }else{
                guard isReload else {
                    return [child_6, child_3, child_4, child_5]
                }
                
                var childViewControllers = [child_1, child_3, child_4, child_5]
                
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
        }else{
            guard isReload else {
                return [child_1, child_5]
            }
            
            var childViewControllers = [child_1, child_5]
            
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.firstTimeLoadSearch = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 7/255, green: 185/255, blue: 155/255, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
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

        self.getConfigBotIntegration()
        self.getConfigResolvedALLWA()
        self.getConfigFeature()
    }
    
    func throttleGetList() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.getList), object: nil)
        perform(#selector(self.getList), with: nil, afterDelay: 1)
    }
    
    @objc func getList(){
        if let searchMessage = tvSearch.text{
            if searchMessage.count <= 2{
                if self.isTabCustomerSelected == true{
                    if self.statusSearchRoomFeature == 1 {
                        //if self.showAlertFilterIsActive() == false {
                            self.showAlertNoResultSearchRoomMessage()
                        //}
                    }
                } else {
                    if self.statusSearchMessageFeature == 1 {
                        if self.showAlertFilterIsActive() == false{
                            self.showAlertNoResultSearchRoomMessage()
                        }
                    }
                }
            }else{
                if self.isTabCustomerSelected == true && self.statusSearchRoomFeature == 3 {
                    self.showAlertDisable()
                }else if self.isTabCustomerSelected == true && self.statusSearchRoomFeature == 1{
                    //if self.showAlertFilterIsActive() == false{
                        self.getCustomerRooms()
                    //}
                }else if self.isTabCustomerSelected == false && self.statusSearchMessageFeature == 3{
                    self.showAlertDisable()
                }else if self.isTabCustomerSelected == false && self.statusSearchMessageFeature == 1{
                    if self.showAlertFilterIsActive() == false{
                        self.getCustomerMessages()
                    }
                }else{
                    self.showAlertNoResultSearchRoomMessage()
                }
            }
        }else{
            self.showAlertNoResultSearchRoomMessage()
        }
        
       
    }
    
    func checkSearchBarMessage(){
        if let searchMessage = tvSearch.text{
            if searchMessage.count <= 2{
                self.showAlertNoResultSearchRoomMessage()
            }else{
                if isTabCustomerSelected == true{
                    self.getCustomerRooms()
                }else{
                    self.getCustomerMessages()
                }
            }
        }
    }
    
    func getCustomerMessages(){
        if self.tvSearch.text == nil || self.tvSearch.text?.isEmpty == true {
            return
        }else{
            self.loadingIndicator.startAnimating()
            self.loadingIndicator.isHidden = false
            QiscusCore.shared.searchMessage(query: self.tvSearch.text ?? "", page: 1, limit: 100) { (comments) in
                self.loadingIndicator.stopAnimating()
                self.loadingIndicator.isHidden = true
                self.tableViewSearch.isHidden = false
                self.searchCustomerComments = comments
                self.searchCustomerRooms.removeAll()
                if self.searchCustomerComments.count == 0 {
                    self.showAlertNoResultSearchRoomMessage()
                }else{
                    self.hideALLAlertSearchRoomMessage()
                }
                self.tableViewSearch.reloadData()
            } onError: { (error) in
                self.loadingIndicator.stopAnimating()
                self.loadingIndicator.isHidden = true
                self.tableViewSearch.isHidden = true
                self.showAlertNoResultSearchRoomMessage()
            }
        }

    }
    
    func convertToDictionary(text: String) -> [[String: Any]]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func getCustomerRooms(){
        var callAPI = true
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        var param = ["limit": "50",
                     "name" : self.tvSearch.text ?? ""
        ] as [String : Any]
        
        if let hasFilterAgent = defaults.array(forKey: "filterAgent"){
            param["user_ids"] = hasFilterAgent
        }
        
        if let hasFilterTag = defaults.string(forKey: "filterTag"){
            if let dict = convertToDictionary(text: hasFilterTag){
                var array = [Int]()
                if dict.count != 0 {
                    for i in dict{
                        let json = JSON(i)
                        array.append(json["id"].int ?? 0)
                    }
                    param["tag_ids"] = array
                }
            }
        }
        
        if let hasFilter = defaults.string(forKey: "filter"){
            let dict = convertToDictionary(text: hasFilter)
            param["channels"] = dict
        }
        
        if let userType = UserDefaults.standard.getUserType(){
            if userType == 2 {
                //agent
                if let filterSelectedTypeWA = defaults.string(forKey: "filterSelectedTypeWA"){
                    if !filterSelectedTypeWA.isEmpty{
                        param["status"] = filterSelectedTypeWA
                    }
                }
                
                //use last tab
                let lastTab = self.defaults.integer(forKey: "lastTab")
                if lastTab == 0 {
                    if self.isTabCustomerSelected == false{
                        callAPI = false
                        self.loadingIndicator.startAnimating()
                        self.loadingIndicator.isHidden = false
                        QiscusCore.shared.getAllChatRooms(showParticipant: true, showRemoved: false, showEmpty: false, roomType: nil, page: 1, limit: 10) { (rooms, meta) in
                            self.loadingIndicator.stopAnimating()
                            self.loadingIndicator.isHidden = true
                            
                            var results = [CustomerRoom]()
                            for room in rooms {
                                if !room.name.contains("notifications"){
                                    let data = CustomerRoom(roomSDK: room)
                                    results.append(data)
                                }
                            }
                            
                            self.searchCustomerRooms = results
                            self.searchCustomerComments.removeAll()
                            
                            self.tableViewSearch.isHidden = false
                            self.tableViewSearch.reloadData()
                            if self.searchCustomerRooms.count == 0 {
                             // show empty search room
                                self.showAlertNoResultSearchRoomMessage()
                            }else{
                                self.hideALLAlertSearchRoomMessage()
                            }
                            
                            
                        } onError: { (error) in
                            self.loadingIndicator.stopAnimating()
                            self.loadingIndicator.isHidden = true
                            self.showAlertNoResultSearchRoomMessage()
                        }
                    }
                } else if lastTab == 1 {
                    param["status"] = "resolved"
                    if let filterSelectedTypeWA = defaults.string(forKey: "filterSelectedTypeWA"){
                        if !filterSelectedTypeWA.isEmpty{
                            if filterSelectedTypeWA.lowercased() != "all".lowercased(){
                                self.showAlertNoResultSearchRoomMessage()
                                return
                            }
                        }
                    }
                }
            }else{
                //admin / spv
                if let filterSelectedTypeWA = defaults.string(forKey: "filterSelectedTypeWA"){
                    if !filterSelectedTypeWA.isEmpty{
                        param["status"] = filterSelectedTypeWA
                    }
                }
                
                //use last tab
                let lastTab = self.defaults.integer(forKey: "lastTab")
                if lastTab == 0 {
                    if self.isTabCustomerSelected == false{
                        callAPI = false
                        self.loadingIndicator.startAnimating()
                        self.loadingIndicator.isHidden = false
                        let myGroup = DispatchGroup()
                        QiscusCore.shared.getAllChatRooms(showParticipant: true, showRemoved: false, showEmpty: false, roomType: nil, page: 1, limit: 10) { (rooms, meta) in
                            
                            var results = [CustomerRoom]()
                            var resultsByRooms = [CustomerRoom]()
                            var roomsData = rooms
                            
                            roomsData = roomsData.filter({ (room) -> Bool in
                                if room.name.contains("notifications"){
                                    return false
                                } else {
                                    return true
                                }
                                
                            })
                            
                            for room in roomsData {
                                let data = CustomerRoom(roomSDK: room)
                                results.append(data)
                                
                                myGroup.enter()
                                self.getRoomById(roomId: room.id) { (custRoom) in
                                    resultsByRooms.append(custRoom)
                                    myGroup.leave()
                                } onError: { (error) in
                                    myGroup.leave()
                                }
                            }
                            
                            myGroup.notify(queue: .main) {
                                
                                for (index,element) in results.enumerated() {
                                    for i in resultsByRooms {
                                        if results[index].roomId == i.roomId {
                                            results[index].isHandledByBot = i.isHandledByBot
                                        }
                                    }
                                    
                                }
                                
                                results.sort { (room1, room2) -> Bool in
                                    return room1.lastCommentUnixTimestamp > room2.lastCommentUnixTimestamp
                                }
                                
                                self.loadingIndicator.stopAnimating()
                                self.loadingIndicator.isHidden = true
                                
                                self.searchCustomerRooms = results
                                self.searchCustomerComments.removeAll()
                                
                                self.tableViewSearch.isHidden = false
                                self.tableViewSearch.reloadData()
                                if self.searchCustomerRooms.count == 0 {
                                    // show empty search room
                                    self.showAlertNoResultSearchRoomMessage()
                                }else{
                                    self.hideALLAlertSearchRoomMessage()
                                }
                            }
                            
                        } onError: { (error) in
                            self.loadingIndicator.stopAnimating()
                            self.loadingIndicator.isHidden = true
                            self.showAlertNoResultSearchRoomMessage()
                        }
                    }
                } else if lastTab == 1 {
                    param["serve_status"] = "unserved"
                } else if lastTab == 2 {
                    param["serve_status"] = "served"
                } else if lastTab == 3 {
                    param["status"] = "resolved"
                    if let filterSelectedTypeWA = defaults.string(forKey: "filterSelectedTypeWA"){
                        if !filterSelectedTypeWA.isEmpty{
                            if filterSelectedTypeWA.lowercased() != "all".lowercased(){
                                self.showAlertNoResultSearchRoomMessage()
                                return
                            }
                        }
                    }
                }
            }
        }else{
            if let filterSelectedTypeWA = defaults.string(forKey: "filterSelectedTypeWA"){
                if !filterSelectedTypeWA.isEmpty{
                    param["status"] = filterSelectedTypeWA
                }
            }
            
            //use last tab
            let lastTab = self.defaults.integer(forKey: "lastTab")
            if lastTab == 0 {
                if self.isTabCustomerSelected == false{
                    callAPI = false
                    self.loadingIndicator.startAnimating()
                    self.loadingIndicator.isHidden = false
                    QiscusCore.shared.getAllChatRooms(showParticipant: true, showRemoved: false, showEmpty: false, roomType: nil, page: 1, limit: 10) { (rooms, meta) in
                        self.loadingIndicator.stopAnimating()
                        self.loadingIndicator.isHidden = true
                        var results = [CustomerRoom]()
                        for room in rooms {
                            if !room.name.contains("notifications"){
                                let data = CustomerRoom(roomSDK: room)
                                results.append(data)
                            }
                        }
                        
                        self.searchCustomerRooms = results
                        self.searchCustomerComments.removeAll()
                        
                        self.tableViewSearch.isHidden = false
                        self.tableViewSearch.reloadData()
                        if self.searchCustomerRooms.count == 0 {
                         // show empty search room
                            self.showAlertNoResultSearchRoomMessage()
                        }else{
                            self.hideALLAlertSearchRoomMessage()
                        }
                        
                        
                    } onError: { (error) in
                        self.loadingIndicator.stopAnimating()
                        self.loadingIndicator.isHidden = true
                        self.showAlertNoResultSearchRoomMessage()
                    }
                }
            } else if lastTab == 1 {
                param["serve_status"] = "unserved"
            } else if lastTab == 2 {
                param["serve_status"] = "served"
            } else if lastTab == 3 {
                param["status"] = "resolved"
                
                if let filterSelectedTypeWA = defaults.string(forKey: "filterSelectedTypeWA"){
                    if !filterSelectedTypeWA.isEmpty{
                        if filterSelectedTypeWA.lowercased() != "all".lowercased(){
                            self.showAlertNoResultSearchRoomMessage()
                            return
                        }
                    }
                }
            }
        }
        
        
        if callAPI == true {
            self.loadingIndicator.startAnimating()
            self.loadingIndicator.isHidden = false
            
            Alamofire.request("\(QiscusHelper.getBaseURL())/api/v2/customer_rooms", method: .post, parameters: param, encoding: JSONEncoding.default, headers: header as! HTTPHeaders).responseJSON { (response) in
                if response.result.value != nil {
                    if (response.response?.statusCode)! >= 300 {
                        //error
                        
                        self.loadingIndicator.stopAnimating()
                        self.loadingIndicator.isHidden = true
                        if response.response?.statusCode == 401 {
                            RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                                if success == true {
                                    self.getCustomerRooms()
                                } else {
                                    self.showAlertNoResultSearchRoomMessage()
                                    return
                                }
                            }
                        }
                    } else {
                        //success
                        self.loadingIndicator.stopAnimating()
                        self.loadingIndicator.isHidden = true
                        
                        let payload = JSON(response.result.value)
                        if let customerRooms = payload["data"]["customer_rooms"].array {
                            var results = [CustomerRoom]()
                            for room in customerRooms {
                                let data = CustomerRoom(json: room)
                                results.append(data)
                            }
                            
                            
                            self.searchCustomerRooms = results
                            self.searchCustomerComments.removeAll()
                        }
                        self.tableViewSearch.isHidden = false
                        self.tableViewSearch.reloadData()
                        if self.searchCustomerRooms.count == 0 {
                         // show empty search room
                            self.showAlertNoResultSearchRoomMessage()
                        }else{
                            self.hideALLAlertSearchRoomMessage()
                        }
                        
                    }
                } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                    //failed
                    self.loadingIndicator.stopAnimating()
                    self.loadingIndicator.isHidden = true
                    self.tableViewSearch.isHidden = true
                    self.showAlertNoResultSearchRoomMessage()
                } else {
                    self.loadingIndicator.stopAnimating()
                    self.loadingIndicator.isHidden = true
                    self.tableViewSearch.isHidden = true
                    self.showAlertNoResultSearchRoomMessage()
                }
            }
        }
    }
    
    func getRoomById(roomId : String,onSuccess: @escaping (CustomerRoom) -> Void, onError: @escaping (String) -> Void){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v2/customer_rooms/\(roomId)", method: .get, parameters: nil, headers: header as! HTTPHeaders).responseJSON { (response) in
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //error
                    onError("failed get roomById")
                } else {
                    //success
                    let payload = JSON(response.result.value)
                    
                    let cust  = CustomerRoom(json: payload["data"]["customer_room"])
                    
                    onSuccess(cust)
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
                onError("failed get roomById")
            } else {
                //failed
                onError("failed get roomById")
            }
        }
    }
    
    func getConfigResolvedALLWA(){
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
                                self.getConfigResolvedALLWA()
                            } else {
                               
                                return
                            }
                        }
                    }else{
                        //show error
                        self.setupUINavBar()
                    }
                } else {
                    //success
                    let json = JSON(response.result.value)
                  
                    let waChannels = json["data"]["wa_channels"].array
                   
                    
                    if waChannels?.count != 0 {
                        self.defaults.setValue(true, forKey: "ic_resolved_all_WA_active")
                    }else{
                        self.defaults.setValue(false, forKey: "ic_resolved_all_WA_active")
                    }
                    
                    self.setupUINavBar()
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
                self.setupUINavBar()
            } else {
                //failed
                self.setupUINavBar()
            }
        }
    }
    
    func getConfigBotIntegration(){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v1/app/bot", method: .get, parameters: nil, headers: header as! HTTPHeaders).responseJSON { (response) in
            print("response call \(response)")
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //failed
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.getConfigBotIntegration()
                            } else {
                               
                                return
                            }
                        }
                    }
                } else {
                    //success
                    let json = JSON(response.result.value)
                  
                    let isBotEnable = json["data"]["is_bot_enabled"].bool ?? false
                   
                    
                    self.defaults.setBot(value: isBotEnable)
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
            } else {
                //failed
            }
        }
    }
    
    func showAlertNoResultSearchRoomMessage(){
        self.viewAlertDisableSearchRoomMessage.isHidden = true
        self.viewAlertSearchRoomMessage.isHidden = true
        self.viewNoResultSearchRoomMessage.isHidden = false
    }
    
    func hideALLAlertSearchRoomMessage(){
        self.viewAlertSearchRoomMessage.isHidden = true
        self.viewAlertDisableSearchRoomMessage.isHidden = true
        self.viewNoResultSearchRoomMessage.isHidden = true
    }
    
    func showAlertDisable(){
        let attributedWithTextColor: NSAttributedString = self.alertMessageDisable.attributedStringWithColor(["disabled"], color: UIColor.black, sizeFont : 17)

        self.lbAlertDisableSearchRoomMessage.attributedText = attributedWithTextColor
        
        self.viewAlertSearchRoomMessage.isHidden = true
        self.viewNoResultSearchRoomMessage.isHidden = true
        self.viewAlertDisableSearchRoomMessage.isHidden = false
    }
    
    func showAlertFilterIsActive()-> Bool{
        if defaults.string(forKey: "filter") != nil || defaults.string(forKey: "filterTag") != nil || defaults.array(forKey: "filterAgent") != nil{
            let attributedWithTextColor: NSAttributedString = self.alertMessageFilterActive.attributedStringWithColor(["filter is active."], color: UIColor.black, sizeFont : 17)
            self.lbAlertSearchRoomMessage.attributedText = attributedWithTextColor
    
            self.viewAlertDisableSearchRoomMessage.isHidden = true
            self.viewNoResultSearchRoomMessage.isHidden = true
            self.viewAlertSearchRoomMessage.isHidden = false
            return true
        } else if self.defaults.integer(forKey: "lastTab") != 0 {
            if let userType = UserDefaults.standard.getUserType(){
                if userType == 2 {
                    //agent
                    let attributedWithTextColor: NSAttributedString = self.alertMessageOtherOngoing.attributedStringWithColor(["Ongoing tab"], color: UIColor.black, sizeFont : 17)

                    self.lbAlertSearchRoomMessage.attributedText = attributedWithTextColor
                }else{
                    let attributedWithTextColor: NSAttributedString = self.alertMessageOtherAll.attributedStringWithColor(["All tab"], color: UIColor.black, sizeFont : 17)

                    self.lbAlertSearchRoomMessage.attributedText = attributedWithTextColor
                }
            }else{
                let attributedWithTextColor: NSAttributedString = self.alertMessageOtherAll.attributedStringWithColor(["All tab"], color: UIColor.black, sizeFont : 17)
                
                self.lbAlertSearchRoomMessage.attributedText = attributedWithTextColor
            }
                
            self.viewAlertDisableSearchRoomMessage.isHidden = true
            self.viewNoResultSearchRoomMessage.isHidden = true
            self.viewAlertSearchRoomMessage.isHidden = false
            return true
        }else{
            return false
        }
    }
    
    
    @IBAction func actionBtCustomersClick(_ sender: Any) {
        self.isTabCustomerSelected = true
        
        if self.statusSearchRoomFeature == 3 && self.statusSearchMessageFeature == 3 {
            self.showAlertDisable()
            self.showALLTAB()
        }else if self.statusSearchRoomFeature == 3 && self.statusSearchMessageFeature == 1{
            self.showAlertDisable()
            self.showALLTAB()
        }else if  self.statusSearchRoomFeature == 1 && self.statusSearchMessageFeature == 3 {
            self.showALLTAB()
            self.hideALLAlertSearchRoomMessage()
        }else if  self.statusSearchRoomFeature == 1 && self.statusSearchMessageFeature == 1 {
            self.showALLTAB()
            self.hideALLAlertSearchRoomMessage()
        }
        
        if self.statusSearchRoomFeature != 3{
            self.tableViewSearch.isHidden = true
            self.throttleGetList()
        }
    }
    
    @IBAction func actionBtMessagesClick(_ sender: Any) {
        self.isTabCustomerSelected = false
        
        if self.statusSearchRoomFeature == 3 && self.statusSearchMessageFeature == 3 {
            self.showAlertDisable()
            
            self.btTabMessages.setTitleColor(ColorConfiguration.defaultColorTosca, for: .normal)
            self.btTabMessages.addBorderBottom(size: 2, color: ColorConfiguration.defaultColorTosca)
            self.btTabCustomers.setTitleColor(UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.45), for: .normal)
            self.btTabCustomers.addBorderBottom(size: 2, color: .lightGray)
        }else if self.statusSearchRoomFeature == 3 && self.statusSearchMessageFeature == 1{
            self.hideALLAlertSearchRoomMessage()
            
            self.btTabMessages.setTitleColor(ColorConfiguration.defaultColorTosca, for: .normal)
            self.btTabMessages.addBorderBottom(size: 2, color: ColorConfiguration.defaultColorTosca)
            self.btTabCustomers.setTitleColor(UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.45), for: .normal)
            self.btTabCustomers.addBorderBottom(size: 2, color: .lightGray)
        }else if  self.statusSearchRoomFeature == 1 && self.statusSearchMessageFeature == 3 {
            self.showAlertDisable()
            
            self.btTabMessages.setTitleColor(ColorConfiguration.defaultColorTosca, for: .normal)
            self.btTabMessages.addBorderBottom(size: 2, color: ColorConfiguration.defaultColorTosca)
            self.btTabCustomers.setTitleColor(UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.45), for: .normal)
            self.btTabCustomers.addBorderBottom(size: 2, color: .lightGray)
        }else if  self.statusSearchRoomFeature == 1 && self.statusSearchMessageFeature == 1 {
            self.hideALLAlertSearchRoomMessage()
            
            self.btTabMessages.setTitleColor(ColorConfiguration.defaultColorTosca, for: .normal)
            self.btTabMessages.addBorderBottom(size: 2, color: ColorConfiguration.defaultColorTosca)
            self.btTabCustomers.setTitleColor(UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.45), for: .normal)
            self.btTabCustomers.addBorderBottom(size: 2, color: .lightGray)
        }
        
        if self.statusSearchMessageFeature != 3 {
            self.tableViewSearch.isHidden = true
            self.throttleGetList()
        }
        
      
    }
    
    func getConfigFeature(){
       
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v2/features", method: .get, parameters: nil, headers: header as! HTTPHeaders).responseJSON { (response) in
            print("response call \(response)")
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //failed
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.getConfigFeature()
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
                  
                    if let features = json["data"]["features"].array {
                        if features.count != 0 {
                            for data in features {
                                let dataFeature = FeaturesModel(json: data)
                                self.featuresData.append(dataFeature)
                            }
                        }
                    }
                    
                    
                    for i in self.featuresData {
                        if i.name.lowercased() == "INBOX".lowercased(){
                            for x in i.features {
                                ////1 show, 2 hide, 3 disabled
                                if x.name.lowercased() == "SEARCH_MESSAGE".lowercased(){
                                    self.statusSearchMessageFeature = x.status
                                }
                                
                                if x.name.lowercased() == "SEARCH_CUSTOMER".lowercased(){
                                    self.statusSearchRoomFeature = x.status
                                }
                            }
                        }
                        
                        if i.name.lowercased() == "SETTING".lowercased(){
                            for x in i.features {
                                ////1 show, 2 hide, 3 disabled
                                if x.name.lowercased() == "SUBMIT_TICKET".lowercased(){
                                    UserDefaults.standard.setStatusFeatureSubmitTicket(value: x.status)
                                }
                            }
                        }
                        
                        if i.name.lowercased() == "ANALYTICS".lowercased(){
                            for x in i.features {
                                ////1 show, 2 hide, 3 disabled
                                if x.name.lowercased() == "AGENT_ANALYTICS".lowercased(){
                                    UserDefaults.standard.setStatusFeatureOverallAgentAnalytics(value: x.status)
                                    
                                    for y in x.features {
                                        if y.name.lowercased() == "AGENT_ANALYTICS_WA".lowercased(){
                                            UserDefaults.standard.setStatusFeatureAnalyticsWA(value: y.status)
                                        }
                                    }
                                    
                                }
                                
                                if x.name.lowercased() == "CUSTOM_ANALYTICS".lowercased(){
                                    UserDefaults.standard.setStatusFeatureCustomAnalytics(value: x.status)
                                }
                            }
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
    
}

extension HomeVC : UITableViewDelegate, UITableViewDataSource {
    
    func chat(withRoom room: RoomModel, comment : CommentModel? = nil){
        let target = UIChatViewController()
        target.room = room
        if let comment = comment {
            target.scrollToComment = comment
        }else{
            target.scrollToComment = nil
        }
        self.navigationController?.pushViewController(target, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isTabCustomerSelected == true {
            return self.searchCustomerRooms.count
        }else{
            return self.searchCustomerComments.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isTabCustomerSelected == true {
            if self.searchCustomerRooms.count == 0{
                return UITableViewCell()
            }else{
                let data = self.searchCustomerRooms[indexPath.row]
                let cell = tableView.dequeueReusableCell(withIdentifier: UIChatListViewCell.identifier, for: indexPath) as! UIChatListViewCell
                cell.setupUICustomerRoom(data: data)
                return cell
            }
        }else{
            if self.searchCustomerComments.count == 0 {
                return UITableViewCell()
            }else{
                let data = self.searchCustomerComments[indexPath.row]
                let cell = tableView.dequeueReusableCell(withIdentifier: UIChatListSearchMessageViewCell.identifier, for: indexPath) as! UIChatListSearchMessageViewCell
                cell.setup(data: data, messageSearch : self.tvSearch.text ?? "")
                return cell
            }
           
        }
        
        return UITableViewCell()
       
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isTabCustomerSelected == true {
            let customerRoom = self.searchCustomerRooms[indexPath.row]
            
            QiscusCore.shared.getChatRoomWithMessages(roomId: customerRoom.roomId, onSuccess: { (room, comments) in
                self.chat(withRoom: room)
            }) { (error) in
                //error
            }
        }else{
            let customerComment = self.searchCustomerComments[indexPath.row]
            
            QiscusCore.shared.getChatRoomWithMessages(roomId: customerComment.roomId, onSuccess: { (room, comments) in
                self.chat(withRoom: room, comment: customerComment)
            }) { (error) in
                //error
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
    
    private func getIndexpath(byRoom data: CustomerRoom) -> IndexPath? {
        // get current index
        if self.isTabCustomerSelected == true {
            for (i,r) in self.searchCustomerRooms.enumerated() {
                if r.id == data.id {
                    return IndexPath(row: i, section: 0)
                }
            }
            return nil
        }else{
            //TODO change with searchMessageModel
            for (i,r) in self.searchCustomerComments.enumerated() {
                if r.id == data.id {
                    return IndexPath(row: i, section: 0)
                }
            }
            return nil
        }
    
        return nil
    }
}

extension HomeVC : UITextFieldDelegate {
    func showALLTAB(){
        self.isTabCustomerSelected = true
        self.btTabCustomers.setTitleColor(ColorConfiguration.defaultColorTosca, for: .normal)
        self.btTabCustomers.addBorderBottom(size: 2, color: ColorConfiguration.defaultColorTosca)
        
        self.btTabMessages.setTitleColor(UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.45), for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.btTabMessages.addBorderBottom(size: 2, color: .lightGray)
        }
    }
    
    func showTABCustomer(){
        self.isTabCustomerSelected = true
        self.btTabMessages.isHidden = true
        
        self.btTabCustomers.setTitleColor(UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.45), for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.btTabCustomers.addBorderBottom(size: 2, color: .lightGray)
        }
    }
    
    func showTABMessage(){
        self.isTabCustomerSelected = false
        self.btTabCustomers.isHidden = true
        
        self.btTabMessages.setTitleColor(UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.45), for: .normal)
        self.btTabMessages.addBorderBottom(size: 2, color: .lightGray)
    }
    
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
        self.showGetCustomer = false
        if let text = textField.text {
            if !text.isEmpty {
                self.stackView.isHidden = false
                self.heightStackView.constant = 50
                if firstTimeLoadSearch == false {
                    self.firstTimeLoadSearch = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        
                        if self.statusSearchRoomFeature == 3 && self.statusSearchMessageFeature == 3 {
                            self.showAlertDisable()
                            self.showALLTAB()
                        }else if self.statusSearchRoomFeature == 3 && self.statusSearchMessageFeature == 2{
                            self.showAlertDisable()
                            self.showTABCustomer()
                        }else if self.statusSearchRoomFeature == 3 && self.statusSearchMessageFeature == 1{
                            self.showAlertDisable()
                            self.showALLTAB()
                        }else if self.statusSearchRoomFeature == 2 && self.statusSearchMessageFeature == 3 {
                            self.showAlertDisable()
                            self.showTABMessage()
                        }else if self.statusSearchRoomFeature == 2 && self.statusSearchMessageFeature == 2 {
                            self.heightStackView.constant = 0
                        }else if  self.statusSearchRoomFeature == 2 && self.statusSearchMessageFeature == 1 {
                            self.showTABMessage()
                        }else if  self.statusSearchRoomFeature == 1 && self.statusSearchMessageFeature == 3 {
                            self.showALLTAB()
                        }else if  self.statusSearchRoomFeature == 1 && self.statusSearchMessageFeature == 2 {
                            self.showTABCustomer()
                        }else if  self.statusSearchRoomFeature == 1 && self.statusSearchMessageFeature == 1 {
                            self.showALLTAB()
                        }
                    }
                }
            }
        }
        if let viewWithTag = self.view.viewWithTag(222) {
            viewWithTag.removeFromSuperview()
        }
        self.throttleGetList()
        
        return true;
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
}
