//
//  SideMenuVC.swift
//  mnemmal
//
//  Created by Danil on 07/10/2017.
//  Copyright © 2017 Danil Chernyshev. All rights reserved.
//

import UIKit
import CoreData
import SideMenu
import FacebookCore
import FacebookLogin
import Firebase
import FirebaseDatabase

class SideMenuVC: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var accountType: UILabel!
    @IBOutlet weak var expirationDate: UILabel!
    @IBOutlet weak var getPremiumButton: UIButton!
    @IBAction func getPremiumButtonAction(_ sender: Any) {
    }
    
    @IBOutlet weak var loginButton: UIButton!
    
    var user = User()
    
    @objc func loginButtonClicked() {
        let loginManager = LoginManager()
        loginManager.logIn([ .publicProfile, .email ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("SideMenu: Logged in!")
                let graphRequest: GraphRequest = GraphRequest(graphPath: "me", parameters: ["fields":"id, name, email, picture.type(large)"], accessToken: accessToken, httpMethod: .GET)
                graphRequest.start({ (response, result) in
                    switch result {
                    case .failed(let error):
                        print(error)
                    case .success(let result):
                        if let resultValue = result.dictionaryValue as Dictionary! {
                        if let name = resultValue["name"] as? String { self.user.name = name } else { print("fuck1") }
                        if let email = resultValue["email"] as? String { self.user.email = email } else { print("fuck2") }
                        if let id = resultValue["id"] as? String { self.user.fbId = id } else { print("fuck3") }
                            let pictureURL: String  = "https://graph.facebook.com/\(self.user.fbId!)/picture?type=large"
                            print(pictureURL)
                        self.user.fbPicURL = pictureURL
                        self.setUpAccountAfterLogin()
                        self.checkFBAccount()
                        self.firebaseLogin()
}
                    }
                })
            }
        }
    }
    
    func userUpdateNotification() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "UserObjectUpdated"), object: self)
        print("SideMenuVC: UserObjectUpdated notification is sent")
    }
    
    func firebaseLogin() {
        let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.authenticationToken)
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                // ...
                return
            }
            if let user = Auth.auth().currentUser {
                print("SideMenuVC: User ID is \(user.uid)")
                print("SideMenuVC: User is logged in Firebase with Facebook")
            self.user.id = user.uid
            self.user.wordsPerLevel = 3
            self.userUpdateNotification() }
        }
    }
    
    func firebaseLogout() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            print("SideMenuVC: User is logged out from Firebase with Facebook")
            self.userUpdateNotification()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        firebaseAuth.signInAnonymously() { (user, error) in
            if let error = error {
                // ...
                return
            }
            if let user = Auth.auth().currentUser {
                print("SideMenuVC: User ID is \(user.uid)")
                print("SideMenuVC: User is logged in Firebase Anonymously after logging out from Facebook")
                self.user.id = user.uid
                self.user.wordsPerLevel = 3
                self.userUpdateNotification() }
        }
    }
    
    func setUpAccountAfterLogin() {
        if let image = self.user.picture { profileImage.image = image }
        if let name = self.user.name { nameLabel.text = name }
        if let pictureURL = self.user.fbPicURL { self.profileImage.downloadedFrom(link: pictureURL) } else { print("fuck4") }
    }
    
     func logout() {
        let loginManager = LoginManager()
        loginManager.logOut()
        self.nameLabel.text = "Anonymous"
        self.loginButton.addTarget(self, action: #selector(self.loginButtonClicked), for: .touchUpInside)
        self.loginButton.setTitle("Login with Facebook", for: .normal)
        profileImage.image = UIImage(named: "Anon")
        self.loginButton.setTitleColor(UIColor.white, for: .normal)
        self.loginButton.layer.backgroundColor = UIColor(red: 59/255.0, green: 89/255.0, blue: 152/255.0, alpha: 1).cgColor
        self.firebaseLogout()
    }
    
    @objc func checkFBAccount() {
        self.loginButton.removeTarget(nil, action: nil, for: .allEvents)
        accountType.textColor = UIColor.lightGray
        expirationDate.textColor = UIColor.lightGray
        if let accessToken = AccessToken.current?.authenticationToken {
            if let name = UserProfile.current?.fullName { nameLabel.text = name }
            print("SideMenuVC: this is saved user profile name " + String(describing: UserProfile.current?.fullName))
            if let url = UserProfile.current?.imageURLWith(.square, size: CGSize(width: 250, height: 250)) {
                profileImage.downloadedFrom(link: String(describing: url)) } else { print("Pic not downloaded")}
            self.loginButton.setTitle("Logout", for: .normal)
            self.loginButton.setTitleColor(UIColor.red, for: .normal)
            nameLabel.textColor = UIColor.darkText
            self.loginButton.layer.backgroundColor = UIColor.groupTableViewBackground.cgColor
            self.loginButton.addTarget(self, action: #selector(self.logout), for: .touchUpInside)
        } else {
            self.nameLabel.text = "Anonymous"
            nameLabel.textColor = UIColor.lightGray
            profileImage.image = UIImage(named: "Anon")
            self.loginButton.setTitle("Login with Facebook", for: .normal)
            self.loginButton.setTitleColor(UIColor.white, for: .normal)
            self.loginButton.layer.backgroundColor = UIColor(red: 59/255.0, green: 89/255.0, blue: 152/255.0, alpha: 1).cgColor
            self.loginButton.addTarget(self, action: #selector(self.loginButtonClicked), for: .touchUpInside)
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.layer.masksToBounds = true
        profileImage.layer.borderWidth = 2.0
        profileImage.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        getPremiumButton.layer.cornerRadius = 10.0
        UserProfile.updatesOnAccessTokenChange = true
        checkFBAccount()
    }
}
