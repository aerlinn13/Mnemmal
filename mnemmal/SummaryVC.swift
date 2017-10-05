//
//  SummaryVC.swift
//  mnemmal
//
//  Created by Danil on 03/10/2017.
//  Copyright © 2017 Danil Chernyshev. All rights reserved.
//

import UIKit

class SummaryVC: UIViewController {

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func closeAct(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var dayNumber: UILabel!
    @IBOutlet weak var closeOutlet: UIButton!
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    
    var story: Story?
    var user: User?
    
    
    func configureHeader() {
        if let image = story?.image {
            bgImage.image = UIImage(named: image) }
        if let title = story?.title {
            headerLabel.text = title }
        if let dayNum = story?.storyLevel {
            dayNumber.text = "Day " + String(describing: dayNum)
        }
        if let color = story?.titleColor {
            headerLabel.textColor = UIColor(hexString: color)
            closeOutlet.setTitleColor(UIColor(hexString: color), for: .normal)
            dayNumber.textColor = UIColor(hexString: color)
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHeader()

        // Do any additional setup after loading the view.
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
