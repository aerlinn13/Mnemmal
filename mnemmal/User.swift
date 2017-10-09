//
//  User.swift
//  mnemmal
//
//  Created by Danil on 06/09/2017.
//  Copyright © 2017 Danil Chernyshev. All rights reserved.
//

import Foundation

struct User {
    var id: String?
    var storiesActive: Array<String>?
    var status = "basic"
    var premiumExpires: Date?
    var onboardingDone: Bool?
    var wordsPerLevel: Int?
}
