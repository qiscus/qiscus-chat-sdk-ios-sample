//
//  RDNavigationDrawerGesture.swift
//  Full Scale
//
//  Created by Randolf Dini-ay on 15/03/2019.
//  Copyright © 2019 Randolf Dini-ay. All rights reserved.
//

import UIKit

open class RDNavigationDrawer: UIView, RDNavigationDrawerDelegate {
    
    @IBOutlet private weak var view: UIView!
    
    func viewDidLoad() { }
    
    func viewWillAppear() { }
    
    func viewWillDisappear() { }
    
    func viewDidDisappear() { }
    
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func nibSetup() {
        backgroundColor = .clear
        
        view = loadViewFromNib() as? RDNavigationDrawer
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        
        addSubview(view)
    }
    
    private func loadViewFromNib() -> UIView {
        let view = Bundle.main.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?[0] as! UIView;
        let navigationDrawer = view as! RDNavigationDrawer
        return navigationDrawer;
    }
    
}
