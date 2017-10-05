//
//  Story.swift
//  mnemmal
//
//  Created by Danil on 06/09/2017.
//  Copyright © 2017 Danil Chernyshev. All rights reserved.
//

import Foundation

class Story {
    var isActive: Bool = false
    var title: String = ""
    var daysAmount: Int = 0
    var id: String = ""
    var genre: String = ""
    var words: Array<String> = [String]()
    var subtext: String = ""
    var premium: Bool = false
    var titleColor: String = ""
    var wordsColor: String = ""
    var image: String = ""
    var hidden: Bool = false
    var storyLevel = "1"
    var wordsObj: Array<Word>?
    var lastDate: String?
    
    init(isActive: Bool, title: String, daysAmount: Int, id: String, genre: String, words: Array<String>, subtext: String, premium: Bool, titleColor: String, wordsColor: String, image: String, hidden: Bool) {
        self.isActive = isActive
        self.title = title
        self.daysAmount = daysAmount
        self.id = id
        self.genre = genre
        self.words = words
        self.subtext = subtext
        self.premium = premium
        self.titleColor = titleColor
        self.wordsColor = wordsColor
        self.image = image
        self.hidden = hidden
    }
    
}
