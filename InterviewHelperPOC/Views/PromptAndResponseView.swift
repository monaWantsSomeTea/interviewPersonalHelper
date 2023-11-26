//
//  QuestionView.swift
//  InterviewHelperPOC
//
//  Created by Mona Zheng on 9/11/23.
//

import Combine
import SwiftUI

private let kViewBackgroundColor: Color = Color(red: 250/255, green: 240/255, blue: 230/255, opacity: 0.2)
private let kQuestionCardHeightPercentage: CGFloat = 0.35
private let kViewVerticalPadding: CGFloat = 32
private let kResponseRecordingActionsViewPadding: CGFloat = 24


struct PromptAndResponseView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var question: PromptItemViewModel
    
    @ObservedObject var audioBox = AudioBox()
    @ObservedObject var progressAnimator: AudioProgressViewAnimator
    @State var isPresentingNewRecordingView: Bool = false
    @State var isPresentingPlayRecordView: Bool = false
    /// Audio has not been saved to CoreData.
    @State var hasUnsavedAudio: Bool = false
    
    init(question: Binding<PromptItemViewModel>) {
        self._question = question
        
        let audioBox = AudioBox()
        self.audioBox = audioBox
        self.progressAnimator = AudioProgressViewAnimator(audioBox: audioBox)
    }
    
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
                ResponseRecordingActionsView(audioBox: self.audioBox,
                                             progressAnimator: self.progressAnimator,
                                             isPresentingPlayRecordView: self.$isPresentingPlayRecordView,
                                             isPresentingNewRecordingView: self.$isPresentingNewRecordingView,
                                             promptItemViewModel: self.$question)
                    .padding([.horizontal], kResponseRecordingActionsViewPadding)
            }
            .padding([.vertical], kViewVerticalPadding)
            .sheet(isPresented: self.$isPresentingNewRecordingView) {
                CreateNewRecordingView(audioBox: self.audioBox,
                                       progressAnimator: self.progressAnimator,
                                       isPresentingPlayRecordView: self.$isPresentingPlayRecordView,
                                       isPresentingNewRecordingView: self.$isPresentingNewRecordingView,
                                       hasUnsavedAudio: self.$hasUnsavedAudio)
                    .presentationDetents([.fraction(0.2)])
                    .interactiveDismissDisabled(true)
            }
            .sheet(isPresented: self.$isPresentingPlayRecordView) {
                PlayRecordingView(audioBox: self.audioBox,
                                  progressAnimator: self.progressAnimator,
                                  isPresentingPlayRecordView: self.$isPresentingPlayRecordView,
                                  totalRecordTime: .constant(10),
                                  promptItemViewModel: self.$question,
                                  hasUnsavedAudio: self.$hasUnsavedAudio)
                        .presentationDetents([.fraction(0.35)])
                        .interactiveDismissDisabled(true)
                        .environment(\.managedObjectContext, viewContext)
            }
        }
    }
}

//struct QuestionView_Previews: PreviewProvider {
//    static var previews: some View {
//        PromptAndResponseView(question:
//            Binding(
//                get: { TopInterviewQuestions().questions[0] },
//                set: { _ in }
//            )
//        )
//        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
