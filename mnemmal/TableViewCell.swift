//
//  FeedTableViewCell.swift
//  
//
//  Created by Danil on 28/09/2017.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet var anonymWroteLabel: UILabel!
    
    @IBOutlet var contentLabel: UILabel!
    
    @IBOutlet weak var clearComment: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
