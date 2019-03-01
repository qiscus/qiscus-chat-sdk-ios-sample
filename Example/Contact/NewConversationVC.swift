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
    func loadContactsDidSucceed(contacts : [MemberModel])
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
    
    
    internal var contactAll: [MemberModel]? = nil
    var searchActive : Bool = false
    var keywordSearch : String? = nil
    var page : Int = 1
    var stopLoad : Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getContacts()
    }
    
    @objc func getContacts(){
        if self.stopLoad == true{
            return
        }
        QiscusCore.shared.getUsers(limit: 20, page: page, querySearch: keywordSearch, onSuccess: { (contacts, metaData) in
            
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
    
    func chat(withRoom room: RoomModel){
        let target = UIChatViewController()
        target.room = room
        self.navigationController?.pushViewController(target, animated: true)
    }
    
}

extension NewConversationVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        if let contact = self.contactAll{
            let name = contact[indexPath.row].username
            QiscusCore.shared.getRoom(withUser: name, onSuccess: { (room, comments) in
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
        
        self.keywordSearch = nil
        self.page = 1
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
    func loadContactsDidSucceed(contacts: [MemberModel]) {
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
