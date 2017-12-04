//
//  SubmissionInterimTableViewCell.swift
//  mnemmal
//
//  Created by Danil on 31/10/2017.
//  Copyright © 2017 Danil Chernyshev. All rights reserved.
//

import UIKit

class SubmissionInterimTableViewCell: UITableViewCell {

    @IBOutlet weak var interimImage: UIImageView!
    
    @IBOutlet weak var mnemmalDone: UIImageView!
    
    @IBOutlet weak var successLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
