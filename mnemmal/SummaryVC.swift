//
//  SummaryVC.swift
//  mnemmal
//
//  Created by Danil on 03/10/2017.
//  Copyright © 2017 Danil Chernyshev. All rights reserved.
//

import UIKit


class SummaryVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    
    // - MARK: IB variables

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func closeAct(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var deleteStoryOutlet: UIButton!
    @IBAction func deleteStory(_ sender: Any) {
        delegate.removeStory(indexPath: self.storyIndexPath!, storyId: self.story!.id)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var closeOutlet: UIButton!
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // - MARK:  Variables
    
    var story: Story?
    var user: User?
    var delegate: StoryRemovalDelegate!
    var storyIndexPath: IndexPath?
    
    // - MARK: CollectionView methods
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
     let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SummaryCollectionViewCell", for: indexPath) as! SummaryCollectionViewCell
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }


    
    func configureHeader() {
        if let image = story?.id {
            bgImage.image = story?.image }
        if let title = story?.title {
            headerLabel.text = title }
        if let color = story?.titleColor {
            headerLabel.textColor = UIColor(hexString: color)
            closeOutlet.setTitleColor(UIColor(hexString: color), for: .normal)
        }
        deleteStoryOutlet.layer.cornerRadius = 10.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHeader()
        let nib = UINib(nibName: "SummaryCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "SummaryCollectionViewCell")
    }
}
