//
//  ViewController.swift
//  qonsultant
//
//  Created by Ahmad Athaullah on 7/27/16.
//  Copyright © 2016 qiscus. All rights reserved.
//

import UIKit
import QiscusUI

extension UIViewController {

    func qiscusAutoHideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.qiscusDismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func qiscusDismissKeyboard() {
        view.endEditing(true)
    }

    func showLoading(withText text: String = "Please wait...") {
        let alert = UIAlertController(title: nil, message: text, preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }
    
    func dismissLoading() {
        dismiss(animated: false, completion: nil)
    }
    
}
