//
//  ResponseSectionView.swift
//  InterviewHelperPOC
//
//  Created by Mona Zheng on 11/1/23.
//

import SwiftUI

struct ResponseSectionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var question: PromptItemViewModel
    
    var body: some View {
        UserResponseView(question: self.$question)
            .environment(\.managedObjectContext, viewContext)
            .padding()
    }
}

struct ResponseSectionView_Previews: PreviewProvider {
    static var previews: some View {
        ResponseSectionView(question:
            Binding(
                get: { TopInterviewQuestions().questions[0] },
                set: { _ in }
            )
        )
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
