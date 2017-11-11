//
//  MnemmalOverlookHeaderTableViewCell.swift
//  mnemmal
//
//  Created by Danil on 06/11/2017.
//  Copyright © 2017 Danil Chernyshev. All rights reserved.
//

import UIKit
import SwipeCellKit

class MnemmalOverlookHeaderTableViewCell: SwipeTableViewCell {

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var mnemmalTextView: UITextViewFixed!
    @IBOutlet weak var authorAvatar: UIImageView!
    @IBOutlet weak var authorName: UILabel!
    @IBOutlet weak var mnemmalDate: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var copyButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
