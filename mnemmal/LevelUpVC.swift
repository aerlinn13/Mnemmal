//
//  LevelUpVC.swift
//  mnemmal
//
//  Created by Danil on 27/09/2017.
//  Copyright © 2017 Danil Chernyshev. All rights reserved.
//

import UIKit
import FirebaseDatabase

class LevelUpVC: UIViewController {

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    var story: Story?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dayNumLabel: UILabel!
    @IBAction func completeButton(_ sender: Any) { self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var completeOutlet: UIButton!
    
    func setUpVC() {
        if let title = self.story?.title { self.titleLabel.text = title
        }
        if let dayNum = self.story?.currentDayForStory { self.dayNumLabel.text = "Day " + dayNum }
    completeOutlet.layer.cornerRadius = 10.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpVC()
    }
}
