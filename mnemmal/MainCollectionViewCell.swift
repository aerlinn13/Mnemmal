//
//  MainCollectionViewCell.swift
//  mnemmal
//
//  Created by Danil on 06/09/2017.
//  Copyright © 2017 Danil Chernyshev. All rights reserved.
//

import UIKit

class MainCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var scrollingImage: UIImageView!

    @IBOutlet weak var storyLabel: UILabel!
    
    @IBOutlet weak var premium: UILabel!
    
    @IBOutlet weak var getButton: UIButton!
    
    @IBOutlet weak var dayNumLabel: UILabel!
    
    @IBOutlet weak var dayNumBG: UIImageView!
    
    @IBOutlet weak var removeButton: UIButton!
    
    @IBOutlet weak var overviewButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
