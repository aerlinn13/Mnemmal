//
//  WordOverlookVC.swift
//  mnemmal
//
//  Created by Danil on 26/09/2017.
//  Copyright © 2017 Danil Chernyshev. All rights reserved.
//

import UIKit

class WordOverlookVC: UIViewController {
    
    var word: Word?
    var delegate: WordDelegate!
    
    @IBOutlet weak var yellowView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var def: UITextView!
    @IBOutlet weak var examples: UITextView!
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet weak var cancelOutlet: UIButton!
    @IBOutlet weak var insertOutlet: UIButton!
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        delegate.cancel()
        print("wordOverlookVC: screen is dismissed.")
    }
    
    @IBAction func insert(_ sender: Any) {
        delegate.didPressButton(string: titleLabel.text!)
        self.cancel(self)
        print("wordOverlookVC: word is inserted.")
    }
    
    
    func setUpVC() {
        titleLabel.text = word?.title
        def.text = word?.definition
        examples.text = self.word!.example0 + " \n" + self.word!.example1
        cancelOutlet.layer.cornerRadius = 10.0
        insertOutlet.layer.cornerRadius = 10.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpVC()

        // HERO
        yellowView.heroID = "yellow"
        titleLabel.heroID = "title"
        def.heroID = "def"
    }
}
