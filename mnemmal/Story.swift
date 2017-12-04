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
    var subtitle: String = ""
    var daysAmount: Int = 0
    var id: String = ""
    var words: Array<String> = [String]()
    var subtext: String = ""
    var epigraph: String = ""
    var storyLevel = "1"
    var image = UIImage()
    var wordsObj: Array<Word>?
    var lastDate: String?
    var newDay: Bool = true
    var coding: String?
    var days: Dictionary<String, Day> = [String: Day]()
    var completed: Bool = false
    var firstParty: String?
    var summaries: Dictionary<String,DailySummary> = [String: DailySummary]()
    var checked = false
    let isNews: Bool
    let onStand: Bool
    
    init(isActive: Bool, title: String, subtitle: String, daysAmount: Int, id: String, words: Array<String>, subtext: String, epigraph: String, firstParty: String, isNews: Bool, onStand: Bool) {
        self.isActive = isActive
        self.title = title
        self.subtitle = subtitle
        self.daysAmount = daysAmount
        self.id = id
        self.words = words
        self.subtext = subtext
        self.epigraph = epigraph
        self.firstParty = firstParty
        self.isNews = isNews
        self.onStand = onStand
    }
}
