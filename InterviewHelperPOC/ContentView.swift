//
//  ContentView.swift
//  InterviewHelperPOC
//
//  Created by Mona Zheng on 9/9/23.
//

import CoreData
import SwiftUI

private let kQuestionsListVerticalPadding: CGFloat = 4
private let kTopInterviewQuestionCategory: String = "top-interview-question"
private let kChevronForwardName: String = "chevron.forward"
private let kScrollViewTopPadding: CGFloat = 1

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [], animation: .default)
    
    /// PromptItems data recieved from Core Data.
    private var fetchedPromptItems: FetchedResults<PromptItem>
    private var promptItems: [PromptItem] { Array(self.fetchedPromptItems) }
    
    /// List of top interview questions.
    @State var topInterviewQuestions: [PromptItemViewModel] = TopInterviewQuestions().questions
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    CommonQuestionsHeader()
                    LazyVStack {
                        ForEach(Array(self.$topInterviewQuestions.enumerated()), id: \.offset) { (_, question) in
                            NavigationLink(
                                destination: PromptAndResponseView(question: question)
                                    .environment(\.managedObjectContext, viewContext)
                            ) {
                                VStack {
                                    HStack {
                                        Text(question.prompt.wrappedValue)
                                            .multilineTextAlignment(.leading)

                                        Spacer()
                                        Image(systemName: kChevronForwardName)
                                    }
                                    .foregroundColor(.black)
                                    .padding([.horizontal])
                                    .padding([.vertical], kQuestionsListVerticalPadding)

                                    Divider()
                                }
                            }
                        }
                    }
                }
            }
            .padding(.top, kScrollViewTopPadding) // Prevents the status bar from being transparent.
        }
        .onAppear {
            self.replaceTopInterviewQuestions(with: self.promptItems)
        }
        .onChange(of: self.promptItems) { newPromptItems in
            self.replaceTopInterviewQuestions(with: newPromptItems)
        }
    }
    
    private func replaceTopInterviewQuestions(with promptItems: [PromptItem]) {
        for item in promptItems {
            guard item.originialCategory == kTopInterviewQuestionCategory,
                  let stringId = item.originalId,
                  let integerId = Int(stringId),
                  integerId > 0,
                  integerId <= topInterviewQuestions.count
            else { continue }
            
            // The items list starts with an id that starts with "1"
            let index = integerId - 1
            self.topInterviewQuestions[index] = PromptItemViewModel(model: item)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
