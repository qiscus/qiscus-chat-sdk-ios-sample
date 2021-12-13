//
//  HDCIContactCustomerPropertisCell.swift
//  Example
//
//  Created by arief nur putranto on 09/12/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit

class HDCIContactCustomerPropertisCell: UITableViewCell {

    @IBOutlet weak var tableViewHeightCons: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    var customerProperties = [CustomerProperties]()
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UINib(nibName: "ListContactCustomerPropertiesCell", bundle: nil), forCellReuseIdentifier: "ListContactCustomerPropertiesCellIdentifire")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension HDCIContactCustomerPropertisCell: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customerProperties.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListContactCustomerPropertiesCellIdentifire", for: indexPath) as! ListContactCustomerPropertiesCell
        let data = self.customerProperties[indexPath.row]
        if data.label.isEmpty == true {
            cell.lbLabel.text = "-"
        } else {
            cell.lbLabel.text = data.label
        }
        
        if data.value.isEmpty == true {
            cell.lbValue.text = "-"
        } else {
            cell.lbValue.text = data.value
        }
        return cell
    }
    
}
