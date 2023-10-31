//
//  SaveOrCancelHeader.swift
//  InterviewHelperPOC
//
//  Created by Mona Zheng on 9/11/23.
//

import SwiftUI
import CoreData

struct SaveOrCancelResponseHeader: View {
    @Environment(\.managedObjectContext) private var viewContext

    @Binding var inputResponse: String
    @Binding var question: PromptItemViewModel
    @Binding var response: String
    
    var body: some View {
        HStack {
            Button(action: self.cancel) {
                Text("Cancel")
                    .foregroundColor(.black)
                    .padding([.horizontal])
                    .padding([.vertical], 4)
                    .overlay {
                        Capsule(style: .continuous)
                            .stroke(Color.black)
                    }
            }

            Spacer()

            Button(action: { self.save(self.$inputResponse, to: self.$question) }) {
                Text("Save")
                    .foregroundColor(.black)
                    .padding([.horizontal])
                    .padding([.vertical], 4)
                    .overlay {
                        Capsule(style: .continuous)
                            .stroke(Color.black)
                    }
                
            }
        }
    }
}

extension SaveOrCancelResponseHeader {
    // Save to Core Data
    func save(_ inputResponse: Binding<String>, to question: Binding<PromptItemViewModel>) {
        let newPromptItem = PromptItem(context: self.viewContext)
        
        switch $question.model.wrappedValue {
        case let promptItem as PromptItem:
            // The old prompt item properties are assigned to the new prompt item.
            // Then we delete the old prompt item.
            // This is so that the `onChange` will detect the changes of CoreData for the PromptItems.
            // - Comment: We can implement a notification system in the future instead.
            newPromptItem.identifier = promptItem.identifier
            newPromptItem.originialCategory = promptItem.originialCategory
            newPromptItem.originalId = promptItem.originalId
            newPromptItem.prompt = promptItem.prompt
            
            self.viewContext.delete(promptItem)
        case let topInterviewQuestion as TopInterviewQuestion:
            newPromptItem.identifier = UUID()
            newPromptItem.originialCategory = "top-interview-question"
            newPromptItem.originalId = String(topInterviewQuestion.id)
            newPromptItem.prompt = topInterviewQuestion.prompt
        default:
            fatalError("Unsupported type")
        }
        
        newPromptItem.response = inputResponse.wrappedValue

        do {
            try self.viewContext.save()
            print("Saved successfully")
            
//            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "PromptItem")
//            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//
//            do {
//                try viewContext.execute(batchDeleteRequest)
//            } catch {
//                print("Error deleting entities: \(error)")
//            }

            
//            let fetchRequestToShow = PromptItem.fetchRequest()
//            do {
//                let promptItems = try viewContext.fetch(fetchRequestToShow)
//                for promptItem in promptItems {
//                    print("Fetched PromptItem with prompt: \(promptItem.prompt)")
//                    print("Response: \(promptItem.response)")
//                }
//            } catch {
//                print("Error fetching PromptItem: \(error)")
//            }
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func cancel() {
        self.inputResponse = self.response
    }
}

//struct SaveOrCancelHeader_Previews: PreviewProvider {
//    static var previews: some View {
//        SaveOrCancelResponseHeader(response: .constant("Hello"), inputResponse: .constant("Not Hello"))
//            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
