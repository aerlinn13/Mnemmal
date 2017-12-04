//
//  SummaryDayWordsUnitCollectionViewCell.swift
//  mnemmal
//
//  Created by Danil on 17/11/2017.
//  Copyright © 2017 Danil Chernyshev. All rights reserved.
//

import UIKit

class SummaryDayWordsUnitCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var definitionBaseView: UIView!

    @IBOutlet weak var definition: UILabel!
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var wordLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
