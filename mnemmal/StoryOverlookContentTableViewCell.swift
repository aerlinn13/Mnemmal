//
//  StoryOverlookContentTableViewCell.swift
//  mnemmal
//
//  Created by Danil on 25/10/2017.
//  Copyright © 2017 Danil Chernyshev. All rights reserved.
//

import UIKit

class StoryOverlookContentTableViewCell: UITableViewCell {

    @IBOutlet weak var epigraph: UILabel!
    @IBOutlet weak var textField: UILabel!
    @IBOutlet weak var choosePartyLabel: UILabel!
    @IBOutlet weak var firstPartyButton: UIButton!
    @IBOutlet weak var secondPartyButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
