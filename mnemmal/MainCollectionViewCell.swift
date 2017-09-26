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
    
    @IBOutlet weak var storySubheader: UILabel!
    
    @IBOutlet weak var getButton: UIButton!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
