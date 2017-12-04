//
//  SummaryDayOpenerTableViewCell.swift
//  mnemmal
//
//  Created by Danil on 15/11/2017.
//  Copyright © 2017 Danil Chernyshev. All rights reserved.
//

import UIKit

class SummaryDayOpenerTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
