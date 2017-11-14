//
//  SubmissionVC.swift
//  mnemmal
//
//  Created by Danil on 17/09/2017.
//  Copyright © 2017 Danil Chernyshev. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Hero

class SubmissionVC: UIViewController,
UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, WordCollectionDelegate, WordDelegate, MnemmalOverlookDelegate, CommentsDelegate, ShareDelegate {
    
    // - MARK: Variables
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction func closeButton(_ sender: Any) {
        if let cell = tableView.cellForRow(at: IndexPath(item: 2, section: 0)) as? SubmissionContentTableViewCell {
        if cell.textView.text.characters.count != 0 {
            confirmDismissal()
        } else { self.dismiss(animated: true, completion: nil)}
        } else { self.dismiss(animated: true, completion: nil) }
    }
    @IBOutlet weak var closeOutlet: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var story: Story?
    var user: User?
    var storyIndexPath: IndexPath?
    var wordsPoolBackup = Array<Word>()
    var wordsPool = Array<Word>()
    var fetchDelegate: FetchWordsAfterSubmissionDelegate!
    var dayForToday: Day?
    var wordToPass: Word?
    var wordIndexPath: IndexPath?
    var summary: DailySummary?

    // - MARK: TableView methods


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        prepareWords()
        
        let cell1 = tableView.dequeueReusableCell(withIdentifier: "SubmissionHeaderTableViewCell") as! SubmissionHeaderTableViewCell
        cell1.selectionStyle = .none
        cell1.scrollingImage.image = story?.image
        cell1.scrollingImage.heroID = "cellImage"
        cell1.headerLabel.text = dayForToday?.name
        cell1.contentTextView.text = dayForToday?.opener
        cell1.contentTextView.heroModifiers = [.translate()]
        cell1.contentTextView.layer.cornerRadius = 10.0
        if let title = dayForToday?.openerButton { cell1.proceedButton.setTitle(title, for: .normal) } else {
            cell1.proceedButton.setTitle("Start", for: .normal)
        }
        cell1.proceedButton.addTarget(self, action: #selector(goToContentSubmission), for: .touchUpInside)
        cell1.proceedButton.layer.cornerRadius = 10.0
        cell1.myView.heightAnchor.constraint(greaterThanOrEqualToConstant: tableView.frame.height).isActive = true

        
        let cell12 = tableView.dequeueReusableCell(withIdentifier: "SubmissionInterimTableViewCell") as! SubmissionInterimTableViewCell
        cell12.interimImage.image = story?.image
        cell12.interimImage.contentMode = .left
        cell12.interimImage.clipsToBounds = true
        cell12.interimImage.heightAnchor.constraint(greaterThanOrEqualToConstant: tableView.frame.height).isActive = true


        let cell2 = tableView.dequeueReusableCell(withIdentifier: "SubmissionContentTableViewCell") as! SubmissionContentTableViewCell
        cell2.wordsPool = wordsPool
        cell2.submitButton.addTarget(self, action: #selector(submitButtonAct), for: .touchUpInside)
        cell2.textView.textColor = UIColor.darkText
        cell2.textView.delegate = self
        cell2.textView.inputAccessoryView = cell2.collectionView
        cell2.delegate = self
        cell2.selectionStyle = .none
        cell2.myView.heightAnchor.constraint(greaterThanOrEqualToConstant: tableView.frame.height).isActive = true

        let cell23 = tableView.dequeueReusableCell(withIdentifier: "SubmissionInterimTableViewCell") as! SubmissionInterimTableViewCell
        cell23.interimImage.image = story?.image
        cell23.interimImage.clipsToBounds = true
        cell23.interimImage.contentMode = .right
        cell23.interimImage.heightAnchor.constraint(greaterThanOrEqualToConstant: tableView.frame.height).isActive = true
        
        let cell3 = tableView.dequeueReusableCell(withIdentifier: "SubmissionCloserTableViewCell") as! SubmissionCloserTableViewCell
        cell3.selectionStyle = .none
        cell3.bgImage.image = story?.image
        cell3.textView.text = dayForToday?.closer
        cell3.baseView.layer.cornerRadius = 10.0
        cell3.firstOptionButton.layer.cornerRadius = 10.0
        cell3.firstOptionButton.setTitle(dayForToday?.closerOption0, for: .normal)
        cell3.firstOptionButton.tag = 1
        cell3.firstOptionButton.addTarget(self, action: #selector(goToMnemmals(sender:)), for: .touchUpInside)
        cell3.secondOptionButton.layer.cornerRadius = 10.0
        cell3.secondOptionButton.setTitle(dayForToday?.closerOption1, for: .normal)
        cell3.secondOptionButton.tag = 2
        cell3.secondOptionButton.addTarget(self, action: #selector(goToMnemmals(sender:)), for: .touchUpInside)
        cell3.myView.heightAnchor.constraint(greaterThanOrEqualToConstant: tableView.frame.height).isActive = true
        
        let cell34 = tableView.dequeueReusableCell(withIdentifier: "SubmissionInterimTableViewCell") as! SubmissionInterimTableViewCell
        cell34.interimImage.image = story?.image
        cell34.interimImage.clipsToBounds = true
        cell34.interimImage.contentMode = .bottomRight
        cell34.interimImage.heightAnchor.constraint(greaterThanOrEqualToConstant: tableView.frame.height).isActive = true
        
        let cell4 = tableView.dequeueReusableCell(withIdentifier: "SubmissionFooterTableViewCell") as! SubmissionFooterTableViewCell
        cell4.selectionStyle = .none
        cell4.mnemmalOverlookDelegate = self
        cell4.shareDelegate = self
        self.mnemmals.sort { $0.time > $1.time }
        cell4.mnemmals = self.mnemmals
        cell4.completeButton.layer.cornerRadius = 10.0
        cell4.completeButton.addTarget(self, action: #selector(goToMainVC), for: .touchUpInside)
        cell4.myView.heightAnchor.constraint(greaterThanOrEqualToConstant: tableView.frame.height).isActive = true
        
        let cell40 = tableView.dequeueReusableCell(withIdentifier: "SubmissionInterimTableViewCell") as! SubmissionInterimTableViewCell
        cell40.interimImage.image = story?.image
        cell40.interimImage.clipsToBounds = true
        cell40.interimImage.contentMode = .bottomLeft
        cell40.interimImage.heightAnchor.constraint(greaterThanOrEqualToConstant: tableView.frame.height).isActive = true
        
        switch indexPath.row {
        case 0: return cell1 // opener
        case 1: return cell12 // interim
        case 2: return cell2 // content submission
        case 3: return cell23 // interim
        case 4: return cell3 // closer
        case 5: return cell34 // interim
        case 6: return cell4 // mnemmals
        case 7: return cell40 // interim-closer
        default: break
        }
        
        return cell1
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell2 = cell as? SubmissionContentTableViewCell {
            cell2.stopTimer()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let cell = tableView.cellForRow(at: IndexPath(item: 2, section: 0)) as? SubmissionContentTableViewCell {
            cell.textView.resignFirstResponder() }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let _ = tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as? SubmissionHeaderTableViewCell {
        if tableView.visibleCells.count != 1 && self.scrolling == false {
            tableView.selectRow(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .bottom)
        }
    }
    }

    var scrolling = false
    
    // - MARK: Textview methods
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        checkHeaderViewColor()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        checkHeaderViewColor()
    }
    
    func checkHeaderViewColor() {
        if let cell = tableView.cellForRow(at: IndexPath(item: 2, section: 0)) as? SubmissionContentTableViewCell {
        cell.headerLabel.text = String(describing: 300 - cell.textView.text.characters.count)
        if cell.textView.text.characters.count < 50 {
            cell.headerView.backgroundColor = UIColor(red: 6/255.0, green: 71/255.0, blue: 128/255.0, alpha: 1)
            cell.submitButton.isHidden = true
        } else if cell.textView.text.characters.count < 280 {
                cell.headerView.backgroundColor = UIColor(red: 112/255.0, green: 216/255.0, blue: 86/255.0, alpha: 1)
            cell.submitButton.isHidden = false
        } else {
            cell.headerView.backgroundColor = UIColor.red
        if cell.textView.text.characters.count == 300 { cell.textView.text.removeLast(1) }
        }
        cell.textView.text = cell.textView.text.replacingOccurrences(of: "  ", with: " ")
    }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let cell = tableView.cellForRow(at: IndexPath(item: 2, section: 0)) as! SubmissionContentTableViewCell
        if cell.textView.text.count < 301 { return true }
        else { return false }
    }
    
    // MARK:- Cancellation
    
    func confirmDismissal() {
     let alertController = UIAlertController(title: nil, message: "Do you want to close this story? All your writing will be lost.", preferredStyle: .alert)
     let yesButton = UIAlertAction(title: "Yes", style: .destructive, handler: { (action) -> Void in
     print("Yes")
     self.dismiss(animated: true, completion: nil)
     })
     let noButton = UIAlertAction(title: "No", style: .default, handler: { (action) -> Void in
     print("No")
     })
     alertController.addAction(yesButton)
     alertController.addAction(noButton)
     self.present(alertController, animated: true, completion: nil)
     }
    
    // MARK:- Transitions
    
   @objc func goToContentSubmission() {
    print("goToContentSubmission(): invoked")
    scrolling = true
    self.tableView.selectRow(at: IndexPath(item: 1, section: 0), animated: true, scrollPosition: .bottom)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
    self.tableView.selectRow(at: IndexPath(item: 2, section: 0), animated: true, scrollPosition: .top)
    })
    tableView.isScrollEnabled = false
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.9, execute: {
        if let cell = self.tableView.cellForRow(at: IndexPath(item: 2, section: 0)) as? SubmissionContentTableViewCell {
            cell.textView.becomeFirstResponder() }
    })
    }
    
    func goToCloser() {
        scrolling = true
        print("goToCloser(): invoked")
        if let cell = tableView.cellForRow(at: IndexPath(item: 2, section: 0)) as? SubmissionContentTableViewCell {
            cell.textView.inputAccessoryView = nil
            cell.textView.reloadInputViews()
            cell.textView.resignFirstResponder()
        }
        self.tableView.selectRow(at: IndexPath(item: 3, section: 0), animated: true, scrollPosition: .bottom)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
            self.tableView.selectRow(at: IndexPath(item: 4, section: 0), animated: true, scrollPosition: .top)
        })
        
    }
    
    
    @objc func goToMnemmals(sender: UIButton!) {
        print("goToMnemmals(): invoked")
        self.retrieveMnemmals()
        let option = String(sender.tag - 1)
        self.updateStoryTrack(option)
        self.submitDailySummary(option: option)
        self.tableView.selectRow(at: IndexPath(item: 5, section: 0), animated: true, scrollPosition: .bottom)
        self.closeOutlet.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.tableView.selectRow(at: IndexPath(item: 6, section: 0), animated: true, scrollPosition: .top)
            if let cell = self.tableView.cellForRow(at: IndexPath(item: 6, section: 0)) as? SubmissionFooterTableViewCell { cell.mnemmals = self.mnemmals
                cell.tableView.reloadData() }
            
        })
    }
    
    @objc func goToMainVC() {
    print("goToMainVC(): invoked")
        self.tableView.selectRow(at: IndexPath(item: 7, section: 0), animated: true, scrollPosition: .middle)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
            self.dismiss(animated: true, completion: nil)
        })
    }
    

    
    // - MARK: Actions on Submit button
    
    @objc func submitButtonAct() {
        print("submitButtonAct(): invoked")
        self.view.endEditing(true)
        deleteFirstSpace()
        submitMnemmal()
        submitWordsAsUsed()
        increaseStoryLevel()
        fetchDelegate.fetchWordsAfterSubmission(storyLevel: (self.story?.storyLevel)!, completedStatus: (self.story?.completed)!, indexPath: self.storyIndexPath!)
        goToCloser()
    }
    
    var mnemmalSent: Mnemmal?
    
    func submitMnemmal() {
        print("submitMnemmal(): invoked")
        let cell = tableView.cellForRow(at: IndexPath(item: 2, section: 0)) as! SubmissionContentTableViewCell
        let userId = self.user!.id!
        let fbId = self.user!.fbId ?? "none"
        let userName = self.user!.name!
        let storyId = self.story!.id
        let storyTrack = self.user!.storyTrack[story!.id]
        let id = userId + ":" + storyId + ":" + storyTrack!
        let time = getCurrentTime()
        let content = cell.textView.text
        let mnemmal = Mnemmal(id: id, userId: userId, fbId: fbId, userName: userName, storyId: storyId, storyTrack: storyTrack!, time: time, likesAmount: "0", content: content!, liked: false)
        self.mnemmalSent = mnemmal
        let userRef = Database.database().reference().child("users/\(userId)/stories/\(storyId)/instances/\(storyTrack!)").childByAutoId()
        userRef.child("ID").setValue(id)
        userRef.child("userID").setValue(userId)
        userRef.child("fbID").setValue(fbId)
        userRef.child("userName").setValue(userName)
        print("submitMnemmal(): username is: " + userName)
        userRef.child("storyID").setValue(storyId)
        userRef.child("storyTrack").setValue(storyTrack!)
        userRef.child("time").setValue(time)
        userRef.child("content").setValue(content)
        print("submitMnemmal(): Mnemmal submitted for userID: \(userId)")
        let genRef = Database.database().reference().child("stories/\(storyId)/instances/\(storyTrack!)").childByAutoId()
        genRef.child("ID").setValue(id)
        genRef.child("userID").setValue(userId)
        genRef.child("fbID").setValue(fbId)
        genRef.child("userName").setValue(userName)
        print("submitMnemmal(): username is: " + userName)
        genRef.child("storyID").setValue(storyId)
        genRef.child("storyTrack").setValue(storyTrack!)
        genRef.child("time").setValue(time)
        genRef.child("content").setValue(content)
        let userRefForDate = Database.database().reference().child("users/\(userId)/stories/\(storyId)/lastDate")
        userRefForDate.setValue(getCurrentTime())
        print("submitMnemmal(): Mnemmal submitted for storyID: \(storyId)")
    }

    
    func submitDailySummary(option: String) {
        print("submitDailySummary(): invoked")
        // submitting DailySummary
        if let mnemmal = self.mnemmalSent {
            let summaryRef = Database.database().reference().child("users/\(self.user!.id!)/stories/\(mnemmal.storyId)/summaries/\(mnemmal.storyTrack)")
        summaryRef.child("ID").setValue(mnemmal.id)
        summaryRef.child("storyTrack").setValue(mnemmal.storyTrack)
        summaryRef.child("title").setValue(self.dayForToday?.name)
        summaryRef.child("opener").setValue(self.dayForToday?.opener)
        summaryRef.child("mnemmalContent").setValue(mnemmal.content)
        summaryRef.child("mnemmalDate").setValue(mnemmal.time)
            summaryRef.child("closer").setValue(self.dayForToday?.closer)
        switch option {
            case "0": summaryRef.child("chosenOption").setValue(self.dayForToday?.closerOption0)
            case "1": summaryRef.child("chosenOption").setValue(self.dayForToday?.closerOption1)
        default: break
        }
            print("submitDailySummary(): dailySummary has been submitted")
    }
    }
    
    func getCurrentTime() -> String {
        print("getCurrentTime(): invoked")
        let date : Date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        let todaysDate = dateFormatter.string(from: date)
        return todaysDate
    }
    
    func increaseStoryLevel() {
        print("increaseStoryLevel(): invoked")
        let daysRef = Database.database().reference().child("users/\(self.user!.id!)/storyRefs/\(self.story!.id)/")
        let storylvl = Int(self.story!.storyLevel)!
        if storylvl < self.story!.daysAmount {
            self.story?.storyLevel = String(describing: Int(self.story!.storyLevel)! + 1)
            let level = storylvl + 1
            let lvl = String(describing: level)
            daysRef.setValue("\(lvl)")
            print("Level for the story \(self.story!.title) has been set to \(lvl)") }
        else if storylvl == self.story!.daysAmount {
            print("DaysAmount limit (\(storylvl) days) is reached. Story is completed")
            self.story?.completed = true
            self.submitStoryAsCompleted()
        }
    }
    
    func submitWordsAsUsed() {
        print("submitWordsAsUsed(): is invoked")
        let wordsRef = Database.database().reference().child("users/\(self.user!.id!)/stories/\(self.story!.id)/wordUsed/")
        for word in self.wordsPoolBackup {
            wordsRef.child("\(word.id)").setValue("\(word.id)")
            print("Word \(word.title) has been set as used for story \(self.story!.title)")
        }
    }
    
    func submitStoryAsCompleted() {
        print("submitStoryAsCompleted(): is invoked")
        let storyRef = Database.database().reference().child("users/\(self.user!.id!)/stories/\(self.story!.id)/completed")
        storyRef.setValue("true")
    }
    
    func updateStoryTrack(_ option: String) {
        print("updateStoryTrack(): is invoked")
        user?.storyTrack[story!.id]?.append(option)
        print("updateStoryTrack(): story track for story now is " + (user?.storyTrack[story!.id])!)
        let storyTrackRef = Database.database().reference().child("users/\(self.user!.id!)/stories/\(self.story!.id)/storyTrack")
        let track = user!.storyTrack[story!.id]!
        storyTrackRef.setValue(track)
    }
    
    func deleteFirstSpace() {
        print("deleteFirstSpace(): is invoked")
        if let cell = tableView.cellForRow(at: IndexPath(item: 2, section: 0)) as? SubmissionContentTableViewCell {
            if cell.textView.text.first == " " { cell.textView.text.removeFirst(1) }
            if cell.textView.text.last != "." { cell.textView.text.append(".")}
        }
    }
    
    // WordCollectionDelegate
    
    func performWordOutlook(indexPath: IndexPath) {
        print("performWordOutlook(): is invoked")
        self.wordToPass = wordsPool[indexPath.row]
        self.wordIndexPath = indexPath
        performSegue(withIdentifier: "wordOverlook", sender: self)
    }
    
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     if segue.identifier == "wordOverlook" {
     let nextScene =  segue.destination as! WordOverlookVC
     if let word = self.wordToPass { nextScene.word = word }
     nextScene.delegate = self
     } else if segue.identifier == "mnemmalOverlook" {
        let nextScene = segue.destination as! MnemmalOverlookTVC
        if let mnemmal = self.mnemmalOverlookPrep { nextScene.mnemmal = mnemmal }
        if let user = self.user { nextScene.user = user }
        nextScene.commentsDelegate = self
        }
     }
    
    // WordDelegate
    
    func cancel() {
        print("cancel(): is invoked")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
        if let cell = self.tableView.cellForRow(at: IndexPath(item: 2, section: 0)) as? SubmissionContentTableViewCell {
            cell.textView.becomeFirstResponder()
        }
        })
    }
    
    // CommentsDelegate
    
    var indexPathOfMnemmal: IndexPath?
    
    func updateMnemmalComments() {
        self.retrieveCommentsForMnemmals()
    }

    
    // ShareDelegate

    var avc: UIActivityViewController?
    
    func shareContent(content: String) {
         avc = UIActivityViewController(activityItems: [content], applicationActivities: nil)
        self.present(avc!, animated: true, completion: nil)
    }
    
    func didPressButton(string: String) {
        print("didPressButton(): invoked")
        if let cell = tableView.cellForRow(at: IndexPath(item: 2, section: 0)) as? SubmissionContentTableViewCell {
        cell.textView.text.append(" " + string + " ")
        print(string)
        self.wordsPool.remove(at: self.wordIndexPath!.row)
        cell.wordsPool = wordsPool
        cell.collectionView.reloadData()
        if wordsPool.count == 0 {
            cell.textView.inputAccessoryView = cell.submitButton
            cell.textView.reloadInputViews()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
        if let cell = self.tableView.cellForRow(at: IndexPath(item: 2, section: 0)) as? SubmissionContentTableViewCell {
            cell.textView.becomeFirstResponder()
            cell.stopTimer()
            }
        })
    }
        
    // MnemmalOverlookDelegate
    
    var mnemmalOverlookPrep: Mnemmal?
    
    func perform(mnemmal: Mnemmal) {
        print("MnemmalOverlookDelegate(): invoked")
        self.mnemmalOverlookPrep = mnemmal
        performSegue(withIdentifier: "mnemmalOverlook", sender: self)
    }
        
    // - MARK: Configuring for presentation
    
    func prepareWords() {
        print("prepareWords(): invoked")
        if let wpb = story!.wordsObj {
            wordsPoolBackup = wpb } else { print("HUI") }
        wordsPool = wordsPoolBackup
        print("wordsPool count is " + String(describing: wordsPool.count))
    }
    
    // - MARK: Firebase methods
    
    var mnemmals = [Mnemmal]()
    
    func retrieveMnemmals() {
        print("retrieveMnemmals(): invoked")
        if let storyId = self.story?.id {
            let storyTrack = self.user!.storyTrack[storyId]!
            print("retrieveMnemmals(): storyTrack is: " + storyTrack)
            let storyRef = Database.database().reference().child("stories/\(storyId)/instances/\(storyTrack)")
            storyRef.keepSynced(true)
            storyRef.observeSingleEvent(of: .value, with: { snapshot in
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                    for snap in snapshots
                    {
                        let id = snap.childSnapshot(forPath: "ID").value as! String
                        let userId = snap.childSnapshot(forPath: "userID").value as! String
                        let fbId = snap.childSnapshot(forPath: "fbID").value as! String
                        print("retrieveMnemmals(): fbID is: " + fbId)
                        let userName = snap.childSnapshot(forPath: "userName").value as? String ?? "Anonymous"
                        let storyId = snap.childSnapshot(forPath: "storyID").value as! String
                        let storyTrack = snap.childSnapshot(forPath: "storyTrack").value as! String
                        let time = snap.childSnapshot(forPath: "time").value as! String
                        let likesAmount = snap.childSnapshot(forPath: "likesAmount").value as? String ?? "0"
                        let content = snap.childSnapshot(forPath: "content").value as! String
                        print("retrieveMnemmals(): comment is: " + content)
                        let mnemmal = Mnemmal(id: id, userId: userId, fbId: fbId, userName: userName, storyId: storyId, storyTrack: storyTrack, time: time, likesAmount: likesAmount, content: content, liked: false)
                        self.mnemmals.append(mnemmal)
                    }
                }
                self.retrieveLikesForUsersMnemmals()
                self.retrieveCommentsForMnemmals()
                self.retrieveLikesForAllMnemmals()
            })
        }
        }

    func retrieveLikesForUsersMnemmals() {
        print("retrieveLikesForUsersMnemmals(): invoked")
        let storyId = self.story!.id
        let storyTrack = self.user!.storyTrack[storyId]!
        let likesRef = Database.database().reference().child("users/\(self.user!.id)/stories/\(storyId)/likedMnemmals/\(storyTrack)")
        likesRef.keepSynced(true)
        likesRef.observeSingleEvent(of: .value, with: { snapshot in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshots
                {
                    if let mnemmalId = snap.value as? String {
                        print("retrieveLikesForUsersMnemmals(): liked mnemmalID is " + mnemmalId)
                        (self.user!.likedMnemmals[storyId])!.append(mnemmalId)
                        print("retrieveLikesForUsersMnemmals(): likedMnemmals.count is " + String(describing: self.user!.likedMnemmals[storyId]?.count))
                    }
                }
            } else { print("retrieveLikesForUsersMnemmals(): No likes to retrieve")}
        })
    }
    
    func retrieveLikesForAllMnemmals() {
        print("retrieveLikesForAllMnemmals(): invoked")
        self.mnemmals.forEach { (mnemmal) in
            print("retrieveLikesForAllMnemmals(): mnemmal content is " + mnemmal.content)
            let likesRef = Database.database().reference().child("likes/\(mnemmal.storyId)/\(mnemmal.storyTrack)/\(mnemmal.id)")
            likesRef.keepSynced(true)
            likesRef.observeSingleEvent(of: .value, with: { snapshot in
                if let likesAmount = snapshot.value as? String {
                    mnemmal.likesAmount = likesAmount
                    print("retrieveLikesForUsersMnemmals(): amount of likes is " + mnemmal.likesAmount)
                }
        })
    }
    }
    
    func retrieveCommentsForMnemmals() {
        print("retrieveCommentsForMnemmals(): invoked")
        self.mnemmals.forEach( { mnemmal in
            mnemmal.comments.removeAll()
            print("" + mnemmal.storyId + mnemmal.storyTrack + mnemmal.id)
            let commentsRef = Database.database().reference().child("comments/\(mnemmal.storyId)/\(mnemmal.storyTrack)/\(mnemmal.id)")
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
                        mnemmal.comments.append(mnemmalComment)
                        print("retrieveCommentsForMnemmals(): new MnemmalComment is retrieved, mnemmalID is: " + mnemmalId)
            }
                }
            })
            if let cell = self.tableView.cellForRow(at: IndexPath(item: 6, section: 0)) as? SubmissionFooterTableViewCell { cell.mnemmals = self.mnemmals
                cell.tableView.reloadData() }
        })
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dayForToday = story?.days[(user?.storyTrack[(story?.id)!])!]
        tableView.isScrollEnabled = true
        print("viewDidLoad(): user name is: " + self.user!.name!)
        
        // HERO
        closeOutlet.heroModifiers = [.rotate(-1.6)]
        
        
        // tableView nibs
        let nib1 = UINib(nibName: "SubmissionHeaderTableViewCell", bundle: nil)
        tableView.register(nib1, forCellReuseIdentifier: "SubmissionHeaderTableViewCell")
        let nib2 = UINib(nibName: "SubmissionContentTableViewCell", bundle: nil)
        tableView.register(nib2, forCellReuseIdentifier: "SubmissionContentTableViewCell")
        let nib3 = UINib(nibName: "SubmissionFooterTableViewCell", bundle: nil)
        tableView.register(nib3, forCellReuseIdentifier: "SubmissionFooterTableViewCell")
        let nib4 = UINib(nibName: "SubmissionInterimTableViewCell", bundle: nil)
        tableView.register(nib4, forCellReuseIdentifier: "SubmissionInterimTableViewCell")
        let nib5 = UINib(nibName: "SubmissionCloserTableViewCell", bundle: nil)
        tableView.register(nib5, forCellReuseIdentifier: "SubmissionCloserTableViewCell")

        tableView.estimatedRowHeight = tableView.frame.height
        tableView.rowHeight = UITableViewAutomaticDimension
        
    }
}
