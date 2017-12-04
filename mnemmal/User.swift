//
//  User.swift
//  mnemmal
//
//  Created by Danil on 06/09/2017.
//  Copyright © 2017 Danil Chernyshev. All rights reserved.
//

import Foundation
import UIKit

struct User {
    var id: String?
    var fbId = "none"
    var fbPicURL: String?
    var name: String?
    var email: String?
    var storiesActive: Array<String>?
    var premium = false
    var premiumExpires: Date?
    var onboardingDone: Bool?
    var wordsPerLevel: Int?
    var picture: UIImage?
    var storyTrack = [String: String]()
    var likedMnemmals = [String: [String]]()
}
