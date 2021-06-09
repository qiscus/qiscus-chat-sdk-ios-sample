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
    
    @IBOutlet weak var viewSearchBar: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var lbRoomsNotFound: UILabel!
    @IBOutlet weak var tableViewSearch: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var bottomTableViewTagHeightConst: NSLayoutConstraint!
    var isReload = false
    var timer : Timer?
    let sideBar = SideBar(viewModel: "SideBarViewModel")
    var defaults = UserDefaults.standard
    var searchCustomerRooms = [CustomerRoom]()
    var defaultButtonBarView = CGRect()
    var defaultContainerView = CGRect()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupUINavBar()
        self.getCountCustomer()
        
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
        
        let button = UIButton()
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1920, 2208:
                button.frame = CGRect(x: self.view.frame.size.width - 105 , y: self.view.frame.size.height - 105, width: 100, height: 100)
            default:
                button.frame = CGRect(x: self.view.frame.size.width - 80 , y: self.view.frame.size.height - 80, width: 75, height: 75)
            }
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
        self.searchBar.isHidden = true
        self.viewSearchBar.isHidden = true
        
        settings.style.selectedBarHeight = 1
        
        settings.style.buttonBarBackgroundColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1)
        settings.style.buttonBarItemBackgroundColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1)
        settings.style.selectedBarBackgroundColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1)
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 15)
        
        buttonBarView.selectedBar.backgroundColor = UIColor(red: 7/255, green: 185/255, blue: 155/255, alpha: 1)
        buttonBarView.backgroundColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1)
        self.view.backgroundColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1)
        if #available(iOS 11.0, *) {
            self.edgesForExtendedLayout = []
        } else {
            self.edgesForExtendedLayout = []
        }
        
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = UIColor(red: 7/255, green: 185/255, blue: 155/255, alpha: 0.5)
            newCell?.label.textColor = UIColor(red: 7/255, green: 185/255, blue: 155/255, alpha: 1)
            
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "reloadTabs"), object: nil)
        }
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
                    self.navigationItem.rightBarButtonItems = [actionFilterButton, actionSearchButton, actionResolvedALLWAButton]
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
        
        let image = UIImage(named: "ic_search")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
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
        
        self.view.viewWithTag(222)?.isHidden = true
        
        self.tableViewSearch.isHidden = false
        self.searchBar.isHidden = false
        self.viewSearchBar.isHidden = false
        
        //setup search
        self.searchBar.delegate = self
        self.searchBar.backgroundImage = UIImage()
        self.searchBar.backgroundColor = .white
        
        self.tableViewSearch.delegate = self
        self.tableViewSearch.dataSource = self
        self.tableViewSearch.register(UIChatListViewCell.nib, forCellReuseIdentifier: UIChatListViewCell.identifier)
        
        self.throttleGetList()
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
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 7/255, green: 185/255, blue: 155/255, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

        self.getConfigResolvedALLWA()
    }
    
    func throttleGetList() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.getList), object: nil)
        perform(#selector(self.getList), with: nil, afterDelay: 1)
    }
    
    @objc func getList(){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        var param = ["limit": "50",
                     "name" : self.searchBar.text ?? ""
        ] as [String : Any]
        
        
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
                                self.getList()
                            } else {
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
                    }
                    self.tableViewSearch.isHidden = false
                    self.tableViewSearch.reloadData()
                    if self.searchCustomerRooms.count == 0 {
                     // show empty search room
                        self.lbRoomsNotFound.isHidden = false
                    }else{
                        self.lbRoomsNotFound.isHidden = true
                    }
                    
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
                self.loadingIndicator.stopAnimating()
                self.loadingIndicator.isHidden = true
                self.tableViewSearch.isHidden = true
                self.lbRoomsNotFound.isHidden = true
            } else {
                self.loadingIndicator.stopAnimating()
                self.loadingIndicator.isHidden = true
                self.tableViewSearch.isHidden = true
                self.lbRoomsNotFound.isHidden = true
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
}

extension HomeVC : UITableViewDelegate, UITableViewDataSource {
    
    func chat(withRoom room: RoomModel){
        let target = UIChatViewController()
        target.room = room
        self.navigationController?.pushViewController(target, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchCustomerRooms.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = self.searchCustomerRooms[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: UIChatListViewCell.identifier, for: indexPath) as! UIChatListViewCell
        cell.setupUICustomerRoom(data: data)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let customerRoom = self.searchCustomerRooms[indexPath.row]
        
        QiscusCore.shared.getChatRoomWithMessages(roomId: customerRoom.roomId, onSuccess: { (room, comments) in
            self.chat(withRoom: room)
        }) { (error) in
            //error
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
        for (i,r) in self.searchCustomerRooms.enumerated() {
            if r.id == data.id {
                return IndexPath(row: i, section: 0)
            }
        }
        return nil
    }
}

extension HomeVC: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
       
        searchBar.text = ""
        searchBar.endEditing(true)
        
        self.searchCustomerRooms.removeAll()
        self.tableViewSearch.reloadData()
        
        buttonBarView.frame = self.defaultButtonBarView
        self.containerView.frame = self.defaultContainerView
        self.containerView.isHidden = false
        self.tableViewSearch.isHidden = true
        self.lbRoomsNotFound.isHidden = true
        self.loadingIndicator.isHidden = true
        self.searchBar.isHidden = true
        self.viewSearchBar.isHidden = true
        self.title = "Inbox"
        self.view.viewWithTag(222)?.isHidden = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    }
    
    func searchBar(_ owsearchBar: UISearchBar, textDidChange searchText: String) {
        self.throttleGetList()
    }
}


