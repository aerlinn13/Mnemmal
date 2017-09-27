//
//  MainVC.swift
//  Mnemmal
//
//  Created by Danil on 06/09/2017.
//  Copyright © 2017 Danil Chernyshev. All rights reserved.
//

import UIKit
import Firebase

class MainVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // - MARK: Variables
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet weak var collectionViewUp: UICollectionView!
    
    @IBOutlet weak var collectionViewDown: UICollectionView!
    
    @IBOutlet weak var noStoriesLabel: UILabel!
    
    @IBOutlet weak var noStoriesInUp: UITextView!
    
    var ref: DatabaseReference!
    
    var storiesForCollectionView = Array<Story>()
    
    var storiesAddedSource = Array<Story>()
    
    var user = User()
    
    // - MARK: CollectionView methods
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0
        if collectionView == collectionViewUp {
            count = storiesForCollectionView.count }
        else { count = storiesAddedSource.count }
        return count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainCollectionViewCell", for: indexPath) as! MainCollectionViewCell
        cell.scrollingImage.layer.cornerRadius = 10.0
        if collectionView == collectionViewUp {
        cell.storyLabel.text = storiesForCollectionView[indexPath.row].title
        let textColor = UIColor(hexString: "\(storiesForCollectionView[indexPath.row].titleColor)")
        cell.storyLabel.textColor = textColor
        cell.storySubheader.text = String(storiesForCollectionView[indexPath.row].genre) + ", " + String(storiesForCollectionView[indexPath.row].daysAmount) + " days"
        cell.storySubheader.textColor = textColor
        cell.storySubheader.isHidden = storiesForCollectionView[indexPath.row].hidden
        cell.scrollingImage.image = UIImage(named: "\(storiesForCollectionView[indexPath.row].image)")
        cell.getButton.isHidden = true
        cell.getButton.addTarget(self, action: #selector(getStory), for: .touchUpInside)
        }
        else {
            cell.storyLabel.text = storiesAddedSource[indexPath.row].title
            let textColor = UIColor(hexString: "\(storiesAddedSource[indexPath.row].titleColor)")
            cell.storyLabel.textColor = textColor
            cell.storySubheader.text = String(storiesAddedSource[indexPath.row].daysAmount) + " days"
            cell.storySubheader.textColor = textColor
            cell.scrollingImage.image = UIImage(named: "\(storiesAddedSource[indexPath.row].image)")
            cell.storySubheader.text = String(storiesAddedSource[indexPath.row].genre) + ", day " + storiesAddedSource[indexPath.row].currentDayForStory
            cell.getButton.isHidden = true
            }
        return cell
    }
    
   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: collectionView.frame.width - 20, height: 140)
            return size
    }
    
    var storyToPass: Story?
    
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
        } else {
            self.storyToPass = self.storiesAddedSource[indexPath.row]
            self.wordsForStory = fetchWords(indexPath)
            performSegue(withIdentifier: "submit", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "submit" {
            let nextScene =  segue.destination as! SubmissionVC
            if let wordsPool = self.wordsForStory { nextScene.wordsPool = wordsPool }
            if let story = self.storyToPass { nextScene.story = story }
            nextScene.user = self.user
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == collectionViewUp {
            var currentCellOffset = self.collectionViewUp.contentOffset
            currentCellOffset.x += self.collectionViewUp.frame.width / 2
            if let indexPath = self.collectionViewUp.indexPathForItem(at: currentCellOffset) {
                self.collectionViewUp.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }
        }
    }
    
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
    
    // - MARK: STORIES
    
    func retrievingAllStories() {
        print("retrieveAllStories()")
        let storiesRef = Database.database().reference().child("stories")
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
                        // let daysRef = Database.database().reference().child("users/\(String(describing: self.user.id))/stories/")
                    let curtDay = "1"
                    /* daysRef.observeSingleEvent(of: .value, with: { snapshot in
                    if let crtDay = snapshot.childSnapshot(forPath: "\(id)").value as? String
                            {
                                print(String(describing: snapshot.childSnapshot(forPath: "\(id)").key))
                                curtDay = crtDay
                                print("crtDay is " + crtDay)
                            } else {
                                print("no value for this story in users account")
                            }
                        }) */
                    let words = snap.childSnapshot(forPath: "words").childSnapshot(forPath: "\(curtDay)").value as! Array<String>
                    print("Words for that story are " + String(describing: words))
                    let image = snap.childSnapshot(forPath: "image").value! as! String
                    let subtext = snap.childSnapshot(forPath: "subtext").value! as! String
                    let titleColor = snap.childSnapshot(forPath: "titleColor").value as! String
                    let premium = snap.childSnapshot(forPath: "premium").value as! Bool
                        let story = Story(isActive: isActive, title: title, daysAmount: daysAmount, id: id, genre: genre, currentDayForStory: curtDay, words: words, subtext: subtext, premium: premium, titleColor: titleColor, wordsColor: "grey", image: image, hidden: false)
                self.storiesForCollectionView.append(story) } else { print("story is inactive") }
                    
                    print("Amount of stories in upper CollectionView is " + String(self.storiesForCollectionView.count))
                }
            }
            self.retrievingUserStories()
        })
    }
    
    func retrievingUserStories() {
        print("retrieveUserStories()")
        self.user.storiesActive = []
        let usersRef = Database.database().reference().child("users").child("\(self.user.id!)").child("storyRefs")
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
    
    func fetchStories() {
        print("fetchStories()")
        self.storiesAddedSource = self.storiesForCollectionView.filter { self.user.storiesActive!.contains($0.id) }
        print("Stories in array to fetch counting " + String(self.storiesAddedSource.count))
        self.storiesForCollectionView = self.storiesForCollectionView.filter { !self.user.storiesActive!.contains($0.id) }
        if self.storiesAddedSource.count != 0 {
        let x = Array(0...(self.storiesAddedSource.count - 1))
        print("AddedSource is " + String(describing: x))
        for item in x {
            loadWords(IndexPath(row: item, section: 0))
            print("iteration number is " + String(item))
        }
            }
        print("Stories for collectionViewDown is " + String(self.storiesAddedSource.count))
        print("Stories for collectionViewUp is " + String(self.storiesForCollectionView.count))
        self.collectionViewUp.reloadData()
        self.collectionViewDown.reloadData()
        checkForLabelsVisibility()
    }
    
    func getIndexForVisibleCell(_ collectionView: UICollectionView) -> IndexPath {
        var visibility: IndexPath?
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        if let indexPath = collectionView.indexPathForItem(at: visiblePoint)
        { visibility = indexPath }
        print(visibility ?? "nil")
        return visibility!
    }
    
    @objc func getStory() {
        let visibility = self.getIndexForVisibleCell(collectionViewUp)
        self.storiesAddedSource.insert(self.storiesForCollectionView[visibility.item], at: 0)
        let storyRefToUpdateUserAccount = self.storiesForCollectionView[visibility.item].id
        self.user.storiesActive!.append(storyRefToUpdateUserAccount)
        self.collectionViewDown.insertItems(at: [IndexPath(item: 0, section: 0)])
        self.storiesForCollectionView.remove(at: visibility.item)
        self.collectionViewUp.deleteItems(at: [visibility])
        checkForLabelsVisibility()
        setCurrentDayForStory(storyRefToUpdateUserAccount)
        DispatchQueue.main.async {
            self.loadWords(visibility)
        }
    }
    
    func checkForLabelsVisibility() {
        if self.storiesAddedSource.count == 0 {
            self.noStoriesLabel.isHidden = false
        } else { self.noStoriesLabel.isHidden = true }
        if self.storiesForCollectionView.count == 0 {
            self.noStoriesInUp.isHidden = false
            self.timer.invalidate()
        }
    }
    
    func setCurrentDayForStory(_ source: String) {
        let daysRef = Database.database().reference().child("users/\(self.user.id!)/storyRefs/\(source)/")
        daysRef.setValue("1")
        print("Day for the story has been set to 1")
    }
    
    // - MARK: Working with WORDS for Stories
    
    var wordsPool = Array<Word>()
    
    func loadWords(_ indexPath: IndexPath) {
        print("loadWords()")
        let wordsRef = Database.database().reference().child("words")
        let unit = self.storiesAddedSource[indexPath.row]
        wordsRef.observe(.value, with: { snapshot in
                    for word in unit.words {
                    let definition = snapshot.childSnapshot(forPath: "/\(word)/definition").value as! String
                    let example0 = snapshot.childSnapshot(forPath: "/\(word)/example0").value as! String
                    let example1 = snapshot.childSnapshot(forPath: "/\(word)/example1").value as! String
                    let id = snapshot.childSnapshot(forPath: "/\(word)/id").value as! String
                    let title = snapshot.childSnapshot(forPath: "/\(word)/title").value as! String
                    print("Title of the word is " + title)
                    let type = snapshot.childSnapshot(forPath: "/\(word)/type").value as! String
                    let wordInit = Word(id: id, title: title, definition: definition, type: type, example0: example0, example1: example1)
                    if let _ = self.wordsPool.first(where: {$0.title == title}) {
                        print("word is already in the array")
                    } else {
                        self.wordsPool.append(wordInit)
                        print("WordsPool count is " + String(self.wordsPool.count))
                    }
                }
        })
    }
    
    var wordsForStory: Array<Word>?

    func fetchWords(_ indexPath: IndexPath) -> Array<Word> {
        let wordsNumbersForStory = self.storiesAddedSource[indexPath.row].words
        print("Words amount that story contains is " + String(wordsNumbersForStory.count))
        let wordsPoolForStory = self.wordsPool.filter { wordsNumbersForStory.contains($0.id) }
        print("Words for the Story to  transfer to Submission VC is " + String(wordsPoolForStory.count))
        return wordsPoolForStory
    }
    
    // - MARK: VC LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // setting up views
        self.noStoriesInUp.isHidden = true
        
        // Authorization
        Auth.auth().signInAnonymously() { (user, error) in
        }
        if let user = Auth.auth().currentUser {
            print("User ID is \(user.uid)")
            self.user.id = user.uid
        }
        // Enabling persistent container for Database
        Database.database().isPersistenceEnabled = true

        // Loading stories from server
        retrievingAllStories()
        
        // Registering nib for CollectionView
        let nib = UINib(nibName: "MainCollectionViewCell", bundle: nil)
        collectionViewUp.register(nib, forCellWithReuseIdentifier: "MainCollectionViewCell")
        collectionViewDown.register(nib, forCellWithReuseIdentifier: "MainCollectionViewCell")
    }
    }
