//
//  LevelUpVC.swift
//  mnemmal
//
//  Created by Danil on 27/09/2017.
//  Copyright © 2017 Danil Chernyshev. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase



class LevelUpVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    // - MARK: Variables

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    var story: Story?
    var comments = [String]()

    
    @IBOutlet weak var titleLabel: UILabel!
    @IBAction func doneButton(_ sender: Any) {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var greenView: UIView!
    
    // - MARK: TableView methods
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        cell.contentLabel.text = comments[indexPath.row]
        cell.clearComment.layer.cornerRadius = 10.0
        cell.layoutIfNeeded()
        return cell
    }
    
    // - MARK: Firebase methods
    
    func retrieveComments() {
        if let storyId = self.story?.id {
        let storyRef = Database.database().reference().child("stories/\(storyId)/instances")
            storyRef.keepSynced(true)
            storyRef.observeSingleEvent(of: .value, with: { snapshot in
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                    for snap in snapshots
                    {
                        let content = snap.childSnapshot(forPath: "/content").value as! String
                        self.comments.append(content)
                    }
    }
                self.comments.reverse()
                self.tableView.reloadData()
            })
    }
    }
    
    
    func setUpVC() {
        if let title = self.story?.title { self.titleLabel.text = title }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nibb = UINib(nibName: "TableViewCell", bundle: nil)
        tableView.register(nibb, forCellReuseIdentifier: "TableViewCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        retrieveComments()
        tableView.layoutIfNeeded()
        setUpVC()
        
        // HERO
        
    }
    override func viewDidAppear(_ animated: Bool) {
    }
}
