//
//  RDNavigationDrawer.swift
//
//  Created by Randolf Dini-ay on 15/03/2019.
//  Copyright © 2016 Randolf Omalsa Dini-ay. All rights reserved.
//

import UIKit

private var navigationDrawer:RDNavigationDrawer! = nil
private var parentController:UIViewController! = nil
private var targetController:UIViewController! = nil

//private var statusBarBackground:UIView! = nil
private var sideBarDimBackground:UIView! = nil
private var slideNavigationWidth:CGFloat! = 0

private var direction:String = ""

private var originalPercentage:CGFloat = 0
private var locationOpened:CGFloat = 0
private var locationClosed:CGFloat = 0

private var draggingDirection:CGFloat = 0
private var draggingAllowed:Bool = false

private var allowedClosingGesture:Bool = true
private var allowedOpeningGesture:Bool = true
private var enabled:Bool = false
private var didOpen:Bool = false

private var openingPanGesture: UIScreenEdgePanGestureRecognizer! = nil
private var closingPanGesture: UIPanGestureRecognizer! = nil

private var isPortrait:Bool = true
private let isiPad = UIDevice.current.userInterfaceIdiom == .pad

extension RDNavigationDrawer: RDNavigation {
    
    var containerView: RDNavigationDrawer {
        return navigationDrawer
    }
    
    var targetViewController: UIViewController {
        return targetController
    }
    
    /*
    fileprivate class func registerNib(name: String) -> RDNavigationDrawer {
        let drawerView = Bundle.main.loadNibNamed(name, owner: nil, options: nil)?[0] as! UIView;
        let rightSideMenuView = drawerView as! RDNavigationDrawer
        return rightSideMenuView;
    }*/
    
    fileprivate class func addShadow() {
        navigationDrawer.layer.shadowColor = UIColor.black.cgColor
        navigationDrawer.layer.shadowOpacity = 0.6
        navigationDrawer.layer.shadowOffset = CGSize.zero
        navigationDrawer.layer.shadowRadius = 10
    }
    
    fileprivate class func addSwipeGesture() {
        
        if allowedClosingGesture {
            if navigationDrawer != nil && closingPanGesture == nil {
                closingPanGesture = UIPanGestureRecognizer(target: self, action: #selector(dragClosingToggle(_:)))
                closingPanGesture.maximumNumberOfTouches = 1
                navigationDrawer.addGestureRecognizer(closingPanGesture)
            }
        }
        
        if allowedOpeningGesture {
            if parentController != nil && openingPanGesture == nil {
                openingPanGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(dragOpeningToggle(_:)))
                openingPanGesture.maximumNumberOfTouches = 1
                openingPanGesture.edges = (direction == "right") ? .right : .left
                parentController.view.addGestureRecognizer(openingPanGesture)
            }
        }

    }
    
    @objc class func dragClosingToggle(_ gesture: UIPanGestureRecognizer?) {
        if gesture == nil { return }
        if allowedClosingGesture == false { return }
        
        let location = gesture!.location(in: navigationDrawer)
        let slideNavigationX = navigationDrawer.frame.origin.x
        var locationX:CGFloat = 0
        var alpha:CGFloat = 0
        let maximumWidth = parentController.view.bounds.width
        
        if direction == "right" {
            //GETTING RIGHT LOCATION WILL BEGAN DRAGGING
            locationX = location.x + slideNavigationX
            alpha = 0.9 - (locationX/maximumWidth)
            
            if gesture?.state == .began {
                draggingDirection = locationX
                
                let limitSwipe = locationOpened + (navigationDrawer.bounds.width/3)
                draggingAllowed = (limitSwipe > location.x)
            }
        }
        else {
            //GETTING LEFT LOCATION WILL BEGAN DRAGGING
            locationX = locationClosed + location.x + slideNavigationX
            alpha = (locationX/maximumWidth) + 0.6
            
            if gesture?.state == .began {
                draggingDirection = locationX
                
                let limitSwipe = navigationDrawer.bounds.width - (navigationDrawer.bounds.width/3)
                draggingAllowed = (limitSwipe < location.x)
            }
        }
        
        draggingState(gesture!.state, locationX: locationX, alpha: alpha)
    }
    
    @objc class func dragOpeningToggle(_ gesture: UIScreenEdgePanGestureRecognizer?) {
        if gesture == nil { return }
        if allowedOpeningGesture == false { return }
        
        let location = gesture!.location(in: parentController.view)
        var locationX:CGFloat = 0
        var alpha:CGFloat = 0
        let maximumWidth = parentController.view.bounds.width
        
        if direction == "right" {
            //GETTING RIGHT LOCATION WILL BEGAN DRAGGING
            locationX = location.x - 15
            alpha = 0.9 - (locationX/maximumWidth)
            
            //TARGETING RIGHT LOCATION TO BE DRAGGED
            if gesture?.state == .began {
                
                draggingDirection = locationX
                let limitSwipe = parentController.view.bounds.width - 30 //(parentController.view.bounds.width/5)
                draggingAllowed = (limitSwipe < location.x)
                percentage(originalPercentage, sideToggle: false)
            }
        }
        else {
            //GETTING LEFT LOCATION WILL BEGAN DRAGGING
            locationX = locationClosed + location.x + 15
            alpha = (locationX/maximumWidth) + 0.6
            
            //TARGETING LEFT LOCATION TO BE DRAGGED
            if gesture?.state == .began {
                
                draggingDirection = locationX
                let limitSwipe:CGFloat = 30 //parentController.view.bounds.width/5
                draggingAllowed = (limitSwipe > location.x)
                percentage(originalPercentage, sideToggle: false)
            }
        }
        
        draggingState(gesture!.state, locationX: locationX, alpha: alpha)
    }
    
    fileprivate class func draggingState(_ state: UIGestureRecognizer.State, locationX: CGFloat, alpha: CGFloat) {
        if enabled == false { return }
        
        if draggingAllowed {
            sideBarDimBackground.isHidden = false
            
            //SETTING NEW LOCATION IN DRAGGING STATE
            if locationX >= locationOpened && direction == "right" {
                self.slideNavigationLocationX(locationX, alpha: alpha)
            }
            else if locationX <= locationOpened && direction == "left" {
                self.slideNavigationLocationX(locationX, alpha: alpha)
            }

            if state == .began {
                //HIDE KEYBOARD
                navigationDrawer.isHidden = false
                navigationDrawer.isUserInteractionEnabled = false
                parentController.view.endEditing(true)
                updateFrame()
            }
            if state == .ended || state == .cancelled {
                if direction == "right" {
                    //RIGHT DIRECTION SWIPTE STATE
                    draggingDirection > locationX ?
                        leftSideToggle() : rightSideToggle()
                }
                else {
                    //LEFT DIRECTION SWIPTE STATE
                    draggingDirection < locationX ?
                        rightSideToggle() : leftSideToggle()
                }
            }
        }
        
    }
    
    fileprivate class func slideNavigationLocationX(_ locationX: CGFloat, alpha: CGFloat) {

        if direction == "right" {
            draggingDirection = (locationX < draggingDirection) ?
                (locationX - 1) : (locationX + 1)
        }
        else {
            draggingDirection = (locationX > draggingDirection) ?
                (locationX - 1) : (locationX + 1)
        }
        
        navigationDrawer.frame.origin.x = locationX
        if alpha <= 0.5 {
            var bColor = UIColor.black
            bColor = bColor.withAlphaComponent(alpha);
            sideBarDimBackground.backgroundColor = bColor
        }
    }
    
    fileprivate class func closeToggle() {
        allowedOpeningGesture = false
        didOpen = false;
        
        DispatchQueue.main.async(execute: {
            
            navigationDrawer.viewWillDisappear()
            navigationDrawer.isUserInteractionEnabled = true
            
            animate(withDuration: 0.25, animations: {
                navigationDrawer.frame.origin.x = locationClosed
                var bColor = UIColor.black
                bColor = bColor.withAlphaComponent(0);
                sideBarDimBackground.backgroundColor = bColor
                
            }, completion: { (Bool) in
                navigationDrawer.viewDidDisappear()
                sideBarDimBackground.frame.size.width = 0
                sideBarDimBackground.isHidden = true
                allowedOpeningGesture = true
                navigationDrawer.isHidden = true
                percentage(originalPercentage, sideToggle: false)
            }) 
            
        })
    }
    
    fileprivate class func openToggle() {

        if navigationDrawer != nil {
            didOpen = true
            DispatchQueue.main.async(execute: {
                
                sideBarDimBackground.isHidden = false
                navigationDrawer.isHidden = false
                navigationDrawer.isUserInteractionEnabled = true
                parentController.view.endEditing(true)
                
                animate(withDuration: 0.25, animations: {
                    sideBarDimBackground.backgroundColor = UIColor.black.withAlphaComponent(0.5);
                    navigationDrawer.frame.origin.x = locationOpened
                    navigationDrawer.frame.size.width = slideNavigationWidth
                    navigationDrawer.layoutIfNeeded()
                })
                
            })
        }
    }
    
    fileprivate class func updateFrame() {
        let frame = parentController.view.bounds
        
        //REFRESH THE DIMBACKGROUND
        if sideBarDimBackground.frame.size.width == 0 {
            sideBarDimBackground.alpha = 0
            animate(withDuration: 0.05, animations: { sideBarDimBackground.alpha = 1 } )
        }
        
        //REFRESH ALL FRAME
        sideBarDimBackground.frame = frame
        navigationDrawer.frame = frame
        
        navigationDrawer.frame.size.width = slideNavigationWidth
        if isOpen {
            navigationDrawer.frame.origin.x = locationOpened;
        }
        else {
            navigationDrawer.frame.origin.x = locationClosed
        }
    }

    fileprivate class func initialize(view: UIView) {
        
        let frame = parentController.view.bounds
        sideBarDimBackground = UIView(frame: frame)
        sideBarDimBackground.isHidden = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(sideToggle))
        sideBarDimBackground.addGestureRecognizer(tapGesture)
        
        let view = view as? RDNavigationDrawer
        navigationDrawer = view //registerNib(name: view?.nibName ?? "")
        navigationDrawer.frame = frame
  
        addShadow()
        addSwipeGesture()
        
        isPortrait = (frame.width < frame.height)
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    @objc fileprivate class func rotated() {
        if navigationDrawer != nil {
            
            DispatchQueue.main.asyncAfter(
                deadline: DispatchTime.now() + Double(Int64(0.01 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                    
                    let frame = parentController.view.bounds
                    let currentPortrait:Bool = (frame.height > frame.width)
                    
                    if isPortrait != currentPortrait {
                        isPortrait = currentPortrait
                        
                        if didOpen {
                            sideToggle()
                            navigationDrawer.isHidden = true
                            sideBarDimBackground.isHidden = true
                        }
                        else {
                            percentage(originalPercentage, sideToggle: false)
                        }
                    }
            })
            
        }
    }

    fileprivate class func rightSideToggle() {
        (direction == "right") ? closeToggle() : openToggle()
    }
    
    fileprivate class func leftSideToggle() {
        (direction == "left") ? closeToggle() : openToggle() 
    }
    
    fileprivate class func percentage(_ percentage: CGFloat, sideToggle: Bool) {
        if navigationDrawer != nil {
            let frame = parentController.view.bounds;
            let baseFrameWidth = isPortrait ? frame.width : frame.height
            
            let frameWidth = isiPad ? (baseFrameWidth/2) :
                isPortrait ? baseFrameWidth : (baseFrameWidth + 50)
            
            if direction == "right" {
                slideNavigationWidth = frameWidth * (percentage/100)
                locationClosed = frame.width + 10
                locationOpened = frame.width - slideNavigationWidth
            }
            else {
                slideNavigationWidth = frameWidth * (percentage/100)
                locationClosed = -(slideNavigationWidth + 10)
                locationOpened = 0
            }
            
            if sideToggle {
                percentage > 0 ? openToggle() : closeToggle()
            }
            else {
                navigationDrawer.frame.size.width = slideNavigationWidth
                navigationDrawer.frame.origin.x = locationClosed;
            }
            
        }
    }
    
    public static func right(target: Any?, view: UIView, percentage: CGFloat, isTopMost: Bool = true) {
        
        if let target = target as? UIViewController {
            targetController = target
            parentController = target.parent ?? target
            
            if navigationDrawer != nil {
                closingPanGesture = nil
                openingPanGesture = nil
                sideBarDimBackground.removeFromSuperview()
                navigationDrawer.removeFromSuperview()
            }
            
            direction = "right";
            enabled = true
            
            initialize(view: view)
            target.view.addSubview(sideBarDimBackground);
            
            originalPercentage = percentage
            self.percentage(originalPercentage, sideToggle: false)
            target.view.addSubview(navigationDrawer)
            
            if isTopMost {
                topMost()
            }
            closeToggle()
            navigationDrawer.viewDidLoad()
        }
        
    }
    
    public static func left(target: Any?, view: UIView, percentage: CGFloat, isTopMost: Bool = true) {
        
        if let target = target as? UIViewController {
            targetController = target
            parentController = target.parent ?? target

            if navigationDrawer != nil {
                closingPanGesture = nil
                openingPanGesture = nil
                sideBarDimBackground.removeFromSuperview()
                navigationDrawer.removeFromSuperview()
            }
            
            direction = "left";
            enabled = true
            
            initialize(view: view)
            target.view.addSubview(sideBarDimBackground);
            
            originalPercentage = percentage
            self.percentage(originalPercentage, sideToggle: false)
            target.view.addSubview(navigationDrawer)
            
            if isTopMost {
                topMost()
            }
            closeToggle()
            navigationDrawer.viewDidLoad()
        }
        
    }
    
    public static func sideToggleWithPercentage(_ percentage: CGFloat) {
        self.percentage(percentage, sideToggle: true)
    }
    
    @objc public static func sideToggle() {
        if navigationDrawer != nil {
           navigationDrawer.viewDidLoad()
            if navigationDrawer.isUserInteractionEnabled {
                updateFrame()
                
                if didOpen {
                    (direction == "right") ? rightSideToggle() : leftSideToggle()
                }
                else {
                    percentage(originalPercentage, sideToggle: false)
                    (direction == "right") ? leftSideToggle() : rightSideToggle()
                }
            }
        }
    }
    
    public static func requireGestureRecognizerToFail(_ gesture: UIGestureRecognizer?) {
        if openingPanGesture != nil {
            openingPanGesture.require(toFail: gesture!)
        }
    }
    
    public static func allowGestures(_ value: Bool) {
        allowedOpeningGesture = value
        allowedClosingGesture = value
        addSwipeGesture()
    }
    
    public static func allowOpeningGesture(_ value: Bool) {
        allowedOpeningGesture = value
        addSwipeGesture()
    }
    
    public static func allowClosingGesture(_ value: Bool) {
        allowedClosingGesture = value
        addSwipeGesture()
    }
    
    public static func enable(_ value: Bool) {
        enabled = value;
    }
    
    public static var isOpen:Bool {
        return didOpen;
    }
    
    public static func topMost() {
        if navigationDrawer != nil {
            let keyWindow = UIApplication.shared.keyWindow
            keyWindow?.addSubview(sideBarDimBackground)
            keyWindow?.addSubview(navigationDrawer)
        }
        didOpen = false
    }
    
}
