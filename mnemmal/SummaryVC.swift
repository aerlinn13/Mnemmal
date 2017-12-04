//
//  SummaryVC.swift
//  mnemmal
//
//  Created by Danil on 03/10/2017.
//  Copyright © 2017 Danil Chernyshev. All rights reserved.
//

import UIKit
import Firebase
import Hero

class SummaryVC: UIViewController, UITableViewDelegate, UITableViewDataSource, WordCollectionDelegate, CommentsDelegate {

    // - MARK: IB variables

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet weak var storyLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var closeOutlet: UIButton!
    @IBOutlet weak var storyImage: UIImageView!
    
    // - MARK:  Variables
    
    var story: Story?
    var user: User?
    var delegate: StoryRemovalDelegate!
    var storyIndexPath: IndexPath?
    var summaries = Array<DailySummary>()
    var storyTrackTemp = ""
    
// TableView methods
    

    func numberOfSections(in tableView: UITableView) -> Int {
        return summaries.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if story!.isNews {
            return 3
        } else { return 4 }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellHeader = tableView.dequeueReusableCell(withIdentifier: "SummaryDayHeaderTableViewCell") as! SummaryDayHeaderTableViewCell
        cellHeader.dayLabel.text = summaries[indexPath.section].title
        
        
        let cellMnemmal = tableView.dequeueReusableCell(withIdentifier: "SummaryDayMnemmalTableViewCell") as! SummaryDayMnemmalTableViewCell
        cellMnemmal.selectionStyle = .none
        cellMnemmal.name.text = self.user!.name
        cellMnemmal.time.text = summaries[indexPath.section].mnemmalDate
        cellMnemmal.content.text = summaries[indexPath.section].mnemmalContent
        cellMnemmal.mnemmalView.layer.cornerRadius = 10.0
        cellMnemmal.avatar.round(corners: .allCorners, radius: cellMnemmal.avatar.bounds.width / 2)
        cellMnemmal.commentsOutlet.text = "Comments: " + String(describing: self.summaries[indexPath.section].comments.count)
        cellMnemmal.likesOutlet.text = "Likes: " + String(describing: self.summaries[indexPath.section].likesAmount)
        if self.user!.fbId != "none" {
            let url = URL(string: "http://graph.facebook.com/\(self.user!.fbId)/picture?type=large")
            print(url!)
            cellMnemmal.avatar.sd_setImage(with: url!, placeholderImage: UIImage(named: "Anon"), options: .continueInBackground, completed: nil)
        } else {
            cellMnemmal.avatar.image = UIImage(named: "Anon")
        }
        cellMnemmal.commentButton.addTarget(self, action: #selector(commentButtonAct(sender:)), for: .touchUpInside)
        cellMnemmal.shareButton.addTarget(self, action: #selector(shareButtonAct(sender:)), for: .touchUpInside)

        let cellWords = tableView.dequeueReusableCell(withIdentifier: "SummaryDayWordsTableViewCell") as! SummaryDayWordsTableViewCell
        cellWords.selectionStyle = .none
        cellWords.words = summaries[indexPath.section].wordsObj!
        cellWords.delegate = self
        
        
        let cellOpener = tableView.dequeueReusableCell(withIdentifier: "SummaryDayOpenerTableViewCell") as! SummaryDayOpenerTableViewCell
        cellOpener.selectionStyle = .none
        cellOpener.baseView.layer.cornerRadius = 10.0
        let text = summaries[indexPath.section].opener!.replacingOccurrences(of: "\\n", with: "\n")
        cellOpener.textView.text = text
        
        if story!.isNews {
        switch indexPath.row {
        case 0: self.tableView.setNeedsLayout(); self.tableView.layoutIfNeeded(); print("return cellHeader"); return cellOpener
        case 1: self.tableView.setNeedsLayout(); self.tableView.layoutIfNeeded(); print("return cellOpener"); return cellWords
        case 2: self.tableView.setNeedsLayout(); self.tableView.layoutIfNeeded(); print("return cellWords"); return cellMnemmal
        default: return cellMnemmal
        }
        } else {
            switch indexPath.row {
            case 0: self.tableView.setNeedsLayout(); self.tableView.layoutIfNeeded(); print("return cellHeader"); return cellHeader
            case 1: self.tableView.setNeedsLayout(); self.tableView.layoutIfNeeded(); print("return cellOpener"); return cellOpener
            case 2: self.tableView.setNeedsLayout(); self.tableView.layoutIfNeeded(); print("return cellWords"); return cellWords
            case 3: self.tableView.setNeedsLayout(); self.tableView.layoutIfNeeded(); print("return cellMnemmal"); return cellMnemmal
            default: return cellMnemmal
        }
    }
    }
    
    
    // cellMnemmal
    
    func updateMnemmalComments() {
        print("updateMnemmalComments(): invoked")
        self.retrieveCommentsForSummaries() { summaries in
            self.animateReloading(self.tableView)
        }
    }
    
    func retrieveCommentsForSummaries(completion: @escaping (Array<DailySummary>) -> Void) {
        print("retrieveCommentsForSummaries(): invoked")
        self.summaries.forEach( { summary in
            if summary.comments.count != 0 {
            summary.comments.removeAll() }
            print("" + self.story!.id + summary.storyTrack! + summary.id!)
            let commentsRef = Database.database().reference().child("comments/\(self.story!.id)/\(summary.storyTrack!)/\(summary.id!)")
            commentsRef.keepSynced(true)
            commentsRef.observeSingleEvent(of: .value, with: { snapshot in
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                    for snap in snapshots {
                        let id = snap.childSnapshot(forPath: "ID").value as! String
                        let userId = snap.childSnapshot(forPath: "userID").value as! String
                        let fbId = snap.childSnapshot(forPath: "fbID").value as! String
                        let userName = snap.childSnapshot(forPath: "userName").value as! String
                        let mnemmalId = snap.childSnapshot(forPath: "mnemmalId").value as! String
                        let time = snap.childSnapshot(forPath: "time").value as! String
                        let content = snap.childSnapshot(forPath: "content").value as! String
                        let mnemmalComment = MnemmalComment(id: id, userId: userId,fbId: fbId, userName: userName, mnemmalId: mnemmalId, time: time, content: content)
                        summary.comments.append(mnemmalComment)
                        print("retrieveCommentsForSummaries(): new MnemmalComment is retrieved, mnemmalID is: " + mnemmalId)
                    }
                    summary.commentsChecked = true
                    var count = self.summaries.count
                    self.summaries.forEach({ summary in
                        if summary.commentsChecked {
                            count -= 1
                            if count == 0 {
                                completion(self.summaries)
                            }
                        }
                    })
                    print("retrieveCommentsForSummaries(): Summary is checked: comments loaded. summary id is: " + summary.id!)
                } else {
                    summary.commentsChecked = true
                    print("retrieveCommentsForSummaries(): Summary is checked: no comments found. summary id is: " + summary.id!)
                    var count = self.summaries.count
                    self.summaries.forEach({ summary in
                        if summary.commentsChecked {
                            count -= 1
                            if count == 0 {
                                completion(self.summaries)
                            }
                        }
                    })
                }
            })
        })
    }
    
    func retrieveLikesForMnemmals(completion: @escaping (Array<DailySummary>) -> Void) {
        print("retrieveLikesForMnemmals(): invoked")
        let likesRef = Database.database().reference().child("likes/\(self.story!.id)")
        likesRef.keepSynced(true)
        likesRef.observeSingleEvent(of: .value, with: { snapshot in
        self.summaries.forEach ({ (summary) in
            print("retrieveLikesForMnemmals(): mnemmal content is " + summary.mnemmalContent!)
            let snap = snapshot.childSnapshot(forPath: "\(summary.storyTrack!)/\(summary.id!)")
            if let likesAmount = snap.value as? String {
                    summary.likesAmount = Int(likesAmount)!
                print("retrieveLikesForMnemmals(): amount of likes is " + String(describing: summary.likesAmount))
                }
            })
            completion(self.summaries)
        })
    }
    
    // MnemmalOverlookDelegate
    
    var mnemmalOverlookPrep: Mnemmal?
    
    func perform(mnemmal: Mnemmal) {
        print("MnemmalOverlookDelegate(): invoked")
        self.mnemmalOverlookPrep = mnemmal
        performSegue(withIdentifier: "mnemmalOverlook", sender: self)
    }
    
    @objc func commentButtonAct(sender: UIButton!) {
        print("commentButtonAct(): invoked")
        let buttonPosition = sender.convert(CGPoint.zero, to: self.tableView)
        if let indexPath = self.tableView.indexPathForRow(at: buttonPosition) {
        print("commentButtonAct(): indexPath is: " + String(describing: indexPath))
            let mnemmal = Mnemmal(id: self.summaries[indexPath.section].id!, userId: self.user!.id!, fbId: self.user!.fbId, userName: self.user!.name!, storyId: self.story!.id, storyTrack: self.summaries[indexPath.section].storyTrack!, time: self.summaries[indexPath.section].mnemmalDate!, likesAmount: "0", content: self.summaries[indexPath.section].mnemmalContent!, liked: false)
        mnemmal.comments = self.summaries[indexPath.section].comments
        tableView.visibleCells.forEach({ $0.heroID = nil })
        tableView.cellForRow(at: indexPath)?.heroID = "mnemmal"
        self.perform(mnemmal: mnemmal)
    }
    }
    
    var avc: UIActivityViewController?
    
    @objc func shareButtonAct(sender: UIButton!) {
        print("shareButtonAct(): invoked")
        let buttonPosition = sender.convert(CGPoint.zero, to: self.tableView)
        if let indexPath = self.tableView.indexPathForRow(at: buttonPosition) {
        print("shareButtonAct(): indexPath is: " + String(describing: indexPath))
        let content = "I wrote a text in Mnemmal app: \"" + self.summaries[indexPath.section].mnemmalContent! + "\""
        avc = UIActivityViewController(activityItems: [content], applicationActivities: nil)
        self.present(avc!, animated: true, completion: nil)
        }
    }
    
    func performWordOutlook(word: Word) {
        print("performWordOutlook(): is invoked")
        self.wordToPass = word
        performSegue(withIdentifier: "summaryWordOverlook", sender: self)
    }
    
    func performWordOutlook(indexPath: IndexPath) {
    }
    
    var wordToPass: Word?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "summaryWordOverlook" {
            let nextScene =  segue.destination as! SummaryWordOverlookVC
            if let word = self.wordToPass { nextScene.word = word }
        } else if segue.identifier == "mnemmalOverlook" {
            let nextScene = segue.destination as! MnemmalOverlookTVC
            if let mnemmal = self.mnemmalOverlookPrep { nextScene.mnemmal = mnemmal }
            if let user = self.user { nextScene.user = user }
            nextScene.commentsDelegate = self
        }
    }
    
    @objc func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func animateReloading(_ tableView: UITableView) {
        print("animateReloading(): invoked")
        let range = Range(uncheckedBounds: (0, tableView.numberOfSections))
        let indexSet = IndexSet(integersIn: range)
        tableView.reloadSections(indexSet, with: .fade)
    }

    func prepareSummaries() {
        print("prepareSummaries(): is invoked")
        if let track = self.user!.storyTrack[self.story!.id] {
        print("prepareSummaries(): storyTrack is: " + track)
        self.storyTrackTemp = track
        let storyId = self.story!.id
        repeat {
        if let summary = self.story!.summaries[self.storyTrackTemp] {
            self.summaries.append(summary)
            print("prepareSummaries(): summary for day is added for story id: " + storyId + " and storyTrack: " + self.storyTrackTemp)
             } else { print("prepareSummaries(): no summary for this track: " + self.storyTrackTemp) }
            if self.storyTrackTemp.count > 0  { self.storyTrackTemp.removeLast(1) }
            print("prepareSummaries(): storyTrack is: " + storyTrackTemp)
        } while self.storyTrackTemp.count != 0
            }
        self.retrieveCommentsForSummaries() { summaries in
            self.retrieveLikesForMnemmals() { summaries in
                self.tableView.reloadData()
            }
        }
    }
    
    func prepareHeader() {
        self.storyImage.image = self.story?.image
        self.storyLabel.text = self.story?.title
        self.cellView.layer.cornerRadius = 10.0
        if (story?.completed)! {
            self.summaries.reverse()
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareHeader()
        closeOutlet.addTarget(self, action: #selector(close), for: .touchUpInside)
        let nib1 = UINib(nibName: "SummaryDayMnemmalTableViewCell", bundle: nil)
        tableView.register(nib1, forCellReuseIdentifier: "SummaryDayMnemmalTableViewCell")
        let nib2 = UINib(nibName: "SummaryDayWordsTableViewCell", bundle: nil)
        tableView.register(nib2, forCellReuseIdentifier: "SummaryDayWordsTableViewCell")
        let nib3 = UINib(nibName: "SummaryDayOpenerTableViewCell", bundle: nil)
        tableView.register(nib3, forCellReuseIdentifier: "SummaryDayOpenerTableViewCell")
        let nib5 = UINib(nibName: "SummaryDayHeaderTableViewCell", bundle: nil)
        tableView.register(nib5, forCellReuseIdentifier: "SummaryDayHeaderTableViewCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        self.cellView.heroID = "cell"
        print("prepareSummaries(): summary count for story: " + String(describing: self.story!.summaries.count))
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            self.prepareSummaries()
        })
    }
}
