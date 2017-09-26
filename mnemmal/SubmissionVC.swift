//
//  SubmissionVC.swift
//  mnemmal
//
//  Created by Danil on 17/09/2017.
//  Copyright © 2017 Danil Chernyshev. All rights reserved.
//

import Foundation
import UIKit

class SubmissionVC: UIViewController,
 UITextViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // - MARK: Variables
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var closeOutlet: UIButton!
    @IBOutlet weak var dayNumber: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var wordsPool = Array<Word>()
    var story: Story?

    // - MARK: CollectionView methods
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wordsPool.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WordCollectionViewCell", for: indexPath) as! WordCollectionViewCell
        cell.title.text = wordsPool[indexPath.row].title
        cell.shortDef.text = wordsPool[indexPath.row].definition
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: collectionView.frame.width - 20, height: 40)
        return size
    }
    
    var wordToPass: Word?
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.wordToPass = self.wordsPool[indexPath.row]
      performSegue(withIdentifier: "wordOverlook", sender: self)
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
        if self.wordsPool.count != 0 {
            self.timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(SubmissionVC.autoScroll), userInfo: nil, repeats: true)
        }
    }
    
    @objc func stopTimer() {
        self.timer.invalidate()
    }
    
    var x = 1
    @objc func autoScroll() {
        if self.x < self.wordsPool.count {
            let indexPath = IndexPath(item: x, section: 0)
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            self.x = self.x + 1
        } else {
            self.x = 0
            self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "wordOverlook" {
            let nextScene =  segue.destination as! WordOverlookVC
            if let word = self.wordToPass { nextScene.word = word }
        }
    }
    
    func configureHeader() {
        if let image = story?.image {
            bgImage.image = UIImage(named: image) }
        if let title = story?.title {
            headerLabel.text = title }
        if let dayNum = story?.currentDayForStory {
            dayNumber.text = "Day " + dayNum
        }
        if let color = story?.titleColor {
            headerLabel.textColor = UIColor(hexString: color)
        closeOutlet.setTitleColor(UIColor(hexString: color), for: .normal)
        dayNumber.textColor = UIColor(hexString: color)
        }
        }
    
    func registerNibs() {
        let nib0 = UINib(nibName: "SubtextCollectionViewCell", bundle: nil)
        let nib1 = UINib(nibName: "WordCollectionViewCell", bundle: nil)
        collectionView.register(nib0, forCellWithReuseIdentifier: "SubtextCollectionViewCell")
        collectionView.register(nib1, forCellWithReuseIdentifier: "WordCollectionViewCell")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerNibs()
        configureHeader()
        textView.delegate = self
        textView.becomeFirstResponder()
        setTimer()
        print("Amount of words trasferred is " + String(wordsPool.count))
        print("Story title is " + String(describing: story?.title))
    
}
}
