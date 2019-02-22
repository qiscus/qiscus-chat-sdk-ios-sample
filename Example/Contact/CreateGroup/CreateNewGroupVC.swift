//
//  CreateNewGroupVC.swift
//  Example
//
//  Created by Qiscus on 18/02/19.
//  Copyright © 2019 Qiscus. All rights reserved.
//

import UIKit
import QiscusCore
import AlamofireImage

protocol CreateNewGroupVCDelegate{
    func showProgress()
    func loadContactsDidSucceed(contacts : [MemberModel])
    func searchContactDidSucceed(contacts : [MemberModel])
    func loadContactsDidFailed(message: String)
}

class CreateNewGroupVC: UIViewController {
    @IBOutlet weak var labelLoading: UILabel!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var ivSearch: UIImageView!
    @IBOutlet weak var tvMarginBottom: NSLayoutConstraint!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var viewCreateGroup: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var heightCollCons: NSLayoutConstraint!
    internal var selectedContacts: [MemberModel] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    internal var contactAll: [MemberModel]? = nil
    internal var filteredContact: [MemberModel]? = nil
    var searchActive : Bool = false
    var keywordSearch : String = ""
    var page : Int = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getContacts()
    }
    
    func getContacts(){
        QiscusCore.shared.getUsers(limit: 20, page: page, querySearch: nil, onSuccess: { (contacts, metaData) in
            if (metaData.currentPage != self.page){
                self.page += 1
                self.loadContactsDidSucceed(contacts: contacts)
            }
        }) { (error) in
            self.loadContactsDidFailed(message: error.message)
        }
    }
    
    @objc func search(){
        QiscusCore.shared.getUsers(limit: 100, page: 1, querySearch: self.keywordSearch, onSuccess: { (contacts, metaData) in
            self.searchContactDidSucceed(contacts: contacts)
        }) { (error) in
            self.loadContactsDidFailed(message: error.message)
        }
    }
    
    private func setupNext(){
        let nextButton = self.nextButton(self, action: #selector(CreateNewGroupVC.goNext))
        self.navigationItem.setRightBarButton(nextButton, animated: false)
    }
    
    private func setupUI() {
        self.title = "Choose Contact"
        
        let backButton = self.backButton(self, action: #selector(CreateNewGroupVC.goBack))
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
        
        //collectionView
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "ContactSelectCollCell", bundle: nil), forCellWithReuseIdentifier: "ContactCollectionIdentifier")
        collectionView.backgroundColor = UIColor.white
        heightCollCons.constant = 0
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
    
    private func nextButton(_ target: UIViewController, action: Selector) -> UIBarButtonItem{
        let nextIcon = UIImageView()
        nextIcon.contentMode = .scaleAspectFit
        
        let image = UIImage(named: "ic_next")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        nextIcon.image = image
        nextIcon.tintColor = #colorLiteral(red: 0.5176470588, green: 0.7607843137, blue: 0.3803921569, alpha: 1)
        
        if UIApplication.shared.userInterfaceLayoutDirection == .leftToRight {
            nextIcon.frame = CGRect(x: 0,y: 11,width: 30,height: 25)
        }else{
            nextIcon.frame = CGRect(x: 22,y: 11,width: 30,height: 25)
        }
        
        let nextButton = UIButton(frame:CGRect(x: 0,y: 0,width: 30,height: 44))
        nextButton.addSubview(nextIcon)
        nextButton.addTarget(target, action: action, for: UIControl.Event.touchUpInside)
        return UIBarButtonItem(customView: nextButton)
    }
    
    @objc func goBack() {
        view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func goNext() {
        view.endEditing(true)
        let vc = CreateGroupInfoVC()
        vc.userGroup = self.selectedContacts
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension CreateNewGroupVC: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.selectedContacts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedContacts.remove(at: indexPath.row)
        self.tableView.reloadData()
        if(selectedContacts.count == 0){
            heightCollCons.constant = 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContactCollectionIdentifier", for: indexPath) as! ContactSelectCollCell
        
        let contactList                 = self.selectedContacts[indexPath.row]
        let placeHolderImage: UIImage   = UIImage(named: "avatar", in: nil, compatibleWith: nil)!
        let cellImageLayer: CALayer?    = cell.profileImageView.layer
        let imageRadius: CGFloat        = CGFloat(cellImageLayer!.frame.size.height / 2)
        let imageSize: CGSize           = CGSize(width: 43, height: 43)
        let imageFilter                 = AspectScaledToFillSizeWithRoundedCornersFilter(size: imageSize, radius: imageRadius)
        cellImageLayer!.cornerRadius    = imageRadius
        cellImageLayer!.masksToBounds   = true
        if let avatarURL = contactList.avatarUrl{
             cell.profileImageView.af_setImage(withURL: avatarURL, placeholderImage: placeHolderImage, filter: imageFilter)
        }
      
        cell.nameLabel.text                 = contactList.username
        let iconImage                       = UIImage(named: "ar_cancel", in: nil, compatibleWith: nil)!
        cell.iconImageView.image            = iconImage.withRenderingMode(.alwaysTemplate)
        cell.iconImageView.tintColor        = UIColor.red
        
        let cellIconLayer: CALayer?         = cell.iconImageView.layer
        let iconRadius: CGFloat             = CGFloat(cellIconLayer!.frame.size.height / 2)
        cellIconLayer!.cornerRadius         = iconRadius
        cellIconLayer!.masksToBounds        = true
        
        return cell
    }
    
}

extension CreateNewGroupVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var ids: [String] = selectedContacts.map{ $0.id }
        if(searchActive == true){
            if let contact = self.filteredContact{
                if !ids.contains(contact[indexPath.row].id){
                    self.selectedContacts.append(contact[indexPath.row])
                }else{
                    if let idx: Int = ids.index(of: contact[indexPath.row].id){
                        self.selectedContacts.remove(at: idx)
                    }
                }
            }
        }else{
            if let contact = self.contactAll{
                if !ids.contains(contact[indexPath.row].id){
                    self.selectedContacts.append(contact[indexPath.row])
                }else{
                    if let idx: Int = ids.index(of: contact[indexPath.row].id){
                        self.selectedContacts.remove(at: idx)
                    }
                }
            }
        }
        
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.tableView.reloadRows(at: [indexPath], with: .none)
        
        if self.selectedContacts.count == 0 {
             heightCollCons.constant = 0
            self.navigationItem.setRightBarButton(nil, animated: true)
        }else{
            heightCollCons.constant = 90
            self.setupNext()
        }
    }
}

extension CreateNewGroupVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return filteredContact?.count ?? 0
        }
        return self.contactAll?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCellIdentifire", for: indexPath) as! ContactCell
        var ids: [String] = selectedContacts.map{ $0.id }
        if(searchActive == true){
            if let contacts = self.filteredContact{
                let contact = contacts[indexPath.row]
                cell.configureWithData(contact: contact)
                if ids.contains(contact.id){
                    cell.ivCheck.isHidden = false
                    cell.ivCheck.layer.cornerRadius = cell.ivCheck.frame.size.height / 2
                }else{
                    cell.ivCheck.isHidden = true
                }
            }
        }else{
            if let contacts = self.contactAll{
                let contact = contacts[indexPath.row]
                cell.configureWithData(contact: contact)
                if ids.contains(contact.id){
                    cell.ivCheck.isHidden = false
                    cell.ivCheck.layer.cornerRadius = cell.ivCheck.frame.size.height / 2
                }else{
                    cell.ivCheck.isHidden = true
                }
                
                if indexPath.row == contacts.count - 1{
                    self.getContacts()
                }
                
            }
        }
        
        self.tableView.tableFooterView = UIView()
        return cell
    }
}

extension CreateNewGroupVC: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        self.tableView.reloadData()
        searchBar.text = ""
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBar(_ owsearchBar: UISearchBar, textDidChange searchText: String) {
        searchActive = true
        self.keywordSearch = searchText
        NSObject.cancelPreviousPerformRequests(withTarget: self,
                                               selector: #selector(self.search),
                                               object: nil)
        
        perform(#selector(self.search),
                with: nil, afterDelay: 0.5)
        
    }
}

extension CreateNewGroupVC: CreateNewGroupVCDelegate {
    func loadContactsDidSucceed(contacts: [MemberModel]) {
        if let contact = self.contactAll{
            self.contactAll = contact + contacts
        }else{
            self.contactAll = contacts
        }
        
        self.tableView.reloadData()
        self.tvMarginBottom.constant = 0
    }
    
    func searchContactDidSucceed(contacts: [MemberModel]){
        self.filteredContact?.removeAll()
        self.filteredContact = contacts
        
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
