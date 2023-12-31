//
//  SaveOrCancelResponseHeaderView.swift
//  InterviewHelperPOC
//
//  Created by Mona Zheng on 9/11/23.
//

import CoreData
import SwiftUI

private let kCancelLabelVerticalViewPadding: CGFloat = 4
private let kSaveLabelVerticalViewPadding: CGFloat = 4
private let kTopInterviewQuestionCategory: String = "top-interview-question"

struct SaveOrCancelResponseHeaderView: View {
    @Environment(\.managedObjectContext) private var viewContext

    /// Input from the user
    @Binding var inputResponse: String
    /// Contains the prompt item data
    @Binding var question: PromptItemViewModel
    
    /// Whether to show the error alert when the response fails to save to CoreData.
    @State var showErrorMessage: Bool = false
    
    var body: some View {
        HStack {
            Button(action: self.cancel) {
                Text("Cancel")
                    .foregroundColor(.primary)
                    .padding([.horizontal])
                    .padding([.vertical], kCancelLabelVerticalViewPadding)
                    .overlay {
                        Capsule(style: .continuous)
                            .stroke(Color.primary)
                    }
            }

            Spacer()

            Button(action: { self.save(self.$inputResponse, to: self.question) }) {
                Text("Save")
                    .foregroundColor(.primary)
                    .padding([.horizontal])
                    .padding([.vertical], kSaveLabelVerticalViewPadding)
                    .overlay {
                        Capsule(style: .continuous)
                            .stroke(Color.primary)
                    }
            }
        }
        .alert(isPresented: self.$showErrorMessage) {
            Alert(title: Text("Something went wrong"),
                  message: Text("Notes were not saved. Please try again later."),
                  dismissButton: .default(Text("Dismiss")))
        }
    }
}

extension SaveOrCancelResponseHeaderView {
    /// Save to Core Data
    private func save(_ inputResponse: Binding<String>, to question: PromptItemViewModel) {
        let newPromptItem = PromptItem(context: self.viewContext)
        var oldPromptItem: PromptItem?
        
        switch question.model {
        case let promptItem as PromptItem:
            // The old prompt item properties are assigned to the new prompt item.
            // Then we delete the old prompt item.
            // This is so that the `onChange` will detect the changes of CoreData for the PromptItems.
            newPromptItem.identifier = promptItem.identifier
            newPromptItem.originialCategory = promptItem.originialCategory
            newPromptItem.originalId = promptItem.originalId
            newPromptItem.prompt = promptItem.prompt
            
            oldPromptItem = promptItem
        case let topInterviewQuestion as TopInterviewQuestion:
            newPromptItem.identifier = UUID()
            newPromptItem.originialCategory = kTopInterviewQuestionCategory
            newPromptItem.originalId = String(topInterviewQuestion.id)
            newPromptItem.prompt = topInterviewQuestion.prompt
        default:
            fatalError("Unsupported type")
        }
        
        newPromptItem.response = inputResponse.wrappedValue

        do {
            if let oldPromptItem {
                self.viewContext.delete(oldPromptItem)
            }
            
            try self.viewContext.save()
        } catch {
            self.showErrorMessage = true
            self.viewContext.delete(newPromptItem)
        }
    }
    
    private func cancel() {
        self.inputResponse = self.question.response
    }
}

struct SaveOrCancelHeader_Previews: PreviewProvider {
    static var previews: some View {
        SaveOrCancelResponseHeaderView(
            inputResponse: .constant("Not Hello"),
            question:
                Binding(
                    get: { TopInterviewQuestions().questions[0] },
                    set: { _ in }
                )
        )
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
