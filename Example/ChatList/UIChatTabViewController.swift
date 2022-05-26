//  ButtonBarExampleViewController.swift
//  XLPagerTabStrip ( https://github.com/xmartlabs/XLPagerTabStrip )
//
//  Copyright (c) 2017 Xmartlabs ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
import Foundation
import XLPagerTabStrip
import QiscusCore
import Alamofire
import AlamofireImage
import ExpandingMenu
import SwiftyJSON

class UIChatTabViewController: ButtonBarPagerTabStripViewController {
    
    var isReload = false
    var timer : Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupUINavBar()
        self.getCountCustomer()
        
        if (self.timer != nil) {
            self.timer?.invalidate()
            self.timer = nil
        }
        self.timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(getCountCustomer), userInfo: nil, repeats: true)
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
    func setupUI(){
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
        }
    }
    
    func setupUINavBar(){
        self.title = "Multichannel Agent"
        
        var buttonProfile = UIButton(type: .custom)
        buttonProfile.frame = CGRect(x: 0, y: 6, width: 30, height: 30)
        buttonProfile.widthAnchor.constraint(equalToConstant: 30).isActive = true
        buttonProfile.heightAnchor.constraint(equalToConstant: 30).isActive = true
        buttonProfile.layer.cornerRadius = 15
        buttonProfile.clipsToBounds = true
        
        if let profile = QiscusCore.getProfile(){
           buttonProfile.af_setImage(for: .normal, url: profile.avatarUrl)
        }
        
        buttonProfile.layer.cornerRadius = buttonProfile.frame.width/2
        
        buttonProfile.addTarget(self, action: #selector(profileButtonPressed), for: .touchUpInside)
        
        let barButton = UIBarButtonItem(customView: buttonProfile)
        
        //assign button to navigationbar
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func profileButtonPressed() {
        let vc = ProfileVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - PagerTabStripDataSource
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let child_1 = UIChatListViewController()
        let child_3 = UIChatListUnservedViewController()
        let child_4 = UIChatListServedViewController()
        let child_5 = UIChatListResolvedViewController()
        
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
            }else{
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
    }
}
