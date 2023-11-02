//
//  UserResponseEditorView.swift
//  InterviewHelperPOC
//
//  Created by Mona Zheng on 9/11/23.
//

import SwiftUI

struct UserResponseEditorView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var inputResponse: String
    @Binding var question: PromptItemViewModel
    
    var body: some View {
        VStack {
            Text(self.question.prompt)
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding()
            
            TextEditor(text: self.$inputResponse)
                .shadow(color: .brown, radius: 2)
                .fontWeight(.semibold)
                .foregroundColor(Color(.darkGray))
            
            Spacer(minLength: 20)
            
            SaveOrCancelResponseHeaderView(inputResponse: self.$inputResponse, question: self.$question)
                .environment(\.managedObjectContext, viewContext)
        }
        .padding()
        .navigationTitle("Edit Response")
    }
    
    init(question: Binding<PromptItemViewModel>) {
        self._question = question
        self._inputResponse = State(initialValue: question.response.wrappedValue)
    }
}

struct UserResponseEditorView_Previews: PreviewProvider {
    static var previews: some View {
        UserResponseEditorView(question:
            Binding(
                get: { TopInterviewQuestions().questions[0] },
                set: { _ in }
            )
        )
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
