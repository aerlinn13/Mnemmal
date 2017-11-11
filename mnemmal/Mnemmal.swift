//
//  StoryInstance.swift
//  mnemmal
//
//  Created by Danil on 06/09/2017.
//  Copyright © 2017 Danil Chernyshev. All rights reserved.
//

import Foundation

class Mnemmal {
    let id: String
    let userId: String
    let fbId: String
    let userName: String
    let storyId:String
    let storyTrack: String
    let time: String
    var likesAmount: String
    let content: String
    var comments = Array<MnemmalComment>()
    var liked: Bool
    
    init(id: String, userId: String, fbId: String, userName: String, storyId: String, storyTrack: String, time: String, likesAmount: String, content: String, comments: Array<MnemmalComment>, liked: Bool ) {
        self.id = id
        self.userId = userId
        self.fbId = fbId
        self.userName = userName
        self.storyId = storyId
        self.storyTrack = storyTrack
        self.time = time
        self.likesAmount = likesAmount
        self.content = content
        self.comments = comments
        self.liked = liked
    }
}
