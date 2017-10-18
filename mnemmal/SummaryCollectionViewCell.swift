//
//  SummaryCollectionViewCell.swift
//  mnemmal
//
//  Created by Danil on 15/10/2017.
//  Copyright © 2017 Danil Chernyshev. All rights reserved.
//

import Foundation
import UIKit

class SummaryCollectionViewCell: UICollectionViewCell, UITableViewDelegate, UITableViewDataSource {

    // MARK:- Variables
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - TableView methods
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell0 = tableView.dequeueReusableCell(withIdentifier: "SummaryOpenerTableViewCell", for: indexPath) as! SummaryOpenerTableViewCell
        let cell1 = tableView.dequeueReusableCell(withIdentifier: "SummaryMnemmalTableViewCell", for: indexPath) as! SummaryMnemmalTableViewCell
        let cell2 = tableView.dequeueReusableCell(withIdentifier: "SummaryCloserTableViewCell", for: indexPath) as! SummaryCloserTableViewCell
        let cell3 = tableView.dequeueReusableCell(withIdentifier: "SummaryActionButtonsTableViewCell", for: indexPath) as! SummaryActionButtonsTableViewCell
        if indexPath.row == 0 { return cell0 }
        if indexPath.row == 1 { return cell1 }
        if indexPath.row == 2 { return cell2 }
        if indexPath.row == 3 { return cell3 }
        return cell0
    }

    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.delegate = self
        tableView.dataSource = self
        let summaryOpenerTableViewCell = UINib(nibName: "SummaryOpenerTableViewCell", bundle: nil)
        tableView.register(summaryOpenerTableViewCell, forCellReuseIdentifier: "SummaryOpenerTableViewCell")
        let summaryMnemmalTableViewCell = UINib(nibName: "SummaryMnemmalTableViewCell", bundle: nil)
        tableView.register(summaryMnemmalTableViewCell, forCellReuseIdentifier: "SummaryMnemmalTableViewCell")
        let summaryCloserTableViewCell =  UINib(nibName: "SummaryCloserTableViewCell", bundle: nil)
        tableView.register(summaryCloserTableViewCell, forCellReuseIdentifier: "SummaryCloserTableViewCell")
        let summaryActionButtonsTableViewCell = UINib(nibName: "SummaryActionButtonsTableViewCell", bundle: nil)
        tableView.register(summaryActionButtonsTableViewCell, forCellReuseIdentifier: "SummaryActionButtonsTableViewCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        
    }
}
