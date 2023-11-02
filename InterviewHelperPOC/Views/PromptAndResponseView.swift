//
//  QuestionView.swift
//  InterviewHelperPOC
//
//  Created by Mona Zheng on 9/11/23.
//

import SwiftUI

private let kViewBackgroundColor: Color = Color(red: 250/255, green: 240/255, blue: 230/255, opacity: 0.2)
private let kQuestionCardHeightPercentage: CGFloat = 0.35
private let kViewVerticalPadding: CGFloat = 32

struct PromptAndResponseView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var question: PromptItemViewModel
    
    var body: some View {
        self.content
            .background(kViewBackgroundColor)
    }
    
    var content: some View {
        GeometryReader { proxy in
            VStack {
                QuestionCard(question: self.question)
                    .padding()
                    .frame(height: proxy.size.height * kQuestionCardHeightPercentage)
                ResponseSectionView(question: self.$question)
                    .environment(\.managedObjectContext, viewContext)
                
            }
            .padding([.vertical], kViewVerticalPadding)
        }
    }
    
    init(question: Binding<PromptItemViewModel>) {
        self._question = question
    }
}

struct QuestionView_Previews: PreviewProvider {
    static var previews: some View {
        PromptAndResponseView(question:
            Binding(
                get: { TopInterviewQuestions().questions[0] },
                set: { _ in }
            )
        )
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
