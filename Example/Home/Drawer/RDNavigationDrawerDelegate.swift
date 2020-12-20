//
//  RDNavigationDrawerDelegate.swift
//  Full Scale
//
//  Created by Randolf Dini-ay on 15/03/2019.
//  Copyright © 2019 Randolf Dini-ay. All rights reserved.
//

import UIKit

protocol RDNavigationDrawerDelegate {
    
    var containerView: RDNavigationDrawer { get }
    
    var targetViewController: UIViewController { get }
    
    func viewDidLoad()
    
    func viewWillAppear()
    
    func viewWillDisappear()
    
    func viewDidDisappear()
    
}
