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
    @IBOutlet weak var subStoryLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var premium: UIImageView!
    
    @IBOutlet weak var removeButton: UIButton!
    
    @IBOutlet weak var underliningView: UIView!
        
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
