//
//  InterviewQuestions.swift
//  InterviewHelperPOC
//
//  Created by Mona Zheng on 9/9/23.
//

import Foundation
import CoreData

class TopInterviewQuestions {
    private(set) var topInterviewQuestions: [TopInterviewQuestion] = []
    
    let viewContext = PersistenceController.shared.container.viewContext
    
    private func setQuestions() -> [TopInterviewQuestion] {
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
    
    func asPromptItems() -> [PromptItem] {
        return self.topInterviewQuestions.map { question in
            let promptItem = PromptItem(context: self.viewContext)

            promptItem.identifier = UUID()
            promptItem.originialCategory = "top-interview-question"
            promptItem.originalId = String(question.id)
            promptItem.prompt = question.prompt
            promptItem.response = nil
            
            
            return promptItem
        }
    }
    
    init() {
        self.topInterviewQuestions = self.setQuestions()
    }
}
