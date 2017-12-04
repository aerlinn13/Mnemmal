//
//  MainVC.swift
//  Mnemmal
//
//  Created by Danil on 06/09/2017.
//  Copyright © 2017 Danil Chernyshev. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorageUI
import FacebookCore
import FacebookLogin
import SideMenu
import BouncyLayout
import PKHUD
import AMPopTip
import StoreKit

class MainVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FetchWordsAfterSubmissionDelegate, StoryRemovalDelegate, GetStoryDelegate {
    

    // - MARK: Variables
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
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
    
    
    var storiesUp = Array<Story>()
    var storiesDown = Array<Story>()
    var user = User()
    var currentLevelForStory: Int?
    var storyToPass: Story?
    var storyIndexPath: IndexPath?
    let placeholderImage = UIImage(named: "placeholder")
    var wordsPool = Array<Word>()
    var indexPathRemoval: IndexPath?
    var storyIdRemoval: String?
    var deleteModeActivated = false
    var invokedFromDown: Bool?

    // - MARK: CollectionView methods
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0
        if collectionView == collectionViewUp {
                count = storiesUp.count }
        else  { count = storiesDown.count }
        return count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reference = Storage.storage().reference()
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainCollectionViewCell", for: indexPath) as! MainCollectionViewCell
        cell.scrollingImage.layer.cornerRadius = 10.0
        cell.storyLabel.isHidden = false
        cell.scrollingImage.alpha = 1.0
        cell.underliningView.isHidden = true
        
        if collectionView == collectionViewUp {
        cell.removeButton.isHidden = true
        cell.statusLabel.isHidden = true
        cell.storyLabel.text = storiesUp[indexPath.row].title
        cell.subStoryLabel.text = storiesUp[indexPath.row].subtitle
        let imageRef = reference.child("\(storiesUp[indexPath.row].id).png")
        cell.scrollingImage.sd_setImage(with: imageRef, placeholderImage: placeholderImage)
        cell.premium.image = nil

    }
        else { // CollectionViewDown
            cell.statusLabel.font = UIFont(name: "Palatino", size: 25.0)
            let string = self.toRoman(number: Int(self.storiesDown[indexPath.row].storyLevel)!)
            cell.statusLabel.text = string
            let width = string.size(OfFont: UIFont(name: "Palatino", size: 25.0)!).width
            cell.widthConstraint.constant = width
            cell.updateConstraints()
            cell.removeButton.isHidden = true
            cell.underliningView.isHidden = false
            cell.premium.isHidden = true
            cell.storyLabel.text = storiesDown[indexPath.row].title
            cell.subStoryLabel.text = storiesDown[indexPath.row].subtitle
            print("cellForRowAtItem(): intrinsicSize from statusLabel is: " + String(describing: cell.statusLabel.intrinsicContentSize.width))
            
            let imageRef = reference.child("\(storiesDown[indexPath.row].id).png")
            cell.scrollingImage.sd_setImage(with: imageRef, placeholderImage: placeholderImage)
            
            cell.underliningView.backgroundColor = nil
            print("cellForRowAtItem(): newDay is: " + String(self.storiesDown[indexPath.row].title) + String(self.storiesDown[indexPath.row].newDay))
            if storiesDown[indexPath.row].completed == false {
            if self.storiesDown[indexPath.row].newDay { // newDay is true
                cell.underliningView.backgroundColor = UIColor(red: 112/255.0, green: 216/255.0, blue: 86/255.0, alpha: 1)
                print("cellForRowAtItem(): this story has a new day: " + self.storiesDown[indexPath.row].title)
            } else { // newDay is false
                cell.underliningView.backgroundColor = UIColor.lightGray
                print("cellForRowAtItem(): this story has no new days: " + self.storiesDown[indexPath.row].title)
            }
            } else { // completed is true
                print("cellForRowAtItem(): this story is DONE: " + self.storiesDown[indexPath.row].title)
                self.storiesDown[indexPath.row].newDay = false
                cell.underliningView.backgroundColor = UIColor.black
            }
            
    }
        cell.layoutIfNeeded()
        return cell
    }
    
   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: collectionView.frame.width - 20, height: 140)
            return size
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("didSelectItem: invoked")
        let cell = collectionView.cellForItem(at: indexPath) as! MainCollectionViewCell
        collectionView.visibleCells.forEach({ cell in
            if let cell = cell as? MainCollectionViewCell {
            cell.heroID = nil
            cell.scrollingImage.heroID = nil
            cell.storyLabel.heroID = nil
            cell.statusLabel.heroID = nil
            cell.subStoryLabel.heroID = nil
            }
        })
        
        if collectionView == collectionViewUp {
            cell.storyLabel.heroID = "label"
            cell.statusLabel.heroID = "statusLabel"
            cell.subStoryLabel.heroModifiers = [.fade]
            self.storiesUp[indexPath.row].image = cell.scrollingImage.image!
            if self.storiesUp[indexPath.row].isNews {
                self.user.storyTrack[self.storiesUp[indexPath.row].id] = "0"
                self.setInitialStoryTrack(story: self.storiesUp[indexPath.row], storyTrack: "0")
                self.storyToPass = self.storiesUp[indexPath.row]
                self.storyIndexPath = indexPath
                self.invokedFromDown = false
                performSegue(withIdentifier: "submit", sender: self)
            } else {
                self.storyToPass = self.storiesUp[indexPath.row]
                self.storyIndexPath = indexPath
                performSegue(withIdentifier: "storyOverlook", sender: self)
            }
            }
        else { // Down
            if deleteModeActivated {
                animateReloading(collectionViewDown)
                deleteModeActivated = false
                print("didSelectItem: " + String(describing: deleteModeActivated))
            } else {
            self.storiesDown[indexPath.row].image = cell.scrollingImage.image!
            self.storyToPass = self.storiesDown[indexPath.row]
            self.storyIndexPath = indexPath
            if !self.storiesDown[indexPath.row].completed {
            if self.storiesDown[indexPath.row].newDay {
                if let cell = collectionView.cellForItem(at: indexPath)! as? MainCollectionViewCell {
                cell.scrollingImage.heroID = "cellImage"
                cell.storyLabel.heroID = "label"
                cell.statusLabel.heroID = "statusLabel"
                }
            self.invokedFromDown = true
            performSegue(withIdentifier: "submit", sender: self)
        }
        else {  self.collectionViewDown.cellForItem(at: indexPath)!.heroID = "cell"
                performSegue(withIdentifier: "summary", sender: self) }
            }
            else { self.collectionViewDown.cellForItem(at: indexPath)!.heroID = "cell"
                    performSegue(withIdentifier: "summary", sender: self) }
        }
        }
        }
    
    @objc func refreshOptions() {
        self.globalLoading(sideMenu: false)
        self.collectionViewDown.refreshControl!.endRefreshing()
    }

    @objc func globalLoading(sideMenu: Bool) {
        if sideMenu { HUD.show(.progress) }
        print("globalLoading(): loading stories.")
        self.loadUserStories()
        self.loadAllStoriesUp { (stories) in
            if stories!.count != 0 {
                self.loadStoryTracksUp()
                self.loadDaysForStoriesUp()
                self.loadCompletedStoriesUp()
                print("globalLoading(): stories are received from closure")
                self.loadWordsForStoriesUp(initial: true) { words in
                    if !(words?.isEmpty)! {
                        print("globalLoading(): words are received from closure")
                        self.filterWordsForStoriesUp(initial: true)
                        self.loadSummariesForStoriesUp(initial: true) { storiesUp in
                            print("globalLoading(): attempt to check summaries.")
                            var count = storiesUp!.count
                            self.storiesUp.forEach({ story in
                                if story.checked {
                                    count -= 1
                                    if count == 0 {
                                        print("globalLoading(): summaries are received from closure")
                                        self.filterStories() } } })
                                    }
                                }
                                }
                            } else { print("globalLoading(): no stories") }
                        }
                    }
    
    
    typealias storiesClosure = (Array<Story>?) -> Void
/// 1
    func loadAllStoriesUp(completion: @escaping storiesClosure) {
        print("retrievingAllStories()")
        self.storiesUp.removeAll()
        self.storiesDown.removeAll()
        let storiesRef = Database.database().reference().child("stories")
        storiesRef.keepSynced(true)
        storiesRef.observeSingleEvent(of: .value, with: { snapshot in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshots
                {
                    let isActive = snap.childSnapshot(forPath: "isActive").value as! Bool
                    if isActive {
                    let title = snap.childSnapshot(forPath: "title").value as! String
                    let subtitle = snap.childSnapshot(forPath: "subtitle").value as! String

                        print("retrieveAllStories(): Title of the story is " + title)
                    let daysAmount = snap.childSnapshot(forPath: "daysAmount").value as! Int
                        print("retrieveAllStories(): Amount of days for the story is " + String(daysAmount))
                    let id = snap.childSnapshot(forPath: "id").value as! String
                        print("retrieveAllStories(): ID for the story is " + String(id))
                    let isNews = snap.childSnapshot(forPath: "isNews").value as! Bool
                        print("retrieveAllStories(): isNews for the story is " + String(isNews))
                    let words = snap.childSnapshot(forPath: "words").value as! [String]
                        print("retrieveAllStories(): Words for that story are " + String(describing: words.count))
                    let subtext = snap.childSnapshot(forPath: "subtext").value! as! String
                        print("retrieveAllStories(): subtext for that story are " + String(describing: subtext))
                    let epigraph = snap.childSnapshot(forPath: "epigraph").value! as! String
                    let firstParty = snap.childSnapshot(forPath: "firstParty").value as! String
                    let onStand = snap.childSnapshot(forPath: "onStand").value as! Bool
                        let story = Story(isActive: isActive, title: title, subtitle: subtitle, daysAmount: daysAmount, id: id, words: words, subtext: subtext, epigraph: epigraph, firstParty: firstParty, isNews: isNews, onStand: onStand)
                    self.storiesUp.append(story)
                    } else { print("retrieveAllStories(): story is inactive") }
                    print("retrieveAllStories(): Amount of stories in upper CollectionView is " + String(self.storiesUp.count))
                }
            }
            self.storiesUp.reverse()
            completion(self.storiesUp)
        })
        }
    
    // 2.1
    func loadDaysForStoriesUp() {
        print("loadDaysForStoriesUp(): invoked")
        
        for story in self.storiesUp {
            let daysRef = Database.database().reference().child("stories/\(story.id)/days/")
            daysRef.observeSingleEvent(of: .value, with: { snapshot in
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                    for snap in snapshots
                    {
                        let coding = snap.childSnapshot(forPath: "coding").value as! String
                        let name = snap.childSnapshot(forPath: "name").value as! String
                        let opener = snap.childSnapshot(forPath: "opener").value as! String
                        let openerButton = snap.childSnapshot(forPath: "openerButton").value as? String
                        let day = Day(coding: coding, name: name, opener: opener, openerButton: openerButton)
                        story.days[coding] = day
                        print("loadDaysForStoriesUp(): New day has been added for story. Amount of days is " + String(describing: story.days.count))
                    }
                }
             })
        }
        }
    
    // 2.2
    func loadStoryTracksUp() {
        print("loadStoryTracksUp(): invoked")
        let storyTrackRef = Database.database().reference().child("users/\(self.user.id!)/stories/")
        storyTrackRef.keepSynced(true)
        storyTrackRef.observeSingleEvent(of: .value, with: { snapshot in
        self.storiesUp.forEach({ (story) in
            let snap = snapshot.childSnapshot(forPath: "\(story.id)/storyTrack")
                if let track = snap.value as? String {
                    self.user.storyTrack[story.id] = track
                    print("loadStoryTracksUp(): StoryTrack saved for " + story.id + ". StoryTrack is: " + track)
                }
        })
        })
    }
    
    func loadStoryTracksDown() {
        print("loadStoryTracksDown(): invoked")
        let storyTrackRef = Database.database().reference().child("users/\(self.user.id!)/stories/")
        storyTrackRef.keepSynced(true)
        storyTrackRef.observeSingleEvent(of: .value, with: { snapshot in
            self.storiesDown.forEach({ (story) in
                let snap = snapshot.childSnapshot(forPath: "\(story.id)/storyTrack")
                if let track = snap.value as? String {
                    self.user.storyTrack[story.id] = track
                    print("loadStoryTracksDown(): Upper track saved for " + story.id)
                } else { self.user.storyTrack[story.id] = "" }
            print("loadStoryTracksDown(): Down storyTrack is " + String(describing: self.user.storyTrack[story.id]) + " for story with title: " + story.title)
            })
        })
    }
    
    
    // 2.3
    func loadCompletedStoriesUp() {
        print("loadCompletedStoriesUp(): invoked")
        
        for story in self.storiesUp {
            let storyRef = Database.database().reference().child("users/\(self.user.id!)/stories/\(story.id)/completed")
            storyRef.keepSynced(true)
            storyRef.observeSingleEvent(of: .value, with: { snapshot in
                print("loadCompletedStoriesUp(): Snapshot.value is " + String(describing: snapshot.value))
                if snapshot.exists() {
                    let completed = snapshot.value as! String
                    let completedBool = Bool(completed)
                    story.completed = completedBool!
                    print("loadCompletedStoriesUp(): Story \(story.title) completed " + String(describing: completed))
                } else {
                    story.completed = false
                    print("loadCompletedStoriesUp(): Story \(story.title) completed - FALSE.")
                }
            })
        }
    }
    
    // 2.4.
    typealias wordsClosure = (Array<Word>?) -> Void
    
    func loadWordsForStoriesUp(initial: Bool, completion: @escaping wordsClosure) {
        print("loadWordsForStoriesUp() is invoked")

        let wordsRef = Database.database().reference().child("words")
        wordsRef.keepSynced(true)
        wordsRef.observeSingleEvent(of: .value, with: { snapshot in
        self.storiesUp.forEach({ (story) in
            for word in story.words {
                    let isActive = snapshot.childSnapshot(forPath: "/\(word)/isActive").value as! Bool
                    if isActive {
                            let definition = snapshot.childSnapshot(forPath: "/\(word)/definition").value as! String
                            let example0 = snapshot.childSnapshot(forPath: "/\(word)/example0").value as! String
                            let example1 = snapshot.childSnapshot(forPath: "/\(word)/example1").value as! String
                            let id = snapshot.childSnapshot(forPath: "/\(word)/id").value as! String
                            let title = snapshot.childSnapshot(forPath: "/\(word)/title").value as! String
                            print("loadWordsForStoriesUp(): Title of the word is " + title)
                            let type = snapshot.childSnapshot(forPath: "/\(word)/type").value as! String
                            let wordInit = Word(id: id, title: title, definition: definition, type: type, example0: example0, example1: example1)
                            if let _ = self.wordsPool.first(where: {$0.title == title}) {
                                print("loadWordsForStoriesUp(): word is already in the array")
                            } else {
                                self.wordsPool.append(wordInit)
                                print("loadWordsForStoriesUp(): self.wordsPool.count is " + String(self.wordsPool.count))
                            }
                        }
                 }
            })
             completion(self.wordsPool)
        })
        //
        }

    // 2.5
    func loadUserStories() {

        print("loadUserStories()")
        self.user.storiesActive = []
        let usersRef = Database.database().reference().child("users").child("\(self.user.id!)").child("storyRefs")
        usersRef.keepSynced(true)
        usersRef.observeSingleEvent(of: .value, with: { snapshot in
        if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
        for snap in snapshots {
        let title = snap.key
        self.user.storiesActive!.append(title) }
        } else { print("loadUserStories(): no user stories") }
            print("loadUserStories(): User stories are counting " + String(describing: self.user.storiesActive!.count))
        })
    }
    
    
    
    // 3.1
    func filterWordsForStoriesUp(initial: Bool) {
        
        print("filterWordsForStoriesUp() is invoked")
        self.storiesUp.forEach({ (story) in
        var wordsNumbersForStory = Array<String>()
        var usedWords = Array<String>()
        var wordsPoolForStory = Array<Word>()
        wordsNumbersForStory = story.words
        let storyId = story.id
        print("filterWordsForStoriesUp(): wordsNumbersForStory.count for story \(story.title) is " + String(wordsNumbersForStory.count))
        let wordsRef = Database.database().reference().child("users/\(self.user.id!)/stories/\(storyId)/wordUsed/")
        wordsRef.keepSynced(true)
        wordsRef.observeSingleEvent(of: .value, with: { snapshot in
        if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
            for snap in snapshots {
                let usedWord = snap.value as! String
                print("filterWordsForStoriesUp(): used word No. for story \(story.title) is" + usedWord)
                usedWords.append(usedWord)
            }
                wordsNumbersForStory = wordsNumbersForStory.filter { !usedWords.contains($0) }
                    }
                    wordsPoolForStory = self.wordsPool.filter { wordsNumbersForStory.contains($0.id) }
                    print("filterWordsForStoriesUp(): self.wordsPoolForStory.count for story \(story.title) is " + String(wordsPoolForStory.count))
                    let pickedWords = wordsPoolForStory.shuffled.choose(self.user.wordsPerLevel!)
                    print("filterWordsForStoriesUp(): pickedWords.count for story \(story.title) is " + String(pickedWords.count))
                    story.wordsObj = pickedWords
                })
        })
    }
    
    
    // 3.2

    func loadSummariesForStoriesUp(initial: Bool, completion: @escaping storiesClosure) {
        print("loadSummariesForStoriesUp() is invoked")
        if self.user.storiesActive!.count == 0 {
            self.storiesUp.forEach({ (story) in
                story.checked = true })
            completion(self.storiesUp)
        } else {
        let summaryRef = Database.database().reference().child("users/\(self.user.id!)/stories")
        summaryRef.keepSynced(true)
        summaryRef.observeSingleEvent(of: .value, with: { snapshot in
            self.storiesUp.forEach({ (story) in
            if let storyTrack = self.user.storyTrack[story.id] {
                var trackTemp = storyTrack
                var tracks = Array<String>()
                print("loadSummariesForStoriesUp(): storyTrack is: " + String(describing: trackTemp))
                while trackTemp.count != 0 {
                    tracks.append(trackTemp)
                    trackTemp.removeLast()
                    print("loadSummariesForStoriesUp(): " + story.title + " decrement track to: " + trackTemp)
                    print("loadSummariesForStoriesUp(): " + story.title + " tracks are: " + String(describing: tracks))
                }
                for trac in tracks {
                let snap = snapshot.childSnapshot(forPath: "\(story.id)/summaries/\(trac)")
                if snap.exists() {
                    print("loadSummariesForStoriesUp(): " + story.title + " : snapshot exists.")
                        let id = snap.childSnapshot(forPath: "ID").value as! String
                        let trock = snap.childSnapshot(forPath: "storyTrack").value as! String
                        let title = snap.childSnapshot(forPath: "title").value as! String
                        let opener = snap.childSnapshot(forPath: "opener").value as! String
                        let mnemmalContent = snap.childSnapshot(forPath: "mnemmalContent").value as! String
                        let mnemmalDate = snap.childSnapshot(forPath: "mnemmalDate").value as! String
                    
                        self.loadUsedWordsForSummaries(storyToLoad: story, storyTrack: trock) { words in
                            let summary = DailySummary(id: id, storyTrack: trock, title: title, opener: opener, mnemmalContent: mnemmalContent, mnemmalDate: mnemmalDate, wordsObj: words!)
                        story.summaries[trock] = summary
                        print("loadSummariesForStoriesUp(): " + story.title + trock + " new summary was added for day: " + summary.title!)
                        if trac.count == 1 { story.checked = true
                        completion(self.storiesUp)
                        print("loadSummariesForStoriesUp(): " + story.title + " story is checked. Words exist.") } }
                } else { if trac.count == 1 { story.checked = true
                        completion(self.storiesUp)
                    print("loadSummariesForStoriesUp(): " + story.title + " snapshot DOES NOT EXIST. Story checked as true.") }
                    }
                }
            } else {
                story.checked = true
                completion(self.storiesUp)
                print("loadSummariesForStoriesUp():" + story.title + " NO STORY TRACK FOR STORY. Story checked as true.") }
            })
        }) } }
    
    func loadSummariesForStoriesDown() {
        print("loadSummariesForStoriesDown() is invoked")
        let summaryRef = Database.database().reference().child("users/\(self.user.id!)/stories")
        summaryRef.keepSynced(true)
        if self.user.storiesActive!.count == 0 {
            return
        } else {
            summaryRef.observeSingleEvent(of: .value, with: { snapshot in
                self.storiesDown.forEach({ (story) in
                    if var storyTrack = self.user.storyTrack[story.id] {
                        print("loadSummariesForStoriesDown(): storyTrack is: " + String(describing: storyTrack))
                        repeat {
                            let snap = snapshot.childSnapshot(forPath: "\(story.id)/summaries/\(storyTrack)")
                            if snap.exists() {
                                print("loadSummariesForStoriesDown(): snapshot exists.")
                                guard
                                    let id = snap.childSnapshot(forPath: "ID").value as? String,
                                    let storyTrack = snap.childSnapshot(forPath: "storyTrack").value as? String,
                                    let title = snap.childSnapshot(forPath: "title").value as? String,
                                    let opener = snap.childSnapshot(forPath: "opener").value as? String,
                                    let mnemmalContent = snap.childSnapshot(forPath: "mnemmalContent").value as? String,
                                    let mnemmalDate = snap.childSnapshot(forPath: "mnemmalDate").value as? String,
                                    let closer = snap.childSnapshot(forPath: "closer").value as? String,
                                    let chosenOption = snap.childSnapshot(forPath: "chosenOption").value as? String
                                    else {
                                        print("loadSummariesForStoriesDown(): error with loading the summaries")
                                        return
                                }
                                print("loadSummariesForStoriesDown(): " + id + title + closer)
                                self.loadUsedWordsForSummaries(storyToLoad: story, storyTrack: storyTrack) { words in
                                    let summary = DailySummary(id: id, storyTrack: storyTrack, title: title, opener: opener, mnemmalContent: mnemmalContent, mnemmalDate: mnemmalDate, wordsObj: words!)
                                    story.summaries[storyTrack] = summary
                                    story.checked = true
                                    print("loadSummariesForStoriesDown(): story is checked. Words exist.")
                                    print("loadSummariesForStoriesDown(): new summary was added for day: " + summary.title!)
                                }
                            }
                            if storyTrack.characters.count > 0 { storyTrack.removeLast(1) }
                            print("loadSummariesForStoriesDown(): storyTrack w/o last character is: " + String(describing: storyTrack))
                        } while storyTrack.count != 0
                    } else {
                        print("loadSummariesForStoriesDown(): snapshot DOES NOT EXIST. Story checked as true.") }
                })
            })
        }
    }
    
    func addSummaryForStory(summary: DailySummary) {
        print("addSummaryForStory(): is invoked")
        self.storiesDown[self.storyIndexPath!.row].summaries[summary.storyTrack!] = summary
    }
    
    func loadUsedWordsForSummaries(storyToLoad: Story, storyTrack: String, completion: @escaping wordsClosure) -> Void {
        print("loadUsedWordsForSummaries(): is invoked")
        var wordsRefs = Array<String>()
        var words: Array<Word>?
        let usedWordsRef = Database.database().reference().child("users/\(self.user.id!)/stories/\(storyToLoad.id)/summaries/\(storyTrack)/words")
        usedWordsRef.keepSynced(true)
        usedWordsRef.observeSingleEvent(of: .value, with: { snapshot in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshots
                {
                    let wordId = snap.value as! String
                    wordsRefs.append(wordId)
                    print("loadUsedWordsForSummaries(): used word ID added: " + wordId)
                }
            }
            words = self.wordsPool.filter { wordsRefs.contains($0.id) }
            print("loadUsedWordsForSummaries(): words are filtered. Words objects amount is: " + String(describing: words!.count))
            completion(words)
            return
            })
    }
    
    
    // 4.1
    func filterStories() {
        print("filterStories() is invoked")
        self.storiesDown = self.storiesUp.filter { self.user.storiesActive!.contains($0.id) }
        print("filterStories(): Stories in storiesAddedSource to fetch counting: " + String(self.storiesDown.count))
        self.storiesUp = self.storiesUp.filter { !self.user.storiesActive!.contains($0.id) }
        self.storiesUp = self.storiesUp.filter { $0.onStand == true }
        print("filterStories():  self.storiesAddedSource.count is: " + String(self.storiesDown.count))
        print("filterStories(): self.storiesForCollectionView.count is: "
            + String(self.storiesUp.count))
        self.loadLastDatesForStoriesDown()
        self.loadLevelsForStoriesDown()
        checkVisibilityOfUIElements(initial: true)
        HUD.flash(.success, onView: nil, delay: 0) { bool in
            self.popTipShow()
        }
    }
    
    func loadLastDatesForStoriesDown() {
        print("loadLastDatesForStoriesDown(): is invoked")
        let lastDateRef = Database.database().reference().child("users/\(self.user.id!)/stories")
        lastDateRef.observeSingleEvent(of: .value, with: { snapshot in
        for story in self.storiesDown {
            let snap = snapshot.childSnapshot(forPath: "\(story.id)/lastDate")
                if let lastDate = snap.value as? String {
                    story.lastDate = lastDate
                    if lastDate != self.getCurrentDate() {
                        story.newDay = true
                    } else { story.newDay = false }
                    print("loadLastDatesForStoriesDown(): last Date for Story \(story.title) is: " + lastDate) }
                else { print("loadLastDatesForStoriesDown(): No last dates for story \(story.title)") }
             }
            self.checkVisibilityOfUIElements(initial: false)
 })
    }


    func loadLevelsForStoriesDown() {
        print("loadLevelsForStoriesDown(): is invoked")
        let levelsRef = Database.database().reference().child("users/\(self.user.id!)/storyRefs")
        levelsRef.keepSynced(true)
        levelsRef.observeSingleEvent(of: .value, with: { snapshot in
            for story in self.storiesDown {
                let level = snapshot.childSnapshot(forPath: "\(story.id)").value as! String
                story.storyLevel = level
                print("loadLevelsForStoriesDown(): Level for story " + story.title + " is " + String(describing: level)) }
            self.checkVisibilityOfUIElements(initial: false)
        })
    }
    
    
    // - MARK: Adding and removal story to User
    
    func getStory(initialStoryTrack: String, fromSubmission: Bool) {
        print("getStory() is invoked")
        var indexPath: IndexPath?
        if fromSubmission {
            indexPath = self.storyIndexPath!
            print("getStory(): indexPath is: " + String(describing: self.storyIndexPath!.row))
        } else { indexPath = self.getIndexForVisibleCell(collectionViewUp)! }
            self.user.storyTrack[self.storiesUp[indexPath!.row].id] = initialStoryTrack
            setInitialStoryTrack(story: self.storiesUp[indexPath!.row], storyTrack: initialStoryTrack)
            self.storiesDown.insert(self.storiesUp[indexPath!.row], at: 0)
            let storyRefToUpdateUserAccount = self.storiesUp[indexPath!.row].id
            self.user.storiesActive!.append(storyRefToUpdateUserAccount)
            self.storiesUp.remove(at: indexPath!.item)
            self.collectionViewUp.reloadData()
            setCurrentDayForNewStory(storyRefToUpdateUserAccount)
            self.storiesDown[0].newDay = true
            checkVisibilityOfUIElements(initial: false)
            self.collectionViewDown.reloadData()
        }
    
    func setInitialStoryTrack(story: Story, storyTrack: String) {
        let storyTrackRef = Database.database().reference().child("users/\(self.user.id!)/stories/\(story.id)/storyTrack")
        storyTrackRef.setValue(storyTrack)
    }
    
    
    func setCurrentDayForNewStory(_ source: String) {
        let daysRef = Database.database().reference().child("users/\(self.user.id!)/storyRefs/\(source)/")
        daysRef.setValue("1")
        print("setCurrentDayForNewStory(): Day for the story has been set to 1")
    }
    
    @objc func removeStory(indexPath: IndexPath, storyId: String) {
        print("removeStory(): is invoked")
        self.storiesDown[indexPath.row].lastDate = nil
        self.storiesDown[indexPath.row].storyLevel = "1"
        self.storiesDown[indexPath.row].newDay = true
        self.storiesDown[indexPath.row].completed = false
        
        self.storiesUp.insert(self.storiesDown[indexPath.row], at: 0)
        self.storiesDown.remove(at: indexPath.row)
        self.animateReloading(collectionViewDown)
        self.animateReloading(collectionViewUp)
        let daysRef = Database.database().reference().child("users/\(self.user.id!)/storyRefs/\(storyId)")
        daysRef.removeValue()
        let wordsRef = Database.database().reference().child("users/\(self.user.id!)/stories/\(storyId)")
        wordsRef.removeValue()
        print("removeStory(): Info removed")
        checkVisibilityOfUIElements(initial: false)
        scrollToCenter(array: self.storiesUp, collectionView: self.collectionViewUp)
        removeUserMnemmalsFromCommonPool(indexPath: indexPath)
    }
    
    func removeUserMnemmalsFromCommonPool(indexPath: IndexPath) {
        print("removeUserMnemmalsFromCommonPool(): is invoked")
        let storyId = self.storiesUp[0].id
        print("removeUserMnemmalsFromCommonPool(): id is " + String(describing: storyId) + ". storyTrack is " + String(describing: self.user.storyTrack[storyId]!))
        repeat {
        let mnemmalRef = Database.database().reference().child("mnemmals/\(storyId)/\(self.user.storyTrack[storyId]!)")
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
        } while self.user.storyTrack[storyId]!.count != 0
        self.user.storyTrack[storyId] = ""
    }
    
    
    func fetchWordsAfterSubmission(storyLevel: String, completedStatus: Bool, indexPath: IndexPath, isNews: Bool) {
        print("fetchWordsAfterSubmission(): is invoked")
        var inp = IndexPath(item: 0, section: 0)
        if !isNews { inp = indexPath }
        self.storiesDown[inp.row].storyLevel = storyLevel
        self.storiesDown[inp.row].completed = completedStatus
        self.storiesDown[inp.row].newDay = false
        self.loadWordsForStoriesUp(initial: false) { words in
        }
        self.storiesDown[inp.row].lastDate = getCurrentDate()
        self.loadLevelsForStoriesDown()
        self.checkVisibilityOfUIElements(initial: false)
    }
    
    func updateStoryTrack(track: String, storyId: String) {
        print("updateStoryTrack(): is invoked")
        self.user.storyTrack[storyId] = track
        print("updateStoryTrack(): updated storyTrack is: " + track)
    }
    
    @objc func updateUserObject() {
        print("MainVC: updateUserObject is invoked")
        HUD.show(.progress)
        if let user = Auth.auth().currentUser {
            print("MainVC: User ID is \(user.uid)")
            print("MainVC: User is logged in Firebase.")
            self.user.id = user.uid
            if let fbId = UserProfile.current?.userId { self.user.fbId = fbId } else {self.user.fbId = "none" }
            if let userName = UserProfile.current?.fullName { self.user.name = userName } else {self.user.name = "Anonymous" }
            self.globalLoading(sideMenu: false)
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
            nextScene.invokedFromDown = self.invokedFromDown!
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
            nextScene.user = self.user
            if let inp = self.storyIndexPath { nextScene.storyIndexPath = inp
                print("Prepare for segue storyOverlook")
                
            }
        }
    }
    
    // MARK: - UI
    
    func setupSideMenu() {
        if let menuLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? UISideMenuNavigationController {
            menuLeftNavigationController.leftSide = true
            SideMenuManager.default.menuLeftNavigationController = menuLeftNavigationController
            SideMenuManager.default.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
            SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
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
    
    func moveToTopStoriesDown() {
        print("moveToTopStoriesDown(): invoked")
        self.storiesDown.sort { $0.storyLevel < $1.storyLevel }
        self.storiesDown.sort { !$0.completed && $1.completed }
        self.storiesDown.sort { $0.newDay && !$1.newDay }
        self.collectionViewDown.reloadData()
        
    }
    
    func getIndexForVisibleCell(_ collectionView: UICollectionView) -> IndexPath? {
        print("getIndexForVisibleCell(): invoked")
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let visibility = collectionView.indexPathForItem(at: visiblePoint)
        return visibility
    }
    
    func checkVisibilityOfUIElements(initial: Bool) {
        print("checkVisibilityOfUIElements(): invoked")
        
        if self.storiesUp.count == 0 {
            self.collectionViewUp.isHidden = true
            self.emptyUp.isHidden = false
            self.emptyUpLabel.isHidden = false
        } else {
            self.emptyUp.isHidden = true
            self.emptyUpLabel.isHidden = true
            self.collectionViewUp.isHidden = false
        }
        if self.storiesDown.count == 0 {
            self.collectionViewDown.isHidden = true
            self.emptyDown.isHidden = false
            self.emptyDownLabel.isHidden = false
        } else {
            self.emptyDown.isHidden = true
            self.emptyDownLabel.isHidden = true
            self.collectionViewDown.isHidden = false
        }
        if initial { self.animateReloading(collectionViewUp) }
        self.moveToTopStoriesDown()
        self.scrollToCenter(array: storiesUp, collectionView: collectionViewUp)
        self.scrollToCenter(array: storiesDown, collectionView: collectionViewDown)
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
            self.storyToPass = self.storiesDown[indexPath.row]
            self.storyIndexPath = indexPath
            cell.scrollingImage.alpha = 0.5
            cell.removeButton.isHidden = false
                cell.removeButton.addTarget(self, action: #selector(remove), for: .touchUpInside)
            self.storiesDown[indexPath.row].image = cell.scrollingImage.image!
            indexPathRemoval = indexPath
            storyIdRemoval = self.storiesDown[indexPath.row].id
        } else {
            print("couldn't find index path")
        }
        }
        }
    }
    
    func summarySegue() {
        performSegue(withIdentifier: "summary", sender: self)
    }
    
    @objc func remove() {
        print("remove(): invoked")
        deleteModeActivated = false
        removeStory(indexPath: indexPathRemoval!, storyId: storyIdRemoval!)
    }
    
    func scrollToCenter(array: Array<Story>, collectionView: UICollectionView) {
        print("scrollToCenter(): invoked")
        if collectionView == collectionViewUp {
        if array.count != 0 {
            if let indexPath = self.getIndexForVisibleCell(collectionViewUp) {
                collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true) } else {
        }
        }
        } else {
        if array.count != 0 {
            collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
        }
    }
    }
    
    func toRoman(number: Int) -> String {
        
        let romanValues = ["M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I"]
        let arabicValues = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1]
        
        var romanValue = ""
        var startingValue = number
        
        for (index, romanChar) in romanValues.enumerated() {
            let arabicValue = arabicValues[index]
            
            let div = startingValue / arabicValue
            
            if (div > 0)
            {
                for j in 0..<div
                {
                    //println("Should add \(romanChar) to string")
                    romanValue += romanChar
                }
                
                startingValue -= arabicValue * div
            }
        }
        
        return romanValue
    }
    
    func getCurrentDate() -> String {
        let formatter = DateFormatter()
        let date = Date()
        formatter.dateFormat = "MMM dd, yyyy"
        let stringDate: String = formatter.string(from: date)
        print(stringDate)
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
    
    @objc func setPremium() {
        self.user.premium = true
    }
    
    @objc func setNotPremium() {
        self.user.premium = false
    }
    
    func countForReviewPopup() {
        print("countForReviewPopup(): invoked")
        let defaults:UserDefaults = UserDefaults.standard
        var counter = defaults.integer(forKey: "reviewCounter")
        print("countForReviewPopup(): counter retrieved is: " + String(describing: counter))
        if counter == 25 { SKStoreReviewController.requestReview()
        print("countForReviewPopup(): reviewController invoked.")
        }
        counter += 1
        defaults.set(counter, forKey: "reviewCounter")
        print("countForReviewPopup(): counter set as: " + String(describing: counter))
    }
    
    func popTipShow() {
        let defaults:UserDefaults = UserDefaults.standard
        let tip = defaults.bool(forKey: "tip")
        if tip == false {
        print("tip is false")
        let customView = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height / 3, width: 1, height: 1))
        customView.isHidden = true
        self.view.addSubview(customView)
        let popTip = PopTip()
        popTip.bubbleColor = UIColor(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1)
        popTip.cornerRadius = 10.0
        popTip.shouldDismissOnTap = true
        popTip.show(text: "Swipe from the edge to check your account settings. Have fun!", direction: .right, maxWidth: 150, in: view, from: customView.frame, duration: 10)
        }
    }
    
    // - MARK: VC LifeCycle

    override func viewDidLoad() {
        PKHUD.sharedHUD.dimsBackground = true
        super.viewDidLoad()
        Database.database().isPersistenceEnabled = true
        self.setupSideMenu()
        self.emptyUp.isHidden = true
        self.emptyUpLabel.isHidden = true
        self.emptyDown.isHidden = true
        self.emptyDownLabel.isHidden = true
        self.emptyUp.layer.cornerRadius = 10.0
        self.emptyDown.layer.cornerRadius = 10.0
        
        let nib = UINib(nibName: "MainCollectionViewCell", bundle: nil)
        collectionViewUp.register(nib, forCellWithReuseIdentifier: "MainCollectionViewCell")
        collectionViewDown.register(nib, forCellWithReuseIdentifier: "MainCollectionViewCell")
        
        // RefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .lightGray
        refreshControl.addTarget(self,
                                 action: #selector(self.refreshOptions),
                                 for: .valueChanged)
        collectionViewDown.refreshControl = refreshControl
        
        // Authorization
        if let accessToken = AccessToken.current?.authenticationToken {
                    // self.user.storyTrack.removeAll()
                    print("MainVC: Facebook User logged in!")
                    if let user = Auth.auth().currentUser {
                        print("MainVC: User ID is \(user.uid)")
                        self.user.id = user.uid
                        self.user.fbId = UserProfile.current!.userId
                        self.user.name = UserProfile.current!.fullName
                        print("userName is: " + self.user.name!)
                        self.user.wordsPerLevel = 3
                        self.globalLoading(sideMenu: true)
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
                    self.globalLoading(sideMenu: true)
                }
            }
        }

        NotificationCenter.default.addObserver(self,
                                            selector: #selector(updateUserObject),
                                            name: NSNotification.Name(rawValue: "UserObjectUpdated"),
                                            object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setPremium),
                                               name: NSNotification.Name(rawValue: "PremiumPurchased"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setNotPremium),
                                               name: NSNotification.Name(rawValue: "PremiumNOTPurchased"),
                                               object: nil)

        // GestureRecognizer
        let longGest = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        collectionViewDown.addGestureRecognizer(longGest)
        collectionViewDown.backgroundView?.isUserInteractionEnabled = false
        }

    override func viewDidAppear(_ animated: Bool) {
        self.checkVisibilityOfUIElements(initial: false)
        self.countForReviewPopup()
    }
}
