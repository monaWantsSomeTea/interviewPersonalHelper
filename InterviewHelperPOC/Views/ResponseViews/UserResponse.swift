//
//  UserResponse.swift
//  InterviewHelperPOC
//
//  Created by Mona Zheng on 9/11/23.
//

import SwiftUI
import CoreData

struct UserResponse: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var response: String
    @Binding var question: Item
    
    var body: some View {
        NavigationLink(
            destination: UserResponseEditor(question: self.$question, response: self.$response)
                .environment(\.managedObjectContext, viewContext)
        ) {
            TextEditor(text: self.$response)
                .shadow(color: .brown, radius: 2)
                .fontWeight(.semibold)
                .foregroundColor(Color(.darkGray))
                .multilineTextAlignment(.leading)
                .disabled(true)
        }
        // TODO: This will not work. We want to change on response changes. question with type Item is a protocol and will not use Equatable . 
//        .onChange(of: self.question) { newQuestion in
//            if let promptItem = newQuestion.wrappedValue as? PromptItem {
//                self.response.wrappedValue = promptItem.response
//            }
//        }
    }
    
    init(question: Binding<Item>) {
        self._question = question
        self._response = State(initialValue: "Add your answer, notes or bullet points")
        
        if let promptItem = question.wrappedValue as? PromptItem {
            self._response.wrappedValue = promptItem.response
        }
    }
}

struct ResponseSection: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var question: Item
    
    var body: some View {
        UserResponse(question: self.$question)
            .environment(\.managedObjectContext, viewContext)
            .padding()
    }
}

struct UserResponse_Previews: PreviewProvider {
    static var previews: some View {
        ResponseSection(question:
            Binding(
                get: {
                    TopInterviewQuestions().questions[0]
                },
                set: { newValue in
                    // Handle the case where you want to update the selected question
//                    newValue
                }
            )
        )
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
