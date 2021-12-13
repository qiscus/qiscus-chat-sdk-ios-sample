//
//  TagsSuggestionCell.swift
//  Example
//
//  Created by Qiscus on 13/11/20.
//  Copyright © 2020 Qiscus. All rights reserved.
//

import UIKit

class TagsSuggestionCell: UITableViewCell {
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    @IBOutlet weak var lbTagsName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupUI(name : String){
        self.lbTagsName.text = name
    }
    
}
