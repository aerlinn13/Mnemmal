//
//  SubmissionContentTableViewCell.swift
//  mnemmal
//
//  Created by Danil on 30/10/2017.
//  Copyright © 2017 Danil Chernyshev. All rights reserved.
//

import UIKit
import Firebase

class SubmissionContentTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var wordsPool = Array<Word>()
    var delegate: WordCollectionDelegate!
    let submitButton: UIButton = UIButton(type: .custom)
    var collectionView: UICollectionView!

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var textView: MyTextView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var myView: UIView!
    
    
    
    // CollectionView methods
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wordsPool.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WordCollectionViewCell", for: indexPath) as! WordCollectionViewCell
        cell.title.text = wordsPool[indexPath.row].title
        cell.title.heroID = "title"
        cell.shortDef.text = "| " + wordsPool[indexPath.row].definition
        cell.shortDef.heroID = "def"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: collectionView.frame.width - 20, height: 40)
        return size
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        textView.resignFirstResponder()
        stopTimer()
        delegate.performWordOutlook(indexPath: indexPath)
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var currentCellOffset = self.collectionView.contentOffset
        currentCellOffset.x += self.collectionView.frame.width / 3
        if let indexPath = self.collectionView.indexPathForItem(at: currentCellOffset) {
        self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    var timer = Timer()
    func setTimer() {
        if self.wordsPool.count != 0 {
            self.timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.autoScroll), userInfo: nil, repeats: false)
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
    
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // instantiating collectionView
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 60)
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 60)
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = UIColor(red: 255/255.0, green: 236/255.0, blue: 180/255.0, alpha: 1)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        let nib = UINib(nibName: "WordCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "WordCollectionViewCell")
        collectionView.reloadData()
        
        // instantiating UIButton
        submitButton.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 60)
        submitButton.setTitle("Submit", for: .normal)
        submitButton.titleLabel!.font = UIFont.systemFont(ofSize: 22)
        submitButton.backgroundColor = UIColor(red: 112/255.0, green: 216/255.0, blue: 86/255.0, alpha: 1)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
