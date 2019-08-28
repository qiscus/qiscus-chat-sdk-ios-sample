//
//  EditRoomNameVC.swift
//  Example
//
//  Created by Qiscus on 05/03/19.
//  Copyright © 2019 Qiscus. All rights reserved.
//

import UIKit
import QiscusCore
import Foundation

class EditRoomNameVC: UIViewController {
    @IBOutlet weak var tvName: UITextField!
    var room : RoomModel? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    func setupUI(){
        //setup navigationBar
        self.title = "Edit Room Name"
        let backButton = self.backButton(self, action: #selector(EditRoomNameVC.goBack))
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.leftBarButtonItems = [backButton]
        
        let saveButton = self.saveButton(self, action: #selector(EditRoomNameVC.save))
        self.navigationItem.rightBarButtonItems = [saveButton]
        
        //setup textView
        self.tvName.text = room?.name
        self.tvName.setBottomBorder()
    }
    
    private func backButton(_ target: UIViewController, action: Selector) -> UIBarButtonItem{
        let backIcon = UIImageView()
        backIcon.contentMode = .scaleAspectFit
        
        let image = UIImage(named: "ic_back")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        backIcon.image = image
        backIcon.tintColor = #colorLiteral(red: 0.5176470588, green: 0.7607843137, blue: 0.3803921569, alpha: 1)
        
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
    
    private func saveButton(_ target: UIViewController, action: Selector) -> UIBarButtonItem{
        let saveIcon = UIImageView()
        saveIcon.contentMode = .scaleAspectFit
        
        let image = UIImage(named: "ic_check")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        saveIcon.image = image
        saveIcon.tintColor = #colorLiteral(red: 0.5176470588, green: 0.7607843137, blue: 0.3803921569, alpha: 1)
        
        if UIApplication.shared.userInterfaceLayoutDirection == .leftToRight {
            saveIcon.frame = CGRect(x: 0,y: 11,width: 30,height: 25)
        }else{
            saveIcon.frame = CGRect(x: 22,y: 11,width: 30,height: 25)
        }
        
        let saveButton = UIButton(frame:CGRect(x: 0,y: 0,width: 30,height: 44))
        saveButton.addSubview(saveIcon)
        saveButton.addTarget(target, action: action, for: UIControl.Event.touchUpInside)
        return UIBarButtonItem(customView: saveButton)
    }
    
    @objc func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func save() {
        if(self.tvName.text?.isEmpty == true){
            let alertController = UIAlertController(title: "Failed", message: "Please insert room name", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { alert -> Void in
            })
            
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true) {
                
            }
        }else{
            QiscusCore.shared.updateChatRoom(roomId: (room?.id)!, name: self.tvName.text, avatarURL: nil, extras: nil, onSuccess: { (roomModel) in
                self.navigationController?.popViewController(animated: true)
            }) { (error) in
                //error
            }
        }
    }
    
}
