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

class UIChatTabViewController: ButtonBarPagerTabStripViewController {
    
    var isReload = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupUINavBar()
        
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
        let child_2 = UIChatListResolvedViewController()
        
        guard isReload else {
            return [child_1, child_2]
        }
        
        var childViewControllers = [child_1, child_2]
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 7/255, green: 185/255, blue: 155/255, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
}
