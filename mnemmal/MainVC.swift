//
//  MainVC.swift
//  Mnemmal
//
//  Created by Danil on 06/09/2017.
//  Copyright © 2017 Danil Chernyshev. All rights reserved.
//

import UIKit
import Firebase

class MainVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FetchWordsAfterSubmissionDelegate {

    // - MARK: Variables
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet weak var collectionViewUp: UICollectionView!
    @IBOutlet weak var collectionViewDown: UICollectionView!
    @IBOutlet weak var emptyUp: UIImageView!
    @IBOutlet weak var emptyDown: UIImageView!
    
    var ref: DatabaseReference!
    var storiesForCollectionView = Array<Story>()
    var storiesAddedSource = Array<Story>()
    var user = User()
    var currentLevelForStory: Int?
    var storyToPass: Story?
    var storyIndexPath: IndexPath?
    
    // - MARK: CollectionView methods
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0
        if collectionView == collectionViewUp {
                count = storiesForCollectionView.count }
        else  { count = storiesAddedSource.count }
        return count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainCollectionViewCell", for: indexPath) as! MainCollectionViewCell
        cell.scrollingImage.layer.cornerRadius = 10.0
        cell.getButton.isHidden = true
        cell.storySubheader.isHidden = false
        cell.storyLabel.isHidden = false
        
        if collectionView == collectionViewUp {
        cell.storyLabel.text = storiesForCollectionView[indexPath.row].title
        let textColor = UIColor(hexString: "\(storiesForCollectionView[indexPath.row].titleColor)")
        cell.storyLabel.textColor = textColor
        cell.storySubheader.text = String(storiesForCollectionView[indexPath.row].genre) + ", " + String(storiesForCollectionView[indexPath.row].daysAmount) + " days"
        cell.storySubheader.textColor = textColor
        cell.scrollingImage.image = UIImage(named: "\(storiesForCollectionView[indexPath.row].image)")
        cell.getButton.addTarget(self, action: #selector(getStory), for: .touchUpInside)
        }
        
        else {
            cell.storyLabel.text = storiesAddedSource[indexPath.row].title
            let textColor = UIColor(hexString: "\(storiesAddedSource[indexPath.row].titleColor)")
            cell.storyLabel.textColor = textColor
            cell.storySubheader.text = String(storiesAddedSource[indexPath.row].daysAmount) + " days"
            cell.storySubheader.textColor = textColor
            cell.scrollingImage.image = UIImage(named: "\(storiesAddedSource[indexPath.row].image)")
            }
        return cell
    }
    
   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: collectionView.frame.width - 20, height: 140)
            return size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == collectionViewUp {
            if let cell = self.collectionViewUp.cellForItem(at: indexPath) as? MainCollectionViewCell {
                if cell.getButton.isHidden == true {
                    cell.getButton.isHidden = false
                    cell.storySubheader.isHidden = true
                    cell.storyLabel.isHidden = true
                    self.timer.invalidate()
                }
                else {
                    cell.getButton.isHidden = true
                    cell.storySubheader.isHidden = false
                    cell.storyLabel.isHidden = false
                }
                }
        }
            
        else {
            print(getCurrentDate())
            self.storyToPass = self.storiesAddedSource[indexPath.row]
            print("didSelectItemAt()")
            self.storyIndexPath = indexPath
            if self.storiesAddedSource[indexPath.row].lastDate != getCurrentDate() {
            performSegue(withIdentifier: "submit", sender: self)
        } else { performSegue(withIdentifier: "summary", sender: self) }
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
        let indexPath = self.getIndexForVisibleCell(collectionViewUp)
        self.collectionViewUp.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    
    // - MARK: Data transfer

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "submit" {
            let nextScene =  segue.destination as! SubmissionVC
            if let story = self.storyToPass { nextScene.story = story
                print("Prepare for segue")
            }
            nextScene.user = self.user
            nextScene.fetchDelegate = self
            if let inp = self.storyIndexPath { nextScene.storyIndexPath = inp }
        } else if segue.identifier == "summary" {
            let nextScene =  segue.destination as! SummaryVC
            if let story = self.storyToPass { nextScene.story = story
                print("Prepare for segue")
            }
            nextScene.user = self.user
        }
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
    

    
    // - MARK: Working with Stories
    
    // 1 Retrieve all stories and put them in upper CollectionView
    func retrievingAllStories() {
        print("retrieveAllStories()")
        let storiesRef = Database.database().reference().child("stories")
        storiesRef.keepSynced(true)
        storiesRef.observeSingleEvent(of: .value, with: { snapshot in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshots
                {
                    let isActive = snap.childSnapshot(forPath: "isActive").value as! Bool
                    if isActive {
                    let title = snap.childSnapshot(forPath: "title").value as! String
                    print("Title of the story is " + title)
                    let daysAmount = snap.childSnapshot(forPath: "daysAmount").value as! Int
                    print("Amount of days for the story is " + String(daysAmount))
                    let id = snap.childSnapshot(forPath: "id").value as! String
                    let genre = snap.childSnapshot(forPath: "genre").value as! String
                    let words = snap.childSnapshot(forPath: "words").value as! Array<String>
                    print("Words for that story are " + String(describing: words))
                    let image = snap.childSnapshot(forPath: "image").value! as! String
                    let subtext = snap.childSnapshot(forPath: "subtext").value! as! String
                    let titleColor = snap.childSnapshot(forPath: "titleColor").value as! String
                    let premium = snap.childSnapshot(forPath: "premium").value as! Bool
                    let story = Story(isActive: isActive, title: title, daysAmount: daysAmount, id: id, genre: genre, words: words, subtext: subtext, premium: premium, titleColor: titleColor, wordsColor: "grey", image: image, hidden: false)
                self.storiesForCollectionView.append(story)
                    } else { print("story is inactive") }
                    print("Amount of stories in upper CollectionView is " + String(self.storiesForCollectionView.count))
                }
            }
            self.retrievingUserStories()
        })
    }
    

    // 2 Retrieve id's of user stories.
    func retrievingUserStories() {
        print("retrievingUserStories()")
        self.user.storiesActive = []
        let usersRef = Database.database().reference().child("users").child("\(self.user.id!)").child("storyRefs")
        usersRef.keepSynced(true)
        usersRef.observeSingleEvent(of: .value, with: { snapshot in
        if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshots {
        let title = snap.key
        self.user.storiesActive!.append(title) }
        } else { print("no user stories") }
            print("User stories are counting " + String(describing: self.user.storiesActive!.count))
        self.fetchStories()
        })
    }
    
    
    // 3 Moving stories that User has from upper to lower collectionView
    func fetchStories() {
        print("fetchStories()")
        self.storiesAddedSource = self.storiesForCollectionView.filter { self.user.storiesActive!.contains($0.id) }
        print("Stories in array to fetch counting " + String(self.storiesAddedSource.count))
        self.storiesForCollectionView = self.storiesForCollectionView.filter { !self.user.storiesActive!.contains($0.id) }
        print("self.storiesAddedSource.count is " + String(self.storiesAddedSource.count))
        print("self.storiesForCollectionView.count is " + String(self.storiesForCollectionView.count))
        loadWords()
        getCurrentLevelsForStoriesAdded()
        self.collectionViewUp.reloadData()
        self.collectionViewDown.reloadData()
        checkVisibility()
}


     func getCurrentLevelsForStoriesAdded() {
        print("getCurrentLevelsForStoriesAdded()")
            let levelsRef = Database.database().reference().child("users/\(self.user.id!)/storyRefs/")
            levelsRef.keepSynced(true)
        levelsRef.observeSingleEvent(of: .value, with: { snapshot in
            for story in self.storiesAddedSource {
            let level = snapshot.childSnapshot(forPath: "\(story.id)").value as! String
            story.storyLevel = level
                print("Level for story " + story.title + " is " + String(describing: level)) }
            })
}


    
    // - MARK: Adding story to User

    @objc func getStory() {
        let visibility = self.getIndexForVisibleCell(collectionViewUp)
        self.storiesAddedSource.insert(self.storiesForCollectionView[visibility.row], at: 0)
        loadWords()
        let storyRefToUpdateUserAccount = self.storiesForCollectionView[visibility.row].id
        self.user.storiesActive!.append(storyRefToUpdateUserAccount)
        self.collectionViewDown.insertItems(at: [IndexPath(item: 0, section: 0)])
        self.storiesForCollectionView.remove(at: visibility.item)
        self.collectionViewUp.deleteItems(at: [visibility])
        setCurrentDayForStory(storyRefToUpdateUserAccount)
        checkVisibility()
    }
    
    
    func setCurrentDayForStory(_ source: String) {
        let daysRef = Database.database().reference().child("users/\(self.user.id!)/storyRefs/\(source)/")
        daysRef.setValue("1")
        print("Day for the story has been set to 1")
    }
    
    func getIndexForVisibleCell(_ collectionView: UICollectionView) -> IndexPath {
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let visibility = collectionView.indexPathForItem(at: visiblePoint)!
        return visibility
    }
    
    func checkVisibility() {
        if self.storiesForCollectionView.count == 0 {
            self.collectionViewUp.isHidden = true
            self.emptyUp.isHidden = false
        } else {
            self.emptyUp.isHidden = true
            self.collectionViewUp.isHidden = false
        }
        
        if self.storiesAddedSource.count == 0 {
            self.collectionViewDown.isHidden = true
            self.emptyDown.isHidden = false
        } else { self.emptyDown.isHidden = true
            self.collectionViewDown.isHidden = false
        }
    }
    
    
    
    
    // - MARK: Working with WORDS for Stories
    
    var wordsPool = Array<Word>()
    
    // 4 Loading words - while fetching stories
    func loadWords() {
        print("loadWords() is invoked")
        let wordsRef = Database.database().reference().child("words")
        wordsRef.keepSynced(true)
        if self.storiesAddedSource.count != 0 {
        let x = Array(0...(self.storiesAddedSource.count - 1))
        for item in x {
            for word in self.storiesAddedSource[item].words {
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
            self.fetchWords(item)
        }
             }
        }
    
    func getLastDateForStoryInstance(_ item: Int) {
        let storyId = self.storiesAddedSource[item].id
        let lastDateRef = Database.database().reference().child("users/\(self.user.id!)/stories/\(storyId)/lastDate")
        lastDateRef.keepSynced(true)
        lastDateRef.observeSingleEvent(of: .value, with: { snapshot in
            print(String(describing: snapshot.value))
            if let lastDate = snapshot.value as? String {
                self.storiesAddedSource[item].lastDate = lastDate
                print("last Date for Story  is  " + lastDate) }
            else { print("No last dates for story \(self.storiesAddedSource[item].title)")}
        })
    }
    
    
    // 5
    
    func fetchWords(_ item: Int) {
        var wordsNumbersForStory = Array<String>()
        var usedWords = Array<String>()
        var wordsPoolForStory = Array<Word>()
        print("fetchWords() is invoked")
            print(" attempt No. \(item)")
            wordsNumbersForStory = self.storiesAddedSource[item].words
            let storyId = self.storiesAddedSource[item].id
            print("fetchWords() - wordsNumbersForStory.count for story \(self.storiesAddedSource[item].title) is " + String(wordsNumbersForStory.count))
        let wordsRef = Database.database().reference().child("users/\(self.user.id!)/stories/\(storyId)/wordUsed/")
        wordsRef.keepSynced(true)
        wordsRef.observeSingleEvent(of: .value, with: { snapshot in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshots
                {
                let usedWord = snap.value as! String
                    print("used word No. for story \(self.storiesAddedSource[item].title) is" + usedWord)
                    usedWords.append(usedWord) }
                wordsNumbersForStory = wordsNumbersForStory.filter { !usedWords.contains($0) }
                print("fetchWords() - self.usedWords.count for story \(self.storiesAddedSource[item].title) is " + String(usedWords.count))
                print("fetchWords() - self.wordsNumbersForStory.count for story \(self.storiesAddedSource[item].title) is " + String(wordsNumbersForStory.count))
            }
            wordsPoolForStory = self.wordsPool.filter { wordsNumbersForStory.contains($0.id) }
            print("fetchWords() - self.wordsPoolForStory.count for story \(self.storiesAddedSource[item].title) is " + String(wordsPoolForStory.count))
            let pickedWords = wordsPoolForStory.shuffled.choose(self.user.wordsPerLevel!)
            print("fetchWords() - pickedWords.count for story \(self.storiesAddedSource[item].title) is " + String(pickedWords.count))
            self.storiesAddedSource[item].wordsObj = pickedWords
        })
        self.getLastDateForStoryInstance(item)
    }

    func fetchWordsAfterSubmission() {
        loadWords()
        getCurrentLevelsForStoriesAdded()
    }
    
    
    // - MARK: VC LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // setting up views
        
        // Authorization
        Auth.auth().signInAnonymously() { (user, error) in
        }
        if let user = Auth.auth().currentUser {
            print("User ID is \(user.uid)")
            self.user.id = user.uid
            self.user.wordsPerLevel = 3
        }
        
        Database.database().isPersistenceEnabled = true
        
        // Registering nib for CollectionView
        let nib = UINib(nibName: "MainCollectionViewCell", bundle: nil)
        collectionViewUp.register(nib, forCellWithReuseIdentifier: "MainCollectionViewCell")
        collectionViewDown.register(nib, forCellWithReuseIdentifier: "MainCollectionViewCell")
        
        
        // Retrieving
        self.emptyUp.layer.cornerRadius = 10.0
        self.emptyDown.layer.cornerRadius = 10.0
        retrievingAllStories()
        setTimer()
        
    }
}
