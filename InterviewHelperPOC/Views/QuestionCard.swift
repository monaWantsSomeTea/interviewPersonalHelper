//
//  QuestionCard.swift
//  InterviewHelperPOC
//
//  Created by Mona Zheng on 9/11/23.
//

import SwiftUI

struct QuestionCard: View {
    var question: Item
    var body: some View {
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(.white)
                .shadow(color: .brown, radius: 2)
                .frame(minWidth: 300)
                .frame(minHeight: 150)
                .overlay {
                    Text(self.question.prompt)
                        .padding()
                        .multilineTextAlignment(.center)
                    
                }
        }
}

struct QuestionCard_Previews: PreviewProvider {
    static var previews: some View {
        QuestionCard(question: TopInterviewQuestions().questions[0])
    }
}
