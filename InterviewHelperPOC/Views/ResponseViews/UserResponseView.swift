//
//  UserResponseView.swift
//  InterviewHelperPOC
//
//  Created by Mona Zheng on 9/11/23.
//

import SwiftUI

private let kResponseInputViewShadowRadius: CGFloat = 2

struct UserResponseView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var question: PromptItemViewModel
    
    var body: some View {
        NavigationLink(
            destination: UserResponseEditorView(question: self.$question)
                .environment(\.managedObjectContext, viewContext)
        ) {
            TextEditor(text: self.$question.response)
                .shadow(color: .brown, radius: kResponseInputViewShadowRadius)
                .fontWeight(.semibold)
                .foregroundColor(Color(.darkGray))
                .multilineTextAlignment(.leading)
                .disabled(true)
        }
    }
    
    init(question: Binding<PromptItemViewModel>) {
        self._question = question
    }
}

struct UserResponseView_Previews: PreviewProvider {
    static var previews: some View {
        UserResponseView(question:
            Binding(
                get: { TopInterviewQuestions().questions[0] },
                set: { _ in }
            )
        )
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
