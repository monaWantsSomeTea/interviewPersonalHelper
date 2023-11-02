//
//  InterviewQuestions.swift
//  InterviewHelperPOC
//
//  Created by Mona Zheng on 9/9/23.
//

import Foundation

class TopInterviewQuestions {
    private(set) var questions: [PromptItemViewModel] = []
    
    private func makeQuestions() -> [TopInterviewQuestion] {
        guard let json = Bundle.main.url(forResource: "questions", withExtension: ".json") else {
            fatalError("Unable to load questions from json file.")
        }
        
        do {
            let jsonData = try Data(contentsOf: json)
            return try JSONDecoder().decode([TopInterviewQuestion].self, from: jsonData)
        } catch {
            fatalError("Unable to load or parse questions from json file from bundle")
        }
    }
    
    init() {
        self.questions = self.makeQuestions().map { PromptItemViewModel(model: $0) }
    }
}
