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
private let kResponseRecordingActionsViewPadding: CGFloat = 24


struct PromptAndResponseView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var question: PromptItemViewModel
    
    @State var isPresentingNewRecordingView: Bool = false
    @State var isPresentingPlayRecordView: Bool = false
    
    @State var totalRecordTime: CGFloat = 0
//    @State var
    
    var body: some View {
        self.content
            .background(kViewBackgroundColor)
    }
    
    var content: some View {
        GeometryReader { proxy in
            VStack {
                QuestionCard(question: self.question)
                    .padding([.horizontal])
                    .frame(height: proxy.size.height * kQuestionCardHeightPercentage)
                ResponseSectionView(question: self.$question)
                    .environment(\.managedObjectContext, viewContext)
                ResponseRecordingActionsView(isPresentingPlayRecordView: self.$isPresentingPlayRecordView, isPresentingNewRecordingView: self.$isPresentingNewRecordingView)
                    .padding([.horizontal], kResponseRecordingActionsViewPadding)
            }
            .padding([.vertical], kViewVerticalPadding)
            .sheet(isPresented: self.$isPresentingNewRecordingView) {
                    CreateNewRecordingView(isPresentingPlayRecordView: self.$isPresentingPlayRecordView, isPresentingNewRecordingView: self.$isPresentingNewRecordingView, totalRecordTime: self.$totalRecordTime)
                    .presentationDetents([.fraction(0.2)])
                    .interactiveDismissDisabled(true)
            }
            .sheet(isPresented: self.$isPresentingPlayRecordView) {
                    PlayRecordingView(isPresentingPlayRecordView: self.$isPresentingPlayRecordView, totalRecordTime: .constant(10))
                        .presentationDetents([.fraction(0.35)])
                        .interactiveDismissDisabled(true)
            }
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
