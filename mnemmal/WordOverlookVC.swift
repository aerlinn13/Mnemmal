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
    var delegate: WordDelegate?
    
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
    }
    
    @IBAction func insert(_ sender: Any) {
        didPress()
        self.cancel(self)
    }
    
    func didPress() {
        delegate?.didPressButton(string: titleLabel.text!)
        print("didPress")
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
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
