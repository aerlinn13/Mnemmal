//
//  Story.swift
//  mnemmal
//
//  Created by Danil on 06/09/2017.
//  Copyright © 2017 Danil Chernyshev. All rights reserved.
//

import Foundation

struct Story {
    var isActive: Bool
    var title: String
    var daysAmount: Int
    var id: String
    var genre: String
    var currentDayForStory: String
    var words: Array<String>
    var subtext: String
    var premium: Bool
    var titleColor: String
    var wordsColor: String
    var image: String
    var hidden: Bool
}
