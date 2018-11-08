//
//  QSearchListCell.swift
//  Example
//
//  Created by Ahmad Athaullah on 9/19/17.
//  Copyright © 2017 Ahmad Athaullah. All rights reserved.
//

import UIKit
import QiscusCore

open class QSearchListCell: UITableViewCell {

    public var comment:CommentModel? {
        didSet{
            setupUI()
        }
    }
    public var searchText = ""{
        didSet{
            self.searchTextChanged()
        }
    }
    override open func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override open func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    open func setupUI(){}
    open func searchTextChanged(){}
}
