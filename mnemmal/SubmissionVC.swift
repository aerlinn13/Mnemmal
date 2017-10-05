//
//  SubmissionVC.swift
//  mnemmal
//
//  Created by Danil on 17/09/2017.
//  Copyright © 2017 Danil Chernyshev. All rights reserved.
//

import UIKit
import FirebaseDatabase
import CDAlertView

class SubmissionVC: UIViewController,
 UITextViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, WordDelegate {
    
    // - MARK: Variables
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBAction func close(_ sender: Any) {
        textView.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var closeOutlet: UIButton!
    @IBOutlet weak var dayNumber: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var submitButton: UIButton!
    @IBAction func sumbitButtonAct(_ sender: Any) {
        submitInstance()
        increaseStoryLevel()
        submitWordsAsUsed()
        performSegue(withIdentifier: "levelup", sender: self)
        fetchDelegate.fetchWordsAfterSubmission()
    }
    
    
    var wordsPoolBackup = Array<Word>()
    var story: Story?
    var user: User?
    var wordsPool: Array<Word>?
    var storyIndexPath: IndexPath?
    var fetchDelegate: FetchWordsAfterSubmissionDelegate!


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
            self.timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(SubmissionVC.autoScroll), userInfo: nil, repeats: true)
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
        } else if segue.identifier == "levelup" {
            let nextScene = segue.destination as! LevelUpVC
            if let story = self.story { nextScene.story = story }
        }
    }
    
    func didPressButton(string:String) {
        self.textView.text.append(" " + string)
        self.wordsPool!.remove(at: self.wordIndexPath!.row)
        self.collectionView.deleteItems(at: [self.wordIndexPath!])
        if wordsPool!.count == 0 {
        self.collectionView.isHidden = true
        self.submitButton.isHidden = false
        self.timer.invalidate()
        }
        self.textView.becomeFirstResponder()
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
        let level = storylvl + 1
        let lvl = String(describing: level)
        daysRef.setValue("\(lvl)")
            print("Level for the story \(self.story!.title) has been set to \(lvl)") }
        else {
            print("DaysAmount limit (\(storylvl) days) is reached. Story is to be deleted from user account.")
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
    
    func configureHeader() {
        if let image = story?.image {
            bgImage.image = UIImage(named: image) }
        if let title = story?.title {
            headerLabel.text = title }
        if let dayNum = story?.storyLevel {
            dayNumber.text = "Day " + String(describing: dayNum)
        }
        if let color = story?.titleColor {
            headerLabel.textColor = UIColor(hexString: color)
        closeOutlet.setTitleColor(UIColor(hexString: color), for: .normal)
        dayNumber.textColor = UIColor(hexString: color)
        }
        submitButton.isHidden = true
    }

    func configurePopup() {
        if popupAppeared == false {
        let alert = CDAlertView(title: "I am good", message: "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like).", type: .custom(image: UIImage(named: "1")!))
        alert.alertBackgroundColor = UIColor(red: 248/255.0, green: 236/255.0, blue: 194/255.0, alpha: 1)
        alert.circleFillColor = UIColor(red: 248/255.0, green: 236/255.0, blue: 194/255.0, alpha: 1)
            alert.show()
            popupAppeared = true
        }
    }
    
    func registerNibs() {
        let nib0 = UINib(nibName: "SubtextCollectionViewCell", bundle: nil)
        let nib1 = UINib(nibName: "WordCollectionViewCell", bundle: nil)
        collectionView.register(nib0, forCellWithReuseIdentifier: "SubtextCollectionViewCell")
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
}
    override func viewDidAppear(_ animated: Bool) {
        configurePopup()
    }
}
