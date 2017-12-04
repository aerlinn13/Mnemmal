//
//  Protocols.swift
//  mnemmal
//
//  Created by Danil on 26/09/2017.
//  Copyright © 2017 Danil Chernyshev. All rights reserved.
//

import UIKit

protocol WordDelegate {
    func cancel()
    func didPressButton(string:String)
}

protocol FetchWordsAfterSubmissionDelegate {
    func fetchWordsAfterSubmission(storyLevel: String, completedStatus: Bool, indexPath: IndexPath, isNews: Bool)
    func loadSummariesForStoriesDown()
    func addSummaryForStory(summary: DailySummary)
    func updateStoryTrack(track: String, storyId: String)
    func getStory(initialStoryTrack: String, fromSubmission: Bool)
}

protocol StoryRemovalDelegate {
    func removeStory(indexPath: IndexPath, storyId: String)
}

protocol UserUpdatedDelegate {
    func updateUserObject(user: User)
}

protocol GetStoryDelegate {
    func getStory(initialStoryTrack: String, fromSubmission: Bool)
    var user: User { get set }
}

protocol WordCollectionDelegate {
    func performWordOutlook(indexPath: IndexPath)
    func performWordOutlook(word: Word)
}

protocol  CommentsDelegate {
    func updateMnemmalComments()
}

protocol MnemmalOverlookDelegate {
    func perform(mnemmal: Mnemmal)
}

protocol  ShareDelegate {
    func shareContent(content: String)
}
