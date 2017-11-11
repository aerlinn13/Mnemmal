//
//  SummaryVC.swift
//  mnemmal
//
//  Created by Danil on 03/10/2017.
//  Copyright © 2017 Danil Chernyshev. All rights reserved.
//

import UIKit

class SummaryVC: UIViewController {

    
    // - MARK: IB variables

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func closeAct(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var deleteStoryOutlet: UIButton!
    @IBAction func deleteStory(_ sender: Any) {
        delegate.removeStory(indexPath: self.storyIndexPath!, storyId: self.story!.id)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var closeOutlet: UIButton!
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!

    // - MARK:  Variables
    
    var story: Story?
    var user: User?
    var delegate: StoryRemovalDelegate!
    var storyIndexPath: IndexPath?
    
    
    // UI configuration

    
    func configureHeader() {
        bgImage.image = story?.image
        if let title = story?.title {
            headerLabel.text = title }
        deleteStoryOutlet.layer.cornerRadius = 10.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHeader()
        bgImage.heroID = "cellImage"
        headerLabel.heroID = "header"
    }
}
