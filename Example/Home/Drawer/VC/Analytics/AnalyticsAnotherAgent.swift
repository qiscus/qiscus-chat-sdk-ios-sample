//
//  AnalyticsAnotherAgent.swift
//  Example
//
//  Created by Qiscus on 01/07/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Alamofire
import AlamofireImage
import SwiftyJSON

class AnalyticsAnotherAgent: ButtonBarPagerTabStripViewController {
    var isReload = false
    var agentId : Int = 0
    
    override func viewDidLoad() {
        settings.style.selectedBarHeight = 3
        settings.style.buttonBarItemLeftRightMargin = 0
        
        settings.style.buttonBarBackgroundColor = ColorConfiguration.defaultColorTosca
        settings.style.buttonBarItemBackgroundColor = ColorConfiguration.defaultColorTosca
        settings.style.selectedBarBackgroundColor = UIColor.white
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 15)
        
        super.viewDidLoad()
        
        self.setupNavBar()
        self.setupUI()
    }
    
    func setupNavBar(){
        let backImage = UIImage(named: "ic_back")
        self.navigationController?.navigationBar.backIndicatorImage = backImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        
        let backButton = self.backButton(self, action: #selector(AnalyticsAnotherAgent.goBack))
        let titleButton = self.titleBackButton(self, action: #selector(AnalyticsAnotherAgent.titleBack))
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.leftBarButtonItems = [backButton, titleButton]
    }
    
    func setupUI(){
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
    }
    
    @objc func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func titleBack() {
       
    }
    
    private func backButton(_ target: UIViewController, action: Selector) -> UIBarButtonItem{
        let backIcon = UIImageView()
        backIcon.contentMode = .scaleAspectFit
        
        let image = UIImage(named: "ic_back")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        backIcon.image = image
        backIcon.tintColor = UIColor.white
        
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
    
    private func titleBackButton(_ target: UIViewController, action: Selector) -> UIBarButtonItem{
        let backButton = UIButton(frame:CGRect(x: 0,y: 0,width: 30,height: 44))
        backButton.setTitle("Analytics another agent", for: .normal)
        backButton.addTarget(target, action: action, for: UIControl.Event.touchUpInside)
        return UIBarButtonItem(customView: backButton)
    }
    
    // MARK: - PagerTabStripDataSource
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let child_1 = PerformanceAgentVC()
        child_1.agentId = self.agentId
        let child_2 = ChatAgentVC()
        child_2.agentId = self.agentId
        let child_3 = OtherAnalyticsVC()
        child_3.agentId = self.agentId
        
        guard isReload else {
            return [child_1, child_2, child_3]
        }
        
        var childViewControllers = [child_1, child_2, child_3]
        
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
