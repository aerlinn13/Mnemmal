//
//  StoryOverlookVC.swift
//  mnemmal
//
//  Created by Danil on 17/10/2017.
//  Copyright © 2017 Danil Chernyshev. All rights reserved.
//

import UIKit

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
        cell0.headerImage.heroID = "cellImage"
        cell0.headerLabel.text = story?.title
        cell0.headerLabel.heroID = "cellTitle"
        cell0.layoutIfNeeded()
        
        let cell1 = tableView.dequeueReusableCell(withIdentifier: "StoryOverlookContentTableViewCell") as! StoryOverlookContentTableViewCell
        cell1.textField.text = story?.subtext
        cell1.epigraph.text = story?.epigraph
        cell1.firstPartyButton.setTitle(story?.firstParty, for: .normal)
        cell1.firstPartyButton.addTarget(self, action: #selector(getStory(sender:)), for: .touchUpInside)
        cell1.firstPartyButton.tag = 1
        cell1.secondPartyButton.setTitle(story?.secondParty, for: .normal)
        cell1.secondPartyButton.addTarget(self, action: #selector(getStory(sender:)), for: .touchUpInside)
        cell1.secondPartyButton.tag = 2
        cell1.choosePartyLabel.text  = "Please choose a hero that you want to start your story with."
        
        if indexPath.row == 0 { return cell0 }
        else if indexPath.row == 1 { return cell1 } else { return cell0 }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var size = UITableViewAutomaticDimension
        if indexPath.row == 0 {
            size = tableView.frame.width
        }
        return size
    }
    
    @objc func getStory(sender: UIButton!) {
        let initialStoryTrack = String(describing: sender.tag - 1)
        delegate.getStory(initialStoryTrack: initialStoryTrack)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        closeOutlet.isHidden = true
        super.viewDidLoad()
        let nib0 = UINib(nibName: "StoryOverlookHeaderTableViewCell", bundle: nil)
        tableView.register(nib0, forCellReuseIdentifier: "StoryOverlookHeaderTableViewCell")
        let nib1 = UINib(nibName: "StoryOverlookContentTableViewCell", bundle: nil)
        tableView.register(nib1, forCellReuseIdentifier: "StoryOverlookContentTableViewCell")
        print("storyOverlook(): story title is " + String(describing: self.story?.title))
        tableView.estimatedRowHeight = tableView.frame.width
        tableView.rowHeight = UITableViewAutomaticDimension
        
// HERO
        closeOutlet.heroModifiers = [.rotate(-1.6)]
    
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        closeOutlet.isHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
