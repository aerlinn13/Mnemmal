//
//  SubmissionFooterComTableViewCell.swift
//  mnemmal
//
//  Created by Danil on 02/11/2017.
//  Copyright © 2017 Danil Chernyshev. All rights reserved.
//

import UIKit

class SubmissionFooterComTableViewCell: UITableViewCell {
    
    @IBOutlet weak var myView: UIView!
    @IBOutlet weak var commentView: UIView!
    
    @IBOutlet weak var commentorAvatar: UIImageView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var commentorNameLabel: UILabel!
    @IBOutlet weak var commentDateTime: UILabel!
    
    @IBOutlet weak var likeButtonOutlet: UIButton!
    @IBOutlet weak var commentButtonOutlet: UIButton!
    @IBOutlet weak var shareButtonOutlet: UIButton!
    
    @IBOutlet weak var likesAmountLabel: UILabel!
    @IBOutlet weak var commentsAmountLabel: UILabel!
    
    var liked: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        likeButtonOutlet.imageView?.contentMode = .scaleAspectFit
        commentButtonOutlet.imageView?.contentMode = .scaleAspectFit
        shareButtonOutlet.imageView?.contentMode = .scaleAspectFit
        likeButtonOutlet.titleLabel?.minimumScaleFactor = 0.5
        likeButtonOutlet.titleLabel?.adjustsFontSizeToFitWidth = true
        commentButtonOutlet.titleLabel?.minimumScaleFactor = 0.5
        commentButtonOutlet.titleLabel?.adjustsFontSizeToFitWidth = true
        shareButtonOutlet.titleLabel?.minimumScaleFactor = 0.5
        shareButtonOutlet.titleLabel?.adjustsFontSizeToFitWidth = true

        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
