//
//  NewConversationVC.swift
//  Example
//
//  Created by Qiscus on 18/02/19.
//  Copyright © 2019 Qiscus. All rights reserved.
//

import UIKit
import QiscusCore

protocol NewConversationVCDelegate{
    func showProgress()
    func loadContactsDidSucceed(contacts : [QUser])
    func loadContactsDidFailed(message: String)
}

class NewConversationVC: UIViewController {
    @IBOutlet weak var labelLoading: UILabel!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var ivSearch: UIImageView!
    @IBOutlet weak var tvMarginBottom: NSLayoutConstraint!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var ivCreateGroup: UIImageView!
    @IBOutlet weak var viewCreateGroup: UIView!
    
    
    internal var contactAll: [QUser]? = nil
    var searchActive : Bool = false
    var keywordSearch : String? = nil
    var page : Int = 1
    var stopLoad : Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getContacts()
        let center: NotificationCenter = NotificationCenter.default
        center.addObserver(self, selector: #selector(NewConversationVC.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        center.addObserver(self, selector: #selector(NewConversationVC.keyboardChange(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        view.endEditing(true)
    }
    
    @objc func getContacts(){
        if self.stopLoad == true{
            return
        }
        
        QiscusCore.shared.getUsers(searchUsername: keywordSearch, page: page, limit: 20, onSuccess: { (contacts, metaData) in
            
            if (metaData.currentPage! >= self.page){
                
                if metaData.currentPage! == self.page {
                    self.stopLoad = true
                }else{
                    self.page += 1
                }
                
                self.loadContactsDidSucceed(contacts: contacts)
            }
            
        }) { (error) in
            self.loadContactsDidFailed(message: error.message)
        }
    }
    
    private func setupUI() {
        self.title = "New Conversation"
        
        let backButton = self.backButton(self, action: #selector(NewConversationVC.goBack))
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.leftBarButtonItems = [backButton]
       
       //table view
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "ContactCell", bundle: nil), forCellReuseIdentifier: "ContactCellIdentifire")
        
        //setup search
        searchBar.delegate = self
        searchBar.backgroundImage = UIImage()
        searchBar.showsCancelButton = false
        
        //view create group
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.createGroup(_:)))
        self.viewCreateGroup.addGestureRecognizer(tap)
        
        ivCreateGroup.image = UIImage(named: "ic_new_chat_group")?.withRenderingMode(.alwaysTemplate)
        ivCreateGroup.tintColor = #colorLiteral(red: 0.5176470588, green: 0.7607843137, blue: 0.3803921569, alpha: 1)
    }
    
    
    @objc func createGroup(_ sender: UITapGestureRecognizer) {
        let target = CreateNewGroupVC()
        self.navigationController?.pushViewController(target, animated: true)
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
    
    @objc func goBack() {
        view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    func chat(withRoom room: QChatRoom){
        let target = UIChatViewController()
        target.room = room
        self.navigationController?.pushViewController(target, animated: true)
    }
    
    // MARK: - Keyboard Methode
    @objc func keyboardWillHide(_ notification: Notification){
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let viewHeight = self.view.frame.height
            self.view.frame = CGRect(x: self.view.frame.origin.x,
                                     y: self.view.frame.origin.y,
                                     width: self.view.frame.width,
                                     height: viewHeight + keyboardSize.height)
        } else {
            debugPrint("We're about to hide the keyboard and the keyboard size is nil. Now is the rapture.")
        }
    }
    
    @objc func keyboardChange(_ notification: Notification){
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
           let window = self.view.window?.frame {
            // We're not just minusing the kb height from the view height because
            // the view could already have been resized for the keyboard before
            self.view.frame = CGRect(x: self.view.frame.origin.x,
                                        y: self.view.frame.origin.y,
                                        width: self.view.frame.width,
                                        height: window.origin.y + window.height - keyboardSize.height)
        } else {
            debugPrint("We're showing the keyboard and either the keyboard size or window is nil: panic widely.")
        }
        
    }
    
}

extension NewConversationVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        self.tableView.deselectRow(at: indexPath, animated: true)
        if let contact = self.contactAll{
            let userId = contact[indexPath.row].id
            QiscusCore.shared.chatUser(userId: userId, onSuccess: { (room, comments) in
                 self.chat(withRoom: room)
            }) { (error) in
                print("error chat: \(error.message)")
            }
        }
    }
}

extension NewConversationVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
       return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contactAll?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCellIdentifire", for: indexPath) as! ContactCell
        
        if let contacts = self.contactAll{
            let contact = contacts[indexPath.row]
            cell.configureWithData(contact: contact)
            
            if indexPath.row == contacts.count - 1{
                self.getContacts()
            }
        }
       
        self.tableView.tableFooterView = UIView()

        return cell
    }
}

extension NewConversationVC: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.tableView.reloadData()
        searchBar.text = ""
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false
        
        self.keywordSearch = ""
        self.page = 1
        self.stopLoad = false
        self.getContacts()
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    }
    
    func searchBar(_ owsearchBar: UISearchBar, textDidChange searchText: String) {
        self.keywordSearch = searchText
        self.page = 1
        self.stopLoad = false
        self.contactAll?.removeAll()
        self.tableView.reloadData()
        NSObject.cancelPreviousPerformRequests(withTarget: self,
                                               selector: #selector(self.getContacts),
                                               object: nil)
        
        perform(#selector(self.getContacts),
                with: nil, afterDelay: 0.5)
       
    }
}

extension NewConversationVC: NewConversationVCDelegate {
    func loadContactsDidSucceed(contacts: [QUser]) {
        if let contact = self.contactAll{
           self.contactAll = contact + contacts
        }else{
              self.contactAll = contacts
        }
       
        self.tableView.reloadData()
        self.tvMarginBottom.constant = 0
    }
    internal func showProgress() {
        //show progress
    }
    
    internal func loadContactsDidFailed(message: String) {
        //load contact failed
    }
}
