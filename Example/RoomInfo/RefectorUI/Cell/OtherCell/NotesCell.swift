//
//  NotesCell.swift
//  Example
//
//  Created by Qiscus on 02/12/20.
//  Copyright © 2020 Qiscus. All rights reserved.
//

import UIKit

class NotesCell: UITableViewCell {

    @IBOutlet weak var lbNotes: UILabel!
    @IBOutlet weak var btIcon: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    func setupUI(){
        btIcon.tintColor = ColorConfiguration.defaultColorTosca
        btIcon.setImage(UIImage(named: "ic_file_attachment")?.withRenderingMode(.alwaysTemplate), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
