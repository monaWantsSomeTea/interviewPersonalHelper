//
//  UserResponseEditorView.swift
//  InterviewHelperPOC
//
//  Created by Mona Zheng on 9/11/23.
//

import SwiftUI

private let kResponseTextInputViewShadowRadius: CGFloat = 2
private let kPaddingBetweenResponseInputAndActionsView: CGFloat = 20

struct UserResponseEditorView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var inputResponse: String
    @Binding var question: PromptItemViewModel
    @FocusState var focused: Bool
    
    var body: some View {
        VStack {
            Text(self.question.prompt)
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding()
            
            Divider()
            
            TextEditor(text: self.$inputResponse)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .focused(self.$focused)
            
            Spacer(minLength: kPaddingBetweenResponseInputAndActionsView)
            
            SaveOrCancelResponseHeaderView(inputResponse: self.$inputResponse,
                                           textFieldFocused: self._focused,
                                           question: self.$question)
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
