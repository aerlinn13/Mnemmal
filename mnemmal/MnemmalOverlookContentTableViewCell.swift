//
//  MnemmalOverlookContentTableViewCell.swift
//  mnemmal
//
//  Created by Danil on 06/11/2017.
//  Copyright © 2017 Danil Chernyshev. All rights reserved.
//

import UIKit
import SwipeCellKit

class MnemmalOverlookContentTableViewCell: SwipeTableViewCell {

    @IBOutlet weak var commentorAvatar: UIImageView!
    @IBOutlet weak var commentorName: UILabel!
    @IBOutlet weak var commentDate: UILabel!
    @IBOutlet weak var commentText: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
