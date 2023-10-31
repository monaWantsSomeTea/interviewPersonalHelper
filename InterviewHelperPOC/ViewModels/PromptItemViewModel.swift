//
//  PromptItemViewModel.swift
//  InterviewHelperPOC
//
//  Created by Mona Zheng on 10/30/23.
//

import Foundation

class PromptItemViewModel {
    ///
    var model: Item
    /// Id of the item that was assigned from the downloaded content
    var originalId: String?
    /// The original category the item was from, ex: "top-interview-questions"
    var originialCategory: String?
    /// Identifier used to store and retrieve the item
    var identifier: UUID?
    /// The prompt for the user to respond to.
    var prompt: String
    /// The response that the user inputted.
    var response: String?
    
    init(model: Item) {
        self.model = model
        
        self.prompt = model.prompt
        self.response = model.response
        
        switch model {
        case let promptItem as PromptItem:
            self.originalId = promptItem.originalId
            self.originialCategory = promptItem.originialCategory
            self.identifier = promptItem.identifier
        case let topInterviewQuestion as TopInterviewQuestion:
            self.originalId = String(topInterviewQuestion.id)
            self.originialCategory = "top-interview-question"
            self.identifier = nil
        default:
            fatalError("Unsupported type")
        }
    }
}
