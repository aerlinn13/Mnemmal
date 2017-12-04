//
//  DailySummary.swift
//  mnemmal
//
//  Created by Danil on 14/11/2017.
//  Copyright © 2017 Danil Chernyshev. All rights reserved.
//

import UIKit

class DailySummary: NSObject {
    let id: String?
    let storyTrack: String?
    let title: String?
    let opener: String?
    let mnemmalContent: String?
    let mnemmalDate: String?
    var wordsObj: Array<Word>?
    var comments = Array<MnemmalComment>()
    var commentsChecked = false
    var likesAmount = 0
    
    init(id: String, storyTrack: String, title: String, opener: String, mnemmalContent: String, mnemmalDate: String, wordsObj: Array<Word>) {
        self.id = id
        self.storyTrack = storyTrack
        self.title = title
        self.opener = opener
        self.mnemmalContent = mnemmalContent
        self.mnemmalDate = mnemmalDate
        self.wordsObj = wordsObj
    }
}

