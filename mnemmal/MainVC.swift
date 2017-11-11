//
//  MainVC.swift
//  Mnemmal
//
//  Created by Danil on 06/09/2017.
//  Copyright © 2017 Danil Chernyshev. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorageUI
import FacebookCore
import FacebookLogin
import SideMenu
import BouncyLayout
import PKHUD

class MainVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FetchWordsAfterSubmissionDelegate, StoryRemovalDelegate, GetStoryDelegate {

    // - MARK: Variables
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionViewUp: UICollectionView!
    @IBOutlet weak var collectionViewDown: UICollectionView!
    @IBOutlet weak var emptyDown: UIButton!
    @IBOutlet weak var emptyUp: UIButton!
    @IBAction func EmptyUpAction(_ sender: Any) {
        sendEmail()
    }
    @IBOutlet weak var emptyUpLabel: UILabel!
    @IBOutlet weak var emptyDownLabel: UILabel!
    @IBOutlet weak var blankView: UIView!
    
    
    var storiesForCollectionView = Array<Story>()
    var storiesAddedSource = Array<Story>()
    var user = User()
    var currentLevelForStory: Int?
    var storyToPass: Story?
    var storyIndexPath: IndexPath?
    let placeholderImage = UIImage(named: "placeholder")

    // - MARK: CollectionView methods
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0
        if collectionView == collectionViewUp {
                count = storiesForCollectionView.count }
        else  { count = storiesAddedSource.count }
        return count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reference = Storage.storage().reference()
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainCollectionViewCell", for: indexPath) as! MainCollectionViewCell
        cell.scrollingImage.layer.cornerRadius = 10.0
        cell.storyLabel.isHidden = false
        cell.removeButton.isHidden = true
        cell.overviewButton.isHidden = true
        
        if collectionView == collectionViewUp {
        cell.dayNumLabel.isHidden = true
        cell.dayNumBG.isHidden = true
        cell.storyLabel.text = storiesForCollectionView[indexPath.row].title
        let textColor = UIColor(hexString: "\(storiesForCollectionView[indexPath.row].titleColor)")
        cell.storyLabel.textColor = textColor
        let imageRef = reference.child("\(storiesForCollectionView[indexPath.row].id).png")
        cell.scrollingImage.sd_setImage(with: imageRef, placeholderImage: placeholderImage)
        // cell.getButton.addTarget(self, action: #selector(MainVC.getStory), for: .touchUpInside)
        cell.getButton.heroID = "getButton"
        cell.premium.heroID = "premium"
        cell.storyLabel.heroID = "cellTitle"
        if storiesForCollectionView[indexPath.row].premium == true {
            cell.premium.isHidden = false } else {
            cell.premium.text = "for free"
            }
    }
        else {
            cell.scrollingImage.alpha = 1.0
            cell.dayNumBG.isHidden = false
            cell.dayNumLabel.isHidden = false
            cell.premium.isHidden = true
            cell.getButton.isHidden = true
            cell.storyLabel.text = storiesAddedSource[indexPath.row].title
            let textColor = UIColor(hexString: "\(storiesAddedSource[indexPath.row].titleColor)")
            cell.storyLabel.textColor = textColor
            print(storiesAddedSource[indexPath.row].storyLevel + "-  " + storiesAddedSource[indexPath.row].title + " - this is storyLevel - ReloadData()")
            
            let imageRef = reference.child("\(storiesAddedSource[indexPath.row].id).png")
            cell.scrollingImage.sd_setImage(with: imageRef, placeholderImage: placeholderImage)
            
            if storiesAddedSource[indexPath.row].completed == false {
            cell.dayNumLabel.text = "DAY " + storiesAddedSource[indexPath.row].storyLevel
            if self.storiesAddedSource[indexPath.row].newDay { // newDay is true
                cell.dayNumLabel.textColor = UIColor(red: 0/255.0, green: 180/255.0, blue: 0/255.0, alpha: 1)
                print("cellForRowAtItem(): this story has a new day: " + self.storiesAddedSource[indexPath.row].title)
            } else { // newDay is false
                cell.dayNumLabel.textColor = UIColor.lightGray
                print("cellForRowAtItem(): this story has no new days: " + self.storiesAddedSource[indexPath.row].title)
            }
            } else { // completed is true
                print("cellForRowAtItem(): this story is DONE: " + self.storiesAddedSource[indexPath.row].title)
                self.storiesAddedSource[indexPath.row].newDay = false
                cell.dayNumLabel.text = "DONE"
                cell.scrollingImage.alpha = 0.5
                cell.dayNumLabel.textColor = UIColor.darkText
            }
    }
        return cell
    }
    
   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: collectionView.frame.width - 20, height: 140)
            return size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MainCollectionViewCell
        cell.scrollingImage.heroID = "cellImage"
        if collectionView == collectionViewUp {
            self.storiesForCollectionView[indexPath.row].image = cell.scrollingImage.image!
            self.storyToPass = self.storiesForCollectionView[indexPath.row]
            self.storyIndexPath = indexPath
            performSegue(withIdentifier: "storyOverlook", sender: self)
            for cell in collectionViewDown.visibleCells  {
                let cellobj = cell as! MainCollectionViewCell
                cellobj.scrollingImage.heroID = ""
                }
            }
        else {
            if deleteModeActivated {
                animateReloading(collectionViewDown)
                deleteModeActivated = false
                print("didSelectItem: " + String(describing: deleteModeActivated))
            } else {
            print(getCurrentDate())
            self.storiesAddedSource[indexPath.row].image = cell.scrollingImage.image!
            self.storyToPass = self.storiesAddedSource[indexPath.row]
            print("didSelectItemAt()")
            self.storyIndexPath = indexPath
            if !self.storiesAddedSource[indexPath.row].completed {
            if self.storiesAddedSource[indexPath.row].newDay {
            performSegue(withIdentifier: "submit", sender: self)
        }
        else { performSegue(withIdentifier: "summary", sender: self) }
            }
            else { performSegue(withIdentifier: "summary", sender: self) }
        }
        }
        }
    
    
    func getCurrentDate() -> String {
        let formatter = DateFormatter()
        let date = Date()
        formatter.dateFormat = "MMM dd, yyyy"
        let stringDate: String = formatter.string(from: date)
        return stringDate
    }
    
    
   func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.collectionViewUp {
            if let indexPath = self.getIndexForVisibleCell(collectionViewUp) {
                self.collectionViewUp.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true) }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if deleteModeActivated {
            animateReloading(collectionViewDown)
            deleteModeActivated = false
        }
    }
    
    
    // - MARK: Data transfer

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "submit" {
            let nextScene =  segue.destination as! SubmissionVC
            if let story = self.storyToPass { nextScene.story = story
                print("Prepare for segue Submit")
            }
            nextScene.fetchDelegate = self
            nextScene.user = self.user
            if let inp = self.storyIndexPath { nextScene.storyIndexPath = inp }
        } else if segue.identifier == "summary" {
            let nextScene =  segue.destination as! SummaryVC
            if let story = self.storyToPass { nextScene.story = story
                print("Prepare for segue Summary")
            }
            nextScene.user = self.user
            if let story = self.storyToPass { nextScene.story = story }
            if let inp = self.storyIndexPath { nextScene.storyIndexPath = inp }
            nextScene.delegate = self
        } else if segue.identifier == "storyOverlook" {
            let nextScene =  segue.destination as! StoryOverlookVC
            nextScene.delegate = self
            if let story = self.storyToPass { nextScene.story = story }
            if let inp = self.storyIndexPath { nextScene.storyIndexPath = inp
                print("Prepare for segue storyOverlook")

            }
        }
    }

    
    // - MARK: Working with Stories
    
    // 1 Retrieve all stories and put them in upper CollectionView
    func retrievingAllStories() {
        HUD.show(.progress)
        print("retrievingAllStories()")
        self.storiesForCollectionView.removeAll()
        self.emptyUpLabel.isHidden = true
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating() // LOADER START
        let storiesRef = Database.database().reference().child("stories")
        storiesRef.keepSynced(true)
        storiesRef.observeSingleEvent(of: .value, with: { snapshot in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshots
                {
                    let isActive = snap.childSnapshot(forPath: "isActive").value as! Bool
                    if isActive {
                    let title = snap.childSnapshot(forPath: "title").value as! String
                        print("retrieveAllStories(): Title of the story is " + title)
                    let daysAmount = snap.childSnapshot(forPath: "daysAmount").value as! Int
                        print("retrieveAllStories(): Amount of days for the story is " + String(daysAmount))
                    let id = snap.childSnapshot(forPath: "id").value as! String
                    let genre = snap.childSnapshot(forPath: "genre").value as! String
                    let words = snap.childSnapshot(forPath: "words").value as! Array<String>
                        print("retrieveAllStories(): Words for that story are " + String(describing: words))
                    let subtext = snap.childSnapshot(forPath: "subtext").value! as! String
                    let epigraph = snap.childSnapshot(forPath: "epigraph").value! as! String
                    let titleColor = snap.childSnapshot(forPath: "titleColor").value as! String
                    let premium = snap.childSnapshot(forPath: "premium").value as! Bool
                    let firstParty = snap.childSnapshot(forPath: "firstParty").value as! String
                    let secondParty = snap.childSnapshot(forPath: "secondParty").value as! String
                        let story = Story(isActive: isActive, title: title, daysAmount: daysAmount, id: id, genre: genre, words: words, subtext: subtext, epigraph: epigraph, premium: premium, titleColor: titleColor, wordsColor: "grey", hidden: false, firstParty: firstParty, secondParty: secondParty)
                self.storiesForCollectionView.append(story)
                    } else { print("retrieveAllStories(): story is inactive") }
                    print("retrieveAllStories(): Amount of stories in upper CollectionView is " + String(self.storiesForCollectionView.count))
                }
            }
            self.loadWordsForStories(withFetchingStories: true)
            self.loadDaysForStories()
            self.loadStoryTracks(initial: true)
            self.checkCompletedStories()
        })
    }
    

    func retrievingUserStories(withFetchingStories: Bool) {
        print("retrievingUserStories()")
        self.user.storiesActive = []
        let usersRef = Database.database().reference().child("users").child("\(self.user.id!)").child("storyRefs")
        usersRef.keepSynced(true)
        usersRef.observeSingleEvent(of: .value, with: { snapshot in
        if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshots {
        let title = snap.key
        self.user.storiesActive!.append(title) }
        } else { print("retrievingUserStories(): no user stories") }
            print("retrievingUserStories(): User stories are counting " + String(describing: self.user.storiesActive!.count))
            if withFetchingStories { self.fetchStories() }
        })
    }
    
    func checkCompletedStories() {
        print("checkCompletedStories(): invoked")
        for story in self.storiesForCollectionView {
            let storyRef = Database.database().reference().child("users/\(self.user.id!)/stories/\(story.id)/completed")
            storyRef.keepSynced(true)
            storyRef.observeSingleEvent(of: .value, with: { snapshot in
                print("checkCompletedStories(): Snapshot.value is " + String(describing: snapshot.value))
                if snapshot.exists() {
                    let completed = snapshot.value as! String
                    let completedBool = Bool(completed)
                    story.completed = completedBool!
                    print("checkCompletedStories(): Story \(story.title) completed " + String(describing: completed))
                } else {
                    story.completed = false
                    print("checkCompletedStories(): Story \(story.title) completed - FALSE.")
                }
                self.moveAvailableStoriesAtTop()
            })
        }
    }
    
    
    func loadDaysForStories() {
        print("loadDaysForStories(): invoked")
        for story in self.storiesForCollectionView {
       let daysRef = Database.database().reference().child("stories/\(story.id)/days/")
        daysRef.observeSingleEvent(of: .value, with: { snapshot in
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                    for snap in snapshots
                    {
                        let coding = snap.childSnapshot(forPath: "coding").value as! String
                        let name = snap.childSnapshot(forPath: "name").value as! String
                        let historical = snap.childSnapshot(forPath: "historical").value as! Bool
                        let opener = snap.childSnapshot(forPath: "opener").value as! String
                        let closer = snap.childSnapshot(forPath: "closer").value as! String
                        let closerOption0 = snap.childSnapshot(forPath: "closerOption0").value as! String
                        let closerOption1 = snap.childSnapshot(forPath: "closerOption1").value as? String
                        let day = Day(coding: coding, name: name, opener: opener, historical: historical, closer: closer, closerOption0: closerOption0, closerOption1: closerOption1)
                        story.days[coding] = day
                        print("loadDaysForStories(): New day has been added for story. Amount of days is " + String(describing: story.days.count))
        }
    }
            })
    }
    }

    
    func loadStoryTracks(initial: Bool) {
        print("loadStoryTracks(): invoked")
        if initial {
    for story in self.storiesForCollectionView {
        let storyTrackRef = Database.database().reference().child("users/\(self.user.id!)/stories/\(story.id)/storyTrack")
        storyTrackRef.keepSynced(true)
    storyTrackRef.observeSingleEvent(of: .value, with: { snapshot in
    if let storyTrack = snapshot.value as? String {
    self.user.storyTrack[story.id] = storyTrack
    } else {
        self.user.storyTrack[story.id] = ""
        }
        print("loadStoryTracks(): storyTrack is " + self.user.storyTrack[story.id]! + " for story with title: " + story.title)
    })
        }
        } else {
    for story in self.storiesAddedSource {
    let storyTrackRef = Database.database().reference().child("users/\(self.user.id!)/stories/\(story.id)/storyTrack")
    storyTrackRef.observeSingleEvent(of: .value, with: { snapshot in
            if let storyTrack = snapshot.value as? String {
                        self.user.storyTrack[story.id] = storyTrack
                    }
            print("loadStoryTracks(): storyTrack is " + self.user.storyTrack[story.id]! + " for story with title: " + story.title)
                })
            }
        }
    }
    
    
    // - MARK: Working with WORDS for Stories
    
    var wordsPool = Array<Word>()
    
    func loadWordsForStories(withFetchingStories: Bool) {
        print("loadWords() is invoked")
        let wordsRef = Database.database().reference().child("words")
        wordsRef.keepSynced(true)
        if self.storiesForCollectionView.count != 0 {
        let x = Array(0...(self.storiesForCollectionView.count - 1))
        for item in x {
            for word in self.storiesForCollectionView[item].words {
        wordsRef.observeSingleEvent(of: .value, with: { snapshot in
                    let isActive = snapshot.childSnapshot(forPath: "/\(word)/isActive").value as! Bool
                        if isActive {
                    let definition = snapshot.childSnapshot(forPath: "/\(word)/definition").value as! String
                    let example0 = snapshot.childSnapshot(forPath: "/\(word)/example0").value as! String
                    let example1 = snapshot.childSnapshot(forPath: "/\(word)/example1").value as! String
                    let id = snapshot.childSnapshot(forPath: "/\(word)/id").value as! String
                    let title = snapshot.childSnapshot(forPath: "/\(word)/title").value as! String
                            print("loadWords(): Title of the word is " + title)
                    let type = snapshot.childSnapshot(forPath: "/\(word)/type").value as! String
                    let wordInit = Word(id: id, title: title, definition: definition, type: type, example0: example0, example1: example1)
                    if let _ = self.wordsPool.first(where: {$0.title == title}) {
                        print("loadWords(): word is already in the array")
                    } else {
                        self.wordsPool.append(wordInit)
                        print("loadWords(): self.wordsPool.count is " + String(self.wordsPool.count))
                    }
                }
            })
            }
        }
             }
        self.fetchWordsForStories(withFetchingStories: withFetchingStories)
        }
    

    
    
    func fetchWordsForStories(withFetchingStories: Bool) {
        print("fetchWordsForStories() is invoked")
        var wordsNumbersForStory = Array<String>()
        var usedWords = Array<String>()
        var wordsPoolForStory = Array<Word>()
        if self.storiesForCollectionView.count != 0 {
        let x = Array(0...(self.storiesForCollectionView.count - 1))
        for item in x {
            print("fetchWordsForStories(): attempt No. \(item)")
        wordsNumbersForStory = self.storiesForCollectionView[item].words
        let storyId = self.storiesForCollectionView[item].id
            print("fetchWordsForStories(): wordsNumbersForStory.count for story \(self.storiesForCollectionView[item].title) is " + String(wordsNumbersForStory.count))
        let wordsRef = Database.database().reference().child("users/\(self.user.id!)/stories/\(storyId)/wordUsed/")
        wordsRef.keepSynced(true)
        wordsRef.observeSingleEvent(of: .value, with: { snapshot in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshots
                {
                let usedWord = snap.value as! String
                    print("fetchWordsForStories(): used word No. for story \(self.storiesForCollectionView[item].title) is" + usedWord)
                    usedWords.append(usedWord) }
                wordsNumbersForStory = wordsNumbersForStory.filter { !usedWords.contains($0) }
            }
            wordsPoolForStory = self.wordsPool.filter { wordsNumbersForStory.contains($0.id) }
            print("fetchWordsForStories(): self.wordsPoolForStory.count for story \(self.storiesForCollectionView[item].title) is " + String(wordsPoolForStory.count))
            let pickedWords = wordsPoolForStory.shuffled.choose(self.user.wordsPerLevel!)
            print("fetchWordsForStories(): pickedWords.count for story \(self.storiesForCollectionView[item].title) is " + String(pickedWords.count))
            self.storiesForCollectionView[item].wordsObj = pickedWords
        })
        }
        retrievingUserStories(withFetchingStories: withFetchingStories)
        self.activityIndicator.stopAnimating()
        } else { print("fetchWordsForStories(): UpperSource is empty")}
    }

    func getLastDatesForStories() {
        print("getLastDatesForStories(): is invoked")
        for story in self.storiesAddedSource {
    let storyId = story.id
    let lastDateRef = Database.database().reference().child("users/\(self.user.id!)/stories/\(storyId)/lastDate")
    lastDateRef.observeSingleEvent(of: .value, with: { snapshot in
    if let lastDate = snapshot.value as? String {
    story.lastDate = lastDate
    if lastDate != self.getCurrentDate() {
            story.newDay = true
        } else { story.newDay = false }
        print("getLastDatesForStories(): last Date for Story  is  " + lastDate) }
    else { print("getLastDatesForStories(): No last dates for story \(story.title)")}
        self.moveAvailableStoriesAtTop()
    })
        }
    }
    
    // Moving stories from up to down
    
    func fetchStories() {
        print("fetchStories() is invoked")
        self.storiesAddedSource = self.storiesForCollectionView.filter { self.user.storiesActive!.contains($0.id) }
        print("fetchStories(): Stories in storiesAddedS to fetch counting: " + String(self.storiesAddedSource.count))
        self.storiesForCollectionView = self.storiesForCollectionView.filter { !self.user.storiesActive!.contains($0.id) }
        print("fetchStories():  self.storiesAddedSource.count is: " + String(self.storiesAddedSource.count))
        print("fetchStories(): self.storiesForCollectionView.count is: "
            + String(self.storiesForCollectionView.count))
        self.collectionViewUp.reloadData()
        getCurrentLevelsForStoriesAdded()
        checkVisibilityOfUIElements()
        HUD.flash(.success)
    }
    
    func getCurrentLevelsForStoriesAdded() {
        print("getCurrentLevelsForStoriesAdded(): is invoked")
        let levelsRef = Database.database().reference().child("users/\(self.user.id!)/storyRefs/")
        levelsRef.keepSynced(true)
        levelsRef.observeSingleEvent(of: .value, with: { snapshot in
            for story in self.storiesAddedSource {
                let level = snapshot.childSnapshot(forPath: "\(story.id)").value as! String
                story.storyLevel = level
                print("getCurrentLevelsForStoriesAdded(): Level for story " + story.title + " is " + String(describing: level)) }
            self.getLastDatesForStories()
            self.activityIndicator.isHidden = true
        })
    }
    
    
    
    // - MARK: Adding and removal story to User
    
    @objc func getStory() {
        print("getStory() is invoked")
        if let visibility = self.getIndexForVisibleCell(collectionViewUp) {
            self.storiesAddedSource.insert(self.storiesForCollectionView[visibility.row], at: 0)
            let storyRefToUpdateUserAccount = self.storiesForCollectionView[visibility.row].id
            self.user.storiesActive!.append(storyRefToUpdateUserAccount)
            self.collectionViewDown.insertItems(at: [IndexPath(item: 0, section: 0)])
            self.collectionViewDown.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
            self.storiesForCollectionView.remove(at: visibility.item)
            if self.storiesForCollectionView.count == 0 { self.stopTimer() }
            self.collectionViewUp.deleteItems(at: [visibility])
            setCurrentDayForNewStory(storyRefToUpdateUserAccount)
            self.storiesAddedSource[0].newDay = true
            checkVisibilityOfUIElements()
            animateReloading(collectionViewDown)
        }
    }
    
    func setCurrentDayForNewStory(_ source: String) {
        let daysRef = Database.database().reference().child("users/\(self.user.id!)/storyRefs/\(source)/")
        daysRef.setValue("1")
        print("setCurrentDayForNewStory(): Day for the story has been set to 1")
    }
    
    @objc func removeStory(indexPath: IndexPath, storyId: String) {
        print("removeStory(): is invoked")
        self.storiesAddedSource[indexPath.row].lastDate = nil
        self.storiesAddedSource[indexPath.row].storyLevel = "1"
        self.storiesAddedSource[indexPath.row].newDay = true
        self.storiesAddedSource[indexPath.row].completed = false
        
        self.storiesForCollectionView.insert(self.storiesAddedSource[indexPath.row], at: 0)
        self.storiesAddedSource.remove(at: indexPath.row)
        self.animateReloading(collectionViewDown)
        self.animateReloading(collectionViewUp)
        let daysRef = Database.database().reference().child("users/\(self.user.id!)/storyRefs/\(storyId)")
        daysRef.removeValue()
        let wordsRef = Database.database().reference().child("users/\(self.user.id!)/stories/\(storyId)")
        wordsRef.removeValue()
        print("removeStory(): Info removed")
        checkVisibilityOfUIElements()
        removeUserMnemmalsFromCommonPool(indexPath: indexPath)
    }
    
    func removeUserMnemmalsFromCommonPool(indexPath: IndexPath) {
        print("removeUserMnemmalsFromCommonPool(): is invoked")
        let storyId = self.storiesForCollectionView[0].id
        print("removeUserMnemmalsFromCommonPool(): id is " + String(describing: storyId) + ". storyTrack is " + String(describing: self.user.storyTrack[storyId]!))
        
        repeat {
        let mnemmalRef = Database.database().reference().child("stories/\(storyId)/instances/\(self.user.storyTrack[storyId]!)")
        mnemmalRef.observeSingleEvent(of: .value, with: { snapshot in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshots
                {
                    if let id = snap.childSnapshot(forPath: "userID").value as? String {
                        if self.user.id == id {
                            print("removeUserMnemmalsFromCommonPool(): removing mnemmal " + snap.key)
                            mnemmalRef.child(snap.key).removeValue()
                }
            }
        }
            }
        })
        let mnemmalId = self.user.id! + ":" + storyId + ":" + self.user.storyTrack[storyId]!
            print("mnemmalId: " + mnemmalId)
        let commentRef = Database.database().reference().child("comments/\(storyId)/\(self.user.storyTrack[storyId]!)/\(mnemmalId)")
        commentRef.removeValue()
        let likesRef = Database.database().reference().child("likes/\(storyId)/\(self.user.storyTrack[storyId]!)/\(mnemmalId)")
        likesRef.removeValue()
        self.user.storyTrack[storyId]?.removeLast(1)
            print("removeUserMnemmalsFromCommonPool(): iterating deletion for days. StoryTrack cut down with 1 character and now = " + String(describing: self.user.storyTrack[storyId]))
        } while self.user.storyTrack[storyId]!.characters.count != 0
        
        self.user.storyTrack[storyId] = ""
    }
    
    
    func fetchWordsAfterSubmission(storyLevel: String, completedStatus: Bool, indexPath: IndexPath) {
        print("fetchWordsAfterSubmission(): is invoked")
        self.storiesAddedSource[indexPath.row].storyLevel = storyLevel
        self.storiesAddedSource[indexPath.row].completed = completedStatus
        self.storiesAddedSource[indexPath.row].newDay = false
        loadWordsForStories(withFetchingStories: false)
        self.storiesAddedSource[indexPath.row].lastDate = getCurrentDate()
        self.getCurrentLevelsForStoriesAdded()
        self.collectionViewUp.reloadData()
        self.collectionViewDown.reloadData()
    }
    
    @objc func updateUserObject() {
        print("MainVC: updateUserObject is invoked")
        if let user = Auth.auth().currentUser {
            print("MainVC: User ID is \(user.uid)")
            print("MainVC: User is logged in Firebase.")
            self.user.id = user.uid
            if let fbId = UserProfile.current?.userId { self.user.fbId = fbId } else {self.user.fbId = "none" }
            if let userName = UserProfile.current?.fullName { self.user.name = userName } else {self.user.name = "Anonymous" }
            self.retrievingAllStories()
        }
    }
    
    
    
    
    
    // MARK: - UI
    
    func setupSideMenu() {
        if let menuLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? UISideMenuNavigationController {
            menuLeftNavigationController.leftSide = true
            SideMenuManager.menuLeftNavigationController = menuLeftNavigationController
            SideMenuManager.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
            SideMenuManager.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        }
    }
    
    func sendEmail() {
        let subject = "About Mnemmal app"
        let body = ""
        let coded = "mailto:danil@chernyshev.pro?subject=\(subject)&body=\(body)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        if let emailURL:NSURL = NSURL(string: coded!)
        {
            if UIApplication.shared.canOpenURL(emailURL as URL)
            {
                UIApplication.shared.openURL(emailURL as URL)
            }
        }
    }
    
    func moveAvailableStoriesAtTop() {
        print("moveAvailableStoriesAtTop(): invoked")
        self.storiesAddedSource.sort { $0.storyLevel < $1.storyLevel }
        self.storiesAddedSource.sort { !$0.completed && $1.completed }
        self.storiesAddedSource.sort { $0.newDay && !$1.newDay }
        self.collectionViewDown.reloadData()
    }
    
    func getIndexForVisibleCell(_ collectionView: UICollectionView) -> IndexPath? {
        print("getIndexForVisibleCell(): invoked")
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let visibility = collectionView.indexPathForItem(at: visiblePoint)
        return visibility
    }
    
    func checkVisibilityOfUIElements() {
        print("checkVisibilityOfUIElements(): invoked")
        if self.storiesForCollectionView.count == 0 {
            self.collectionViewUp.isHidden = true
            self.emptyUp.isHidden = false
            self.emptyUpLabel.isHidden = false
        } else {
            self.emptyUp.isHidden = true
            self.emptyUpLabel.isHidden = true
            self.collectionViewUp.isHidden = false
        }
        if self.storiesAddedSource.count == 0 {
            self.collectionViewDown.isHidden = true
            self.emptyDown.isHidden = false
            self.emptyDownLabel.isHidden = false
        } else {
            self.emptyDown.isHidden = true
            self.emptyDownLabel.isHidden = true
            self.collectionViewDown.isHidden = false
        }
    }
    
    func animateReloading(_ collectionView: UICollectionView) {
        print("animateReloading(): invoked")
        let range = Range(uncheckedBounds: (0, collectionView.numberOfSections))
        let indexSet = IndexSet(integersIn: range)
        collectionView.reloadSections(indexSet)
    }
    
    @objc func handleLongPress(gesture : UILongPressGestureRecognizer!) {
        print("handleLongPress(): invoked")
        if gesture.state == .began {
        deleteModeActivated = true
        animateReloading(collectionViewDown)
        let p = gesture.location(in: self.collectionViewDown)
        if let indexPath = self.collectionViewDown.indexPathForItem(at: p) {
            // get the cell at indexPath (the one you long pressed)
            if let cell = self.collectionViewDown.cellForItem(at: indexPath) as? MainCollectionViewCell {
            self.storyToPass = self.storiesAddedSource[indexPath.row]
            self.storyIndexPath = indexPath
            cell.scrollingImage.alpha = 0.7
            cell.dayNumBG.isHidden = true
            cell.dayNumLabel.isHidden = true
            cell.removeButton.addTarget(self, action: #selector(remove), for: .touchUpInside)
            cell.removeButton.isHidden = false
            cell.overviewButton.addTarget(self, action: Selector("summarySegue"), for: .touchUpInside)
            self.storiesAddedSource[indexPath.row].image = cell.scrollingImage.image!
            cell.overviewButton.isHidden = false
            indexPathRemoval = indexPath
            storyIdRemoval = self.storiesAddedSource[indexPath.row].id
        } else {
            print("couldn't find index path")
        }
        }
        }
    }
    
    func summarySegue() {
        performSegue(withIdentifier: "summary", sender: self)
    }
    
    func remove() {
        print("remove(): invoked")
        deleteModeActivated = false
        removeStory(indexPath: indexPathRemoval!, storyId: storyIdRemoval!)
    }
    
    var indexPathRemoval: IndexPath?
    var storyIdRemoval: String?
    var deleteModeActivated = false
    

    // - MARK: Timer and scroll of upper CollectionView
    
    var timer = Timer()
    func setTimer() {
        print("setTimer(): invoked")
        if self.storiesForCollectionView.count != 0 {
            self.timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(MainVC.autoScroll), userInfo: nil, repeats: true)
        }
    }
    
    @objc func stopTimer() {
        print("stopTimer(): invoked")
        self.timer.invalidate()
    }
    
    var x = 1
    @objc func autoScroll() {
        if self.x < self.storiesForCollectionView.count {
            let indexPath = IndexPath(item: x, section: 0)
            self.collectionViewUp.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            self.x = self.x + 1
        } else {
            self.x = 0
            self.collectionViewUp.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
    
    func scrollToCenter() {
        print("scrollToCenter(): invoked")
        if storiesForCollectionView.count != 0 {
        collectionViewUp.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: true)
        x = 0
        }
    }
    
    // - MARK: VC LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        Database.database().isPersistenceEnabled = true

        let nib = UINib(nibName: "MainCollectionViewCell", bundle: nil)
        collectionViewUp.register(nib, forCellWithReuseIdentifier: "MainCollectionViewCell")
        collectionViewDown.register(nib, forCellWithReuseIdentifier: "MainCollectionViewCell")
        
        // Authorization
        if let accessToken = AccessToken.current?.authenticationToken {
                    print("MainVC: Facebook User logged in!")
                    if let user = Auth.auth().currentUser {
                        print("MainVC: User ID is \(user.uid)")
                        self.user.id = user.uid
                        self.user.fbId = UserProfile.current!.userId
                        self.user.name = UserProfile.current!.fullName
                        print("userName is: " + self.user.name!)
                        self.user.wordsPerLevel = 3
                        self.retrievingAllStories()
                    }
        } else {
            Auth.auth().signInAnonymously() { (user, error) in
                print("MainVC: Anonym User logged in!")
                if let user = Auth.auth().currentUser {
                    print("MainVC: User ID is \(user.uid)")
                    self.user.id = user.uid
                    self.user.fbId = "none"
                    self.user.name = "Anonymous"
                    self.user.wordsPerLevel = 3
                    self.retrievingAllStories()
                }
            }
        }
        
        // Retrieving
        self.emptyUp.layer.cornerRadius = 10.0
        self.emptyDown.layer.cornerRadius = 10.0
        
        // SideMenu
        setupSideMenu()
        
        // Activity Indicator
        self.activityIndicator.isHidden = true
        
        // Notifications
        NotificationCenter.default.addObserver(self,
                                            selector: #selector(updateUserObject),
                                            name: NSNotification.Name(rawValue: "UserObjectUpdated"),
                                            object: nil)

        // GestureRecognizer
        let longGest = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        collectionViewDown.addGestureRecognizer(longGest)
        collectionViewDown.backgroundView?.isUserInteractionEnabled = false
        }
    

    
    override func viewDidAppear(_ animated: Bool) {
        scrollToCenter()
        loadStoryTracks(initial: false)
        setTimer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        moveAvailableStoriesAtTop()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        stopTimer()
    }
}
