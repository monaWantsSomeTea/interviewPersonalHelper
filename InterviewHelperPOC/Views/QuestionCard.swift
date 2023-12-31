//
//  QuestionCard.swift
//  InterviewHelperPOC
//
//  Created by Mona Zheng on 9/11/23.
//

import SwiftUI

private let kQuestionCardCornerRadius: CGFloat = 12
private let kQuestionCardShadowRadius: CGFloat = 2
private let kQuestionCardMinWidth: CGFloat = 300
private let kQuestionCardMinHeight: CGFloat = 150

struct QuestionCard: View {
    var question: PromptItemViewModel
    var body: some View {
            RoundedRectangle(cornerRadius: kQuestionCardCornerRadius)
            .foregroundColor(Color(.systemBackground))
                .shadow(color: .brown, radius: kQuestionCardShadowRadius)
                .frame(minWidth: kQuestionCardMinWidth)
                .frame(minHeight: kQuestionCardMinHeight)
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
