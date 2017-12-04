//
//  StoryOverlookVC.swift
//  mnemmal
//
//  Created by Danil on 17/10/2017.
//  Copyright © 2017 Danil Chernyshev. All rights reserved.
//

import UIKit
import PKHUD

class StoryOverlookVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - IB Elements
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var closeOutlet: UIButton!
    @IBAction func closeAction(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Variables
    
    var story: Story?
    var user: User?
    var storyIndexPath: IndexPath?
    var delegate: GetStoryDelegate!
    
    // MARK: - TableView DataSource methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell0 = tableView.dequeueReusableCell(withIdentifier: "StoryOverlookHeaderTableViewCell") as! StoryOverlookHeaderTableViewCell
        cell0.headerImage.image = story?.image
        cell0.headerLabel.heroID = "label"
        self.closeOutlet.heroID = "close"
        cell0.headerLabel.text = story?.title
        
        let cell1 = tableView.dequeueReusableCell(withIdentifier: "StoryOverlookContentTableViewCell") as! StoryOverlookContentTableViewCell
        cell1.textField.text = story?.subtext
        cell1.epigraph.text = story?.epigraph
        cell1.secondPartyButton.isHidden = false
        cell1.secondPartyButton.setTitle(nil, for: .normal)
        cell1.secondPartyButton.removeTarget(self, action: nil, for: .allEvents)
        cell1.secondPartyButton.addTarget(self, action: #selector(getStory(sender:)), for: .touchUpInside)
        cell1.secondPartyButton.tag = 1
        
        switch indexPath.row {
        case 0: return cell0
        case 1: return cell1
        default: return cell0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var size = UITableViewAutomaticDimension
        if indexPath.row == 0 {
            size = tableView.frame.width
        }
        return size
    }
    
    @objc func getStory(sender: UIButton!) {
        let initialStoryTrack = "0"
        delegate.getStory(initialStoryTrack: initialStoryTrack, fromSubmission: false)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib0 = UINib(nibName: "StoryOverlookHeaderTableViewCell", bundle: nil)
        tableView.register(nib0, forCellReuseIdentifier: "StoryOverlookHeaderTableViewCell")
        let nib1 = UINib(nibName: "StoryOverlookContentTableViewCell", bundle: nil)
        tableView.register(nib1, forCellReuseIdentifier: "StoryOverlookContentTableViewCell")
        print("storyOverlook(): story title is " + String(describing: self.story?.title))
        tableView.estimatedRowHeight = tableView.frame.width
        tableView.rowHeight = UITableViewAutomaticDimension
    }
}
