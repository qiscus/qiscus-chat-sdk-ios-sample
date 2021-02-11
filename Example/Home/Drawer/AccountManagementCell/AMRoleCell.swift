//
//  AMRoleCell.swift
//  Example
//
//  Created by Qiscus on 09/02/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit

class AMRoleCell: UITableViewCell {
    @IBOutlet weak var tagListView: TagListView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setupUI(){
        //tag
        tagListView.textFont = .systemFont(ofSize: 17)
        tagListView.shadowRadius = 2
        tagListView.shadowOpacity = 0.4
        //tagListView.shadowColor = UIColor.black
        //tagListView.shadowOffset = CGSize(width: 1, height: 1)
        tagListView.alignment = .left
        tagListView.enableRemoveButton = false
        //tagListView.delegate = self
    }
    
    func setupData(dataRole : [String]){
        if dataRole.count != 0 {
            self.tagListView.removeAllTags()
            for data in dataRole {
                self.tagListView.addTag(data)
            }
        }
    }
    
}
