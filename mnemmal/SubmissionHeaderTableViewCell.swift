//
//  SubmissionHeaderTableViewCell.swift
//  mnemmal
//
//  Created by Danil on 30/10/2017.
//  Copyright © 2017 Danil Chernyshev. All rights reserved.
//

import UIKit

class SubmissionHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var scrollingImage: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var proceedButton: UIButton!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var myView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
