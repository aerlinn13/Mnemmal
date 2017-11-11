//
//  SubmissionCloserTableViewCell.swift
//  mnemmal
//
//  Created by Danil on 01/11/2017.
//  Copyright © 2017 Danil Chernyshev. All rights reserved.
//

import UIKit

class SubmissionCloserTableViewCell: UITableViewCell {

    
    @IBOutlet weak var myView: UIView!
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var firstOptionButton: UIButton!
    @IBOutlet weak var secondOptionButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
