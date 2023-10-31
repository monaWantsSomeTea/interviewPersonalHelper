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
    @State var currentResponse: String
    @Binding var question: PromptItemViewModel
    
    var body: some View {
        NavigationLink(
            destination: UserResponseEditor(question: self.$question, response: self.$currentResponse)
                .environment(\.managedObjectContext, viewContext)
        ) {
            TextEditor(text: self.$currentResponse)
                .shadow(color: .brown, radius: 2)
                .fontWeight(.semibold)
                .foregroundColor(Color(.darkGray))
                .multilineTextAlignment(.leading)
                .disabled(true)
        }
        .onAppear {
            guard let storedResponse = self.question.response else {
                self.$currentResponse.wrappedValue = "Add your answer, notes or bullet points"
                return
            }
            
            if storedResponse != self.currentResponse {
                self.$currentResponse.wrappedValue = storedResponse
            }
        }
    }
    
    init(question: Binding<PromptItemViewModel>) {
        self._question = question
        self._currentResponse = State(initialValue: "Add your answer, notes or bullet points")
        
        if let promptItem = question.model.wrappedValue as? PromptItem,
           let response = promptItem.response {
            self._currentResponse.wrappedValue = response
        }
    }
}

struct ResponseSection: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var question: PromptItemViewModel
    
    var body: some View {
        UserResponse(question: self.$question)
            .environment(\.managedObjectContext, viewContext)
            .padding()
    }
}

//struct UserResponse_Previews: PreviewProvider {
//    static var previews: some View {
//        ResponseSection(question:
//            Binding(
//                get: {
//                    TopInterviewQuestions().questions[0]
//                },
//                set: { newValue in
//                    // Handle the case where you want to update the selected question
////                    newValue
//                }
//            )
//        )
//            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
