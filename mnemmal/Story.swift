//
//  Story.swift
//  mnemmal
//
//  Created by Danil on 06/09/2017.
//  Copyright © 2017 Danil Chernyshev. All rights reserved.
//

import Foundation
import UIKit

class Story {
    var isActive: Bool = false
    var title: String = ""
    var daysAmount: Int = 0
    var id: String = ""
    var genre: String = ""
    var words: Array<String> = [String]()
    var subtext: String = ""
    var epigraph: String = ""
    var premium: Bool = false
    var titleColor: String = ""
    var wordsColor: String = ""
    var hidden: Bool = false
    var storyLevel = "1"
    var image = UIImage()
    var wordsObj: Array<Word>?
    var lastDate: String?
    var newDay: Bool = true
    var coding: String?
    var days: Dictionary<String, Day> = [String: Day]()
    var completed: Bool = false
    var firstParty: String?
    var secondParty: String?
    var summaries: Dictionary<String,DailySummary> = [String: DailySummary]()
    
    init(isActive: Bool, title: String, daysAmount: Int, id: String, genre: String, words: Array<String>, subtext: String, epigraph: String, premium: Bool, titleColor: String, wordsColor: String, hidden: Bool, firstParty: String, secondParty: String) {
        self.isActive = isActive
        self.title = title
        self.daysAmount = daysAmount
        self.id = id
        self.genre = genre
        self.words = words
        self.subtext = subtext
        self.epigraph = epigraph
        self.premium = premium
        self.titleColor = titleColor
        self.wordsColor = wordsColor
        self.hidden = hidden
        self.firstParty = firstParty
        self.secondParty = secondParty
    }
}
