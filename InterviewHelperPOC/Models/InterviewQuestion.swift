//
//  InterviewQuestions.swift
//  InterviewHelperPOC
//
//  Created by Mona Zheng on 9/9/23.
//

import Foundation

struct InterviewQuestion: Codable, Identifiable {
    let id: Int // could use UUID instead
    let details: String
    
    enum CodeKeys: Swift.CodingKey {
        case id
        case question
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodeKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.details = try container.decode(String.self, forKey: .question)
    }
    
}
