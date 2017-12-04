//
//  WordOverlookVC.swift
//  mnemmal
//
//  Created by Danil on 26/09/2017.
//  Copyright © 2017 Danil Chernyshev. All rights reserved.
//

import Foundation
import UIKit

class SummaryWordOverlookVC: UIViewController {
    
    var word: Word?
    
    @IBOutlet weak var yellowView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var def: UITextView!
    @IBOutlet weak var examples: UITextView!
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    @IBOutlet weak var insertOutlet: UIButton!
    
    
    @IBAction func insert(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        print("SummaryWordOverlookVC: dismissed.")
    }
    
    func setUpVC() {
        titleLabel.text = word?.title
        def.text = word?.definition
        examples.text = self.word!.example0 + " \n" + self.word!.example1
        insertOutlet.layer.cornerRadius = 10.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpVC()
    }
}

