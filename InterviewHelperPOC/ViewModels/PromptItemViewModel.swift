//
//  PromptItemViewModel.swift
//  InterviewHelperPOC
//
//  Created by Mona Zheng on 10/30/23.
//

import Foundation

class PromptItemViewModel {
    /// Protocol for prompt item models
    var model: GenericPromptItem
    /// Id of the item that was assigned from the downloaded content
    var originalId: String?
    /// The original category the item was from, ex: "top-interview-questions"
    var originialCategory: String?
    /// Identifier used to store and retrieve the item
    var identifier: UUID?
    /// The prompt for the user to respond to.
    var prompt: String
    /// The response that the user inputted.
    var response: String
    
    init(model: GenericPromptItem) {
        self.model = model
        
        self.prompt = model.prompt
        
        if let response = model.response, !response.isEmpty {
            self.response = response
        } else {
            self.response = "Add your answer, notes or bullet points"
        }
        
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
