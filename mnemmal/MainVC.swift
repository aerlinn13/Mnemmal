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

class MainVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FetchWordsAfterSubmissionDelegate, StoryRemovalDelegate {

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
        
        if collectionView == collectionViewUp {
        cell.dayNumLabel.isHidden = true
        cell.dayNumBG.isHidden = true
        cell.storyLabel.text = storiesForCollectionView[indexPath.row].title
        let textColor = UIColor(hexString: "\(storiesForCollectionView[indexPath.row].titleColor)")
        cell.storyLabel.textColor = textColor
            
        let imageRef = reference.child("\(storiesForCollectionView[indexPath.row].id).png")
        cell.scrollingImage.sd_setImage(with: imageRef, placeholderImage: placeholderImage)
            storiesForCollectionView[indexPath.row].image = cell.scrollingImage.image!
        cell.getButton.addTarget(self, action: #selector(MainVC.getStory), for: .touchUpInside)
        if storiesForCollectionView[indexPath.row].premium == true {
            cell.premium.isHidden = false } else {
            cell.premium.text = "for free"
            }
    }
        else {
            cell.premium.isHidden = true
            cell.getButton.isHidden = true
            cell.storyLabel.text = storiesAddedSource[indexPath.row].title
            let textColor = UIColor(hexString: "\(storiesAddedSource[indexPath.row].titleColor)")
            cell.storyLabel.textColor = textColor
            print(storiesAddedSource[indexPath.row].storyLevel + "- this is storyLevel - ReloadData()")
            
            let imageRef = reference.child("\(storiesAddedSource[indexPath.row].id).png")
            cell.scrollingImage.sd_setImage(with: imageRef, placeholderImage: placeholderImage)
            storiesAddedSource[indexPath.row].image = cell.scrollingImage.image!

            if storiesAddedSource[indexPath.row].completed == false {
            cell.dayNumLabel.text = "DAY " + storiesAddedSource[indexPath.row].storyLevel
            if self.storiesAddedSource[indexPath.row].lastDate != getCurrentDate() {
                cell.dayNumLabel.textColor = UIColor(red: 0/255.0, green: 180/255.0, blue: 0/255.0, alpha: 1)
                self.storiesAddedSource[indexPath.row].newDay = true
            } else {
                cell.dayNumLabel.textColor = UIColor.lightGray
            }
            } else {
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
        if collectionView == collectionViewUp {
        }
        else {
            print(getCurrentDate())
            self.storyToPass = self.storiesAddedSource[indexPath.row]
            print("didSelectItemAt()")
            self.storyIndexPath = indexPath
            if !self.storiesAddedSource[indexPath.row].completed {
            if self.storiesAddedSource[indexPath.row].lastDate != getCurrentDate() {
            performSegue(withIdentifier: "submit", sender: self)
        }
        else { performSegue(withIdentifier: "summary", sender: self) }
            }
            else { performSegue(withIdentifier: "summary", sender: self) }
        }
    }
    
    
    func getCurrentDate() -> String {
        let formatter = DateFormatter()
        let date = Date()
        formatter.dateFormat = "dd-MM-yyyy"
        let stringDate: String = formatter.string(from: date)
        return stringDate
    }
    
    
   func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.collectionViewUp {
            if let indexPath = self.getIndexForVisibleCell(collectionViewUp) {
                self.collectionViewUp.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true) }
        }
    }
    
    
    // - MARK: Data transfer

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "submit" {
            let nextScene =  segue.destination as! SubmissionVC
            if let story = self.storyToPass { nextScene.story = story
                print("Prepare for segue Submit")
            }
            nextScene.user = self.user
            nextScene.fetchDelegate = self
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
        }
    }


    
    // - MARK: Working with Stories
    
    // 1 Retrieve all stories and put them in upper CollectionView
    func retrievingAllStories() {
        HUD.show(.progress)
        print("retrieveAllStories()")
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
                    let titleColor = snap.childSnapshot(forPath: "titleColor").value as! String
                    let premium = snap.childSnapshot(forPath: "premium").value as! Bool
                    let story = Story(isActive: isActive, title: title, daysAmount: daysAmount, id: id, genre: genre, words: words, subtext: subtext, premium: premium, titleColor: titleColor, wordsColor: "grey", hidden: false)
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
                print("Snapshot.value is " + String(describing: snapshot.value))
                if snapshot.exists() {
                    let completed = snapshot.value as! String
                    let completedBool = Bool(completed)
                    story.completed = completedBool!
                    print("Story \(story.title) completed " + String(describing: completed))
                } else {
                    story.completed = false
                    print("Story \(story.title) completed - FALSE.")
                }
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
        self.user.storyTrack[story.id] = String(describing: arc4random_uniform(2))
        }
        print("storyTrack is " + self.user.storyTrack[story.id]!)
    })
        }
        } else {
    for story in self.storiesAddedSource {
    let storyTrackRef = Database.database().reference().child("users/\(self.user.id!)/stories/\(story.id)/storyTrack")
    storyTrackRef.observeSingleEvent(of: .value, with: { snapshot in
            if let storyTrack = snapshot.value as? String {
                        self.user.storyTrack[story.id] = storyTrack
                    } else {
                        self.user.storyTrack[story.id] = String(describing: arc4random_uniform(2))
                    }
                    print("storyTrack is " + self.user.storyTrack[story.id]!)
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
                    print("loadWords() - Title of the word is " + title)
                    let type = snapshot.childSnapshot(forPath: "/\(word)/type").value as! String
                    let wordInit = Word(id: id, title: title, definition: definition, type: type, example0: example0, example1: example1)
                    if let _ = self.wordsPool.first(where: {$0.title == title}) {
                        print("word is already in the array")
                    } else {
                        self.wordsPool.append(wordInit)
                        print("loadWords() - self.wordsPool.count is " + String(self.wordsPool.count))
                    }
                }
            })
            }
            
        }
             }
        self.fetchWordsForStories(withFetchingStories: withFetchingStories)
        }
    

    
    
    func fetchWordsForStories(withFetchingStories: Bool) {
        var wordsNumbersForStory = Array<String>()
        var usedWords = Array<String>()
        var wordsPoolForStory = Array<Word>()
        print("fetchWordsForStories() is invoked")
        if self.storiesForCollectionView.count != 0 {
        let x = Array(0...(self.storiesForCollectionView.count - 1))
        for item in x {
        print(" attempt No. \(item)")
        wordsNumbersForStory = self.storiesForCollectionView[item].words
        let storyId = self.storiesForCollectionView[item].id
        print("fetchWordsForStories() - wordsNumbersForStory.count for story \(self.storiesForCollectionView[item].title) is " + String(wordsNumbersForStory.count))
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
            print("fetchWordsForStories() - self.wordsPoolForStory.count for story \(self.storiesForCollectionView[item].title) is " + String(wordsPoolForStory.count))
            let pickedWords = wordsPoolForStory.shuffled.choose(self.user.wordsPerLevel!)
            print("fetchWordsForStories() - pickedWords.count for story \(self.storiesForCollectionView[item].title) is " + String(pickedWords.count))
            self.storiesForCollectionView[item].wordsObj = pickedWords
        })
        let lastDateRef = Database.database().reference().child("users/\(self.user.id!)/stories/\(storyId)/lastDate")
        lastDateRef.keepSynced(true)
        lastDateRef.observeSingleEvent(of: .value, with: { snapshot in
            print(String(describing: snapshot.value))
            if let lastDate = snapshot.value as? String {
                self.storiesForCollectionView[item].lastDate = lastDate
                print("last Date for Story  is  " + lastDate) }
            else { print("No last dates for story \(self.storiesForCollectionView[item].title)")}
        })
        }
        retrievingUserStories(withFetchingStories: withFetchingStories)
        self.activityIndicator.stopAnimating()
        } else { print("UpperSource is empty")}
    }

    
    
    // Moving stories from up to down
    
    func fetchStories() {
        print("fetchStories() is invoked")
        self.storiesAddedSource = self.storiesForCollectionView.filter { self.user.storiesActive!.contains($0.id) }
        print("fetchStories(): Stories in array to fetch counting " + String(self.storiesAddedSource.count))
        self.storiesForCollectionView = self.storiesForCollectionView.filter { !self.user.storiesActive!.contains($0.id) }
        print("fetchStories():  self.storiesAddedSource.count is " + String(self.storiesAddedSource.count))
        print("fetchStories(): self.storiesForCollectionView.count is " + String(self.storiesForCollectionView.count))
        moveAvailableStoriesAtTop()
        checkVisibilityOfUIElements()
        getCurrentLevelsForStoriesAdded()
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
            self.storiesAddedSource = self.storiesAddedSource.sorted(by: { $0.storyLevel < $1.storyLevel })
            self.activityIndicator.isHidden = true
            self.collectionViewUp.reloadData()
            self.collectionViewDown.reloadData()
            self.moveAvailableStoriesAtTop()
        })
    }
    
    
    
    // - MARK: Adding and removal story to User
    
    @objc func getStory() {
        if let visibility = self.getIndexForVisibleCell(collectionViewUp) {
            self.storiesAddedSource.insert(self.storiesForCollectionView[visibility.row], at: 0)
            let storyRefToUpdateUserAccount = self.storiesForCollectionView[visibility.row].id
            self.user.storiesActive!.append(storyRefToUpdateUserAccount)
            self.collectionViewDown.insertItems(at: [IndexPath(item: 0, section: 0)])
            self.storiesForCollectionView.remove(at: visibility.item)
            if self.storiesForCollectionView.count == 0 { self.stopTimer() }
            self.collectionViewUp.deleteItems(at: [visibility])
            setCurrentDayForNewStory(storyRefToUpdateUserAccount)
            checkVisibilityOfUIElements()
        }
    }
    
    
    func setCurrentDayForNewStory(_ source: String) {
        let daysRef = Database.database().reference().child("users/\(self.user.id!)/storyRefs/\(source)/")
        daysRef.setValue("1")
        print("setCurrentDayForNewStory(): Day for the story has been set to 1")
    }
    
    func removeStory(indexPath: IndexPath, storyId: String) {
        self.storiesAddedSource[indexPath.row].lastDate = nil
        self.storiesAddedSource[indexPath.row].storyLevel = "1"
        self.storiesForCollectionView.append(self.storiesAddedSource[indexPath.row])
        self.storiesAddedSource.remove(at: indexPath.row)
        self.animateReloading(collectionViewDown)
        self.animateReloading(collectionViewUp)
        let daysRef = Database.database().reference().child("users/\(self.user.id!)/storyRefs/\(storyId)")
        daysRef.removeValue()
        let wordsRef = Database.database().reference().child("users/\(self.user.id!)/stories/\(storyId)")
        wordsRef.removeValue()
        checkVisibilityOfUIElements()
    }
    
    
    func fetchWordsAfterSubmission(storyLevel: String, completedStatus: Bool, indexPath: IndexPath) {
        self.storiesAddedSource[indexPath.row].storyLevel = storyLevel
        self.storiesAddedSource[indexPath.row].completed = completedStatus
        loadWordsForStories(withFetchingStories: false)
        getCurrentLevelsForStoriesAdded()
    }
    
    @objc func updateUserObject() {
        print("MainVC: updateUserObject is invoked")
        if let user = Auth.auth().currentUser {
            print("MainVC: User ID is \(user.uid)")
            print("MainVC: User is logged in Firebase.")
            self.user.id = user.uid
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
        self.storiesAddedSource.sort { $0.newDay && !$1.newDay }
        collectionViewDown.reloadData()
    }
    
    func getIndexForVisibleCell(_ collectionView: UICollectionView) -> IndexPath? {
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let visibility = collectionView.indexPathForItem(at: visiblePoint)
        return visibility
    }
    
    func checkVisibilityOfUIElements() {
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
        let range = Range(uncheckedBounds: (0, collectionView.numberOfSections))
        let indexSet = IndexSet(integersIn: range)
        collectionView.reloadSections(indexSet)
    }
    
    // - MARK: Timer and scroll of upper CollectionView
    
    var timer = Timer()
    func setTimer() {
        if self.storiesForCollectionView.count != 0 {
            self.timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(MainVC.autoScroll), userInfo: nil, repeats: true)
        }
    }
    
    @objc func stopTimer() {
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
                        self.user.wordsPerLevel = 3
                        self.retrievingAllStories()
                    }
        } else {
            Auth.auth().signInAnonymously() { (user, error) in
                print("MainVC: Anonym User logged in!")
                if let user = Auth.auth().currentUser {
                    print("MainVC: User ID is \(user.uid)")
                    self.user.id = user.uid
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

    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadStoryTracks(initial: false)
        setTimer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        stopTimer()
    }
}
