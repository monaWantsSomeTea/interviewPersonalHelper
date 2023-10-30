//
//  UserResponseEditor.swift
//  InterviewHelperPOC
//
//  Created by Mona Zheng on 9/11/23.
//

import SwiftUI

struct UserResponseEditor: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var inputResponse: String
    
    @Binding var question: Item
    @Binding var response: String
    
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
            SaveOrCancelResponseHeader(inputResponse: self.$inputResponse, question: self.$question, response: self.$response)
                .environment(\.managedObjectContext, viewContext)
        }
        .padding()
        .navigationTitle("Edit Response")
    }
    
    init(question: Binding<Item>, response: Binding<String>) {
        self._question = question
        self._response = response
        self._inputResponse = State(initialValue: response.wrappedValue)
    }
}

struct UserResponseEditor_Previews: PreviewProvider {
    static var previews: some View {
        UserResponseEditor(question:
            Binding(
                get: {
                    TopInterviewQuestions().questions[0]
                },
                set: { newValue in
                    // Handle the case where you want to update the selected question
//                    newValue
                }
            ), response: .constant("Add some stuff here first")
        )
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
