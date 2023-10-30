//
//  InterviewQuestions.swift
//  InterviewHelperPOC
//
//  Created by Mona Zheng on 9/9/23.
//

import Foundation

protocol Item {
    var prompt: String { get set }
}

struct TopInterviewQuestion: Decodable, Identifiable, Item {
    let id: Int
    var prompt: String
    
    enum CodeKeys: Swift.CodingKey {
        case id
        case question
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodeKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.prompt = try container.decode(String.self, forKey: .question)
    }
}
