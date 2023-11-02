//
//  InterviewQuestions.swift
//  InterviewHelperPOC
//
//  Created by Mona Zheng on 9/9/23.
//

import Foundation

protocol GenericPromptItem {
    /// Prompt that the user would respond to.
    var prompt: String { get set }
    /// The response that the user inputted.
    var response: String? { get set }
}

struct TopInterviewQuestion: Decodable, Identifiable, GenericPromptItem {
    /// Unique id of the item from this list of questions.
    let id: Int
    /// Prompt that the user would respond to.
    var prompt: String
    /// The response that the user inputted.
    var response: String?
    
    enum CodeKeys: Swift.CodingKey {
        case id
        case question
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodeKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.prompt = try container.decode(String.self, forKey: .question)
        
        self.response = nil
    }
}
