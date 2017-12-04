//
//  SummaryDayWordsTableViewCell.swift
//  mnemmal
//
//  Created by Danil on 15/11/2017.
//  Copyright © 2017 Danil Chernyshev. All rights reserved.
//

import UIKit

class SummaryDayWordsTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    
    @IBOutlet weak var collectionView: UICollectionView!
    var words = Array<Word>()
    var delegate: WordCollectionDelegate!
    
    // CollectionView methods
    
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return words.count
    }
    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SummaryDayWordsUnitCollectionViewCell", for: indexPath) as! SummaryDayWordsUnitCollectionViewCell
        cell.baseView.layer.cornerRadius = 10.0
        cell.wordLabel.text = words[indexPath.row].title
        cell.definition.text = words[indexPath.row].definition
        cell.definitionBaseView.layer.cornerRadius = 10.0
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate.performWordOutlook(word: self.words[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.size.width - 20) / 3
        let height = CGFloat(90)
        return CGSize(width: width, height: height)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
        let nib = UINib(nibName: "SummaryDayWordsUnitCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "SummaryDayWordsUnitCollectionViewCell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
