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
import PKHUD
import StoreKit

class SideMenuVC: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var goToFacebookButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    var user = User()
    var linkage: Bool?

    
    @objc func loginButtonClicked() {
        self.askUserToSaveProgressOnFBLogin() { linkage in
        let loginManager = LoginManager()
            loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: self) { loginResult in
            HUD.show(.progress)
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
                        if linkage {
                            self.firebaseLogin(link: true)
                        } else {
                            self.firebaseLogin(link: false)
                        }
                        }
                    })
                }
            }
        }
        }
    
    
    func askUserToSaveProgressOnFBLogin(completion: @escaping ((Bool) -> Void)) {
        let alert = UIAlertController(title: "Would you like to transfer your current progress under your Facebook account?", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { action in
            self.linkage = true
            completion(self.linkage!)
             }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: { action in
            self.linkage = false
            completion(self.linkage!)
            } ))
        self.present(alert, animated: true, completion: nil)
    }
    
    func userUpdateNotification() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "UserObjectUpdated"), object: self)
        print("SideMenuVC: UserObjectUpdated notification is sent.") }

    func firebaseLogin(link: Bool) {
        print("firebaseLogin(): invoked.")
        HUD.show(.progress)
        let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.authenticationToken)
        if link {
            if let user = Auth.auth().currentUser {
                    user.link(with: credential) { user, error in
                        if let error = error {
                        HUD.show(.labeledError(title: "", subtitle: "Account already in use"), onView: nil)
                        HUD.hide(afterDelay: 2)
                        AccessToken.current = nil
                        } else { self.userUpdateNotification()
                        print("SideMenuVC: User ID is \(user!.uid). Data linked to FB Account.")
                        self.checkFBAccount() }
                    }
                }
             } else {
            Auth.auth().signIn(with: credential) { (user, error) in
                if let error = error {
                    print(error)
                    return
                }
                if let user = Auth.auth().currentUser {
                    self.userUpdateNotification()
                    print("SideMenuVC: User ID is \(user.uid)")
                    self.checkFBAccount()
                }
                }
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
                print(error)
                return
            }
            if let user = Auth.auth().currentUser {
                print("SideMenuVC: User ID is \(user.uid)")
                print("SideMenuVC: User is logged in Firebase Anonymously after logging out from Facebook")
                self.userUpdateNotification()
                self.checkFBAccount()
            }
        }
    }
    
    @objc func logout() {
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
        if let accessToken = AccessToken.current?.authenticationToken {
            if let name = UserProfile.current?.fullName { nameLabel.text = name }
            print("SideMenuVC: this is saved user profile name " + String(describing: UserProfile.current?.fullName))
            if let url = UserProfile.current?.imageURLWith(.square, size: CGSize(width: 250, height: 250)) {
                self.profileImage.sd_setImage(with: url, placeholderImage: UIImage(named: "Anon"), options: .continueInBackground, completed: nil) } else { print("Pic not downloaded")}
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
    
    func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        let stringDate: String = formatter.string(from: date)
        print(stringDate)
        return stringDate
    }
    
    @objc func goToFBPage() {
        UIApplication.shared.openURL(URL(string: "https://fb.me/mnemmal")!)
    }
    
    @objc func openTermsOfUse() {
        UIApplication.shared.openURL(URL(string: "https://github.com/aerlinn13/mnemmal")!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.checkFBAccount()
        self.goToFacebookButton.addTarget(self, action: #selector(self.goToFBPage), for: .touchUpInside)
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.layer.masksToBounds = true
        profileImage.layer.borderWidth = 2.0
        profileImage.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        UserProfile.updatesOnAccessTokenChange = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tip = true
        UserDefaults.standard.set(tip, forKey: "tip")
    }
}
