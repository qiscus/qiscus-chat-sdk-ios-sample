//
//  QLoadingViewController.swift
//  QiscusSDK
//
//  Created by Ahmad Athaullah on 12/16/16.
//  Copyright © 2016 Ahmad Athaullah. All rights reserved.
//

import UIKit

open class QLoadingViewController: UIViewController {
    open static let sharedInstance = QLoadingViewController()
    
    @IBOutlet weak var loadingImage: UIImageView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    
    open var percentage:Float = 0
    open var showPercentage = false
    open var showText = false
    open var isPresence = false
    open var isBlocking = false
    open var interuptLoadingAction:()->Void = ({})
    open var dismissImmediately: Bool = false
    
    fileprivate init() {
        super.init(nibName: "QLoadingViewController", bundle:nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true , animated: false)
        self.loadingLabel.isHidden = !showText
        self.percentageLabel.isHidden = !showText
        
    }
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true , animated: false)
        self.isPresence = true
        var images: [UIImage] = []
        for i in 0...11 {
            images.append(UIImage(named: "loading\(i+1)")!)
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(QLoadingViewController.onTapLoading))
        self.view.addGestureRecognizer(tap)
        
        self.loadingImage.animationImages = images
        self.loadingImage.animationDuration = 1
        self.loadingImage.animationRepeatCount = 0
        self.loadingImage.startAnimating()
    }
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.isPresence = false
    }
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc open func onTapLoading() {
        if !self.isBlocking{
            self.dismiss(animated: true, completion: {
                self.interuptLoadingAction()
            })
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}
