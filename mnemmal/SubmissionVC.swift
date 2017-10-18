//
//  SubmissionVC.swift
//  mnemmal
//
//  Created by Danil on 17/09/2017.
//  Copyright © 2017 Danil Chernyshev. All rights reserved.
//

import UIKit
import FirebaseDatabase

class SubmissionVC: UIViewController,
 UITextViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, WordDelegate {
    
    // - MARK: Variables
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var textView: MyTextView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBAction func close(_ sender: Any) {
        textView.resignFirstResponder()
        if self.textView.text.count != 0 {
            confirmDismissal() } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    @IBOutlet weak var closeOutlet: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var submitButton: UIButton!
    @IBAction func sumbitButtonAct(_ sender: Any) {
        submitInstance()
        increaseStoryLevel()
        submitWordsAsUsed()
        configureCloser()
        fetchDelegate.fetchWordsAfterSubmission(storyLevel: (self.story?.storyLevel)!, completedStatus: (self.story?.completed)!, indexPath: self.storyIndexPath!)
    }
    
    
    var wordsPoolBackup = Array<Word>()
    var story: Story?
    var user: User?
    var wordsPool: Array<Word>?
    var storyIndexPath: IndexPath?
    var fetchDelegate: FetchWordsAfterSubmissionDelegate!
    var dayForToday: Day?
    


    // - MARK: CollectionView methods
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wordsPool!.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WordCollectionViewCell", for: indexPath) as! WordCollectionViewCell
        cell.title.text = wordsPool![indexPath.row].title
        cell.shortDef.text = wordsPool![indexPath.row].definition
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: collectionView.frame.width - 20, height: 40)
        return size
    }
    
    var wordToPass: Word?
    var wordIndexPath: IndexPath?
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.wordToPass = self.wordsPool?[indexPath.row]
      performSegue(withIdentifier: "wordOverlook", sender: self)
        self.wordIndexPath = indexPath
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            var currentCellOffset = self.collectionView.contentOffset
            currentCellOffset.x += self.collectionView.frame.width / 2
            if let indexPath = self.collectionView.indexPathForItem(at: currentCellOffset) {
                self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    var timer = Timer()
    func setTimer() {
        if self.wordsPool?.count != 0 {
            self.timer = Timer.scheduledTimer(timeInterval: 7.0, target: self, selector: #selector(SubmissionVC.autoScroll), userInfo: nil, repeats: true)
        }
    }
    
    @objc func stopTimer() {
        self.timer.invalidate()
    }
    
    var x = 1
    @objc func autoScroll() {
        if self.x < self.wordsPool!.count {
            let indexPath = IndexPath(item: x, section: 0)
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            self.x = self.x + 1
        } else {
            self.x = 0
            self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        textView.resignFirstResponder()
        if segue.identifier == "wordOverlook" {
            let nextScene =  segue.destination as! WordOverlookVC
            if let word = self.wordToPass { nextScene.word = word }
            nextScene.delegate = self
            self.textView.resignFirstResponder()
        } else if segue.identifier == "levelup" {
            let nextScene = segue.destination as! LevelUpVC
            if let story = self.story { nextScene.story = story }
        }
    }
    
    func didPressButton(string:String) {
        self.textView.text.append(" " + string)
        self.textView.becomeFirstResponder()
        print(string)
        self.wordsPool!.remove(at: self.wordIndexPath!.row)
        self.collectionView.deleteItems(at: [self.wordIndexPath!])
        self.timer.invalidate()
        if wordsPool!.count == 0 {
        self.collectionView.isHidden = true
        self.submitButton.isHidden = false
        }
        
    }
    
    // - MARK: Textview methods
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
            
        }
        checkSubmitButtonAvailability()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        checkSubmitButtonAvailability()
    }
    
    func checkSubmitButtonAvailability() {
        self.headerLabel.text = String(describing: textView.text.characters.count) + "/300"
        if textView.text.characters.count < 50 {
            self.headerLabel.textColor = UIColor.red
            self.submitButton.backgroundColor = UIColor.lightGray
            self.submitButton.setTitle("50 characters to proceed", for: .normal)
            self.submitButton.isUserInteractionEnabled = false
        } else {
            self.headerLabel.textColor = UIColor(red: 112/255.0, green: 216/255.0, blue: 86/255.0, alpha: 1)
            self.submitButton.backgroundColor = UIColor(red: 112/255.0, green: 216/255.0, blue: 86/255.0, alpha: 1)
            self.submitButton.setTitle("Submit", for: .normal)
            self.submitButton.isUserInteractionEnabled = true
        }
        if textView.text.characters.count == 301 { textView.text.removeLast(1) }
        textView.text = textView.text.replacingOccurrences(of: "   ", with: " ")
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text.count < 301 { return true }
        else { return false }
    }
    
    
    
    // - MARK: Actions on Submit button
    
    func submitInstance() {
        let userId = self.user!.id!
        let storyId = self.story!.id
        let level = 1
        let content = textView.text
        let likes = 0
        let instance = StoryInstance(userId: userId, storyId: storyId, level: level, content: content!, likes: likes)
        let userRef = Database.database().reference().child("users/\(String(describing: userId))/stories/\(instance.storyId)/instances/").childByAutoId()
        userRef.child("userID").setValue(userId)
        userRef.child("StoryID").setValue(storyId)
        userRef.child("level").setValue(level)
        userRef.child("content").setValue(content)
        userRef.child("likes").setValue(likes)
        print("Instance submitted for userID: \(String(describing: userId))")
        let genRef = Database.database().reference().child("stories/\(String(describing: storyId))/instances/").childByAutoId()
        genRef.child("userID").setValue(userId)
        genRef.child("StoryID").setValue(storyId)
        genRef.child("level").setValue(level)
        genRef.child("content").setValue(content)
        genRef.child("likes").setValue(likes)
        let userRefForDate = Database.database().reference().child("users/\(String(describing: userId))/stories/\(instance.storyId)/lastDate")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let date = Date()
        let stringDate = dateFormatter.string(from: date)
        userRefForDate.setValue("\(stringDate)")
        print("Instance submitted for storyID: \(String(describing: storyId))")
    }
    
    func increaseStoryLevel() {
        let daysRef = Database.database().reference().child("users/\(self.user!.id!)/storyRefs/\(self.story!.id)/")
        let storylvl = Int(self.story!.storyLevel)!
        if storylvl < self.story!.daysAmount {
        self.story?.storyLevel = String(describing: Int(self.story!.storyLevel)! + 1)
        let level = storylvl + 1
        let lvl = String(describing: level)
        daysRef.setValue("\(lvl)")
        print("Level for the story \(self.story!.title) has been set to \(lvl)") }
        else {
        print("DaysAmount limit (\(storylvl) days) is reached. Story is completed")
            self.story?.completed = true
            self.submitStoryAsCompleted()
        }
    }
    
    func submitWordsAsUsed() {
        print("submitWordsAsUsed() is invoked")
        let wordsRef = Database.database().reference().child("users/\(self.user!.id!)/stories/\(self.story!.id)/wordUsed/")
        for word in self.wordsPoolBackup {
            wordsRef.child("\(word.id)").setValue("\(word.id)")
            print("Word \(word.title) has been set as used for story \(self.story!.title)")
        }
    }
    
    func submitStoryAsCompleted() {
        print("submitStoryAsCompleted() is invoked")
        let storyRef = Database.database().reference().child("users/\(self.user!.id!)/stories/\(self.story!.id)/completed")
        storyRef.setValue("true")

    }
    
    // MARK: - Cancellation
    
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
    
    // MARK:- Preparing Controller to presentation
    
    func configureDayForToday() {
        dayForToday = story?.days[(user?.storyTrack[(story?.id)!])!]
    }
    
    func configureHeader() {
        if let image = story?.id {
            bgImage.image = story?.image }
        if let color = story?.titleColor {
            headerLabel.textColor = UIColor(hexString: color)
        }
        submitButton.isHidden = true
        textView.text = "War never changes..."
        textView.textColor = UIColor.lightGray
    }

    func configureOpener() {
        if openerAppeared == false {
        let alertController = UIAlertController(title: dayForToday?.name, message: dayForToday?.opener, preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            print("Ok button tapped")
            self.textView.becomeFirstResponder()
        })
        alertController.addAction(okButton)
        self.present(alertController, animated: true, completion: nil)
        openerAppeared = true
        }
    }
    
    var openerAppeared = false
    
    func configureCloser() {
        textView.resignFirstResponder()
        let alertController = UIAlertController(title: nil, message: dayForToday?.closer, preferredStyle: .actionSheet)
        let closerOption0 = UIAlertAction(title: dayForToday?.closerOption0 ?? "FUCK YOU", style: .default, handler: { (action) -> Void in
            self.updateStoryTrack("0")
            self.performSegue(withIdentifier: "levelup", sender: self)
        })
        alertController.addAction(closerOption0)
        if let closerOption = dayForToday?.closerOption1 {
            let closerOption1 = UIAlertAction(title: closerOption, style: .default, handler: { (action) -> Void in
                self.updateStoryTrack("1")
                self.performSegue(withIdentifier: "levelup", sender: self)
            })
            alertController.addAction(closerOption1)
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    func updateStoryTrack(_ option: String) {
        user?.storyTrack[story!.id]?.append(option)
        print("story track for story now is " + (user?.storyTrack[story!.id])!)
        let storyTrackRef = Database.database().reference().child("users/\(self.user!.id!)/stories/\(self.story!.id)/storyTrack")
        let track = user!.storyTrack[story!.id]!
        storyTrackRef.setValue(track)
    }
    
    func registerNibs() {
        let nib1 = UINib(nibName: "WordCollectionViewCell", bundle: nil)
        collectionView.register(nib1, forCellWithReuseIdentifier: "WordCollectionViewCell")
    }
    
    var popupAppeared = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wordsPoolBackup = story!.wordsObj!
        wordsPool = wordsPoolBackup
        registerNibs()
        configureHeader()
        textView.delegate = self
        setTimer()
        print("Amount of words trasferred is " + String(wordsPool!.count))
        print("Story title is " + String(describing: story!.title))
        print("Current level for Story transferred to VC is " + String(describing: story!.storyLevel))
        configureDayForToday()
    }
    override func viewDidAppear(_ animated: Bool) {
        configureOpener()
    }
}
