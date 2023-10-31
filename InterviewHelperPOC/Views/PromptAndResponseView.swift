//
//  QuestionView.swift
//  InterviewHelperPOC
//
//  Created by Mona Zheng on 9/11/23.
//

import SwiftUI

struct PromptAndResponseView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var question: PromptItemViewModel
    
    var body: some View {
        self.content
            .background(Color(red: 250/255, green: 240/255, blue: 230/255, opacity: 0.2)) //, ,
    }
    
    var content: some View {
        GeometryReader { proxy in
            VStack {
                QuestionCard(question: self.question)
                    .padding()
                    .frame(height: proxy.size.height * 0.35)
                ResponseSection(question: self.$question)
                    .environment(\.managedObjectContext, viewContext)
                
            }
            .padding([.vertical], 32)
        }
    }
    
    init(question: Binding<PromptItemViewModel>) {
        self._question = question
    }
}

//struct QuestionView_Previews: PreviewProvider {
//    static var previews: some View {
//        PromptAndResponseView(question: TopInterviewQuestions().questions[0])
//            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
