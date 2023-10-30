//
//  ContentView.swift
//  InterviewHelperPOC
//
//  Created by Mona Zheng on 9/9/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PromptItem.identifier, ascending: true)],
        animation: .default)
    
    private var items: FetchedResults<PromptItem>
    
    @State var topInterviewQuestions: [Item] = TopInterviewQuestions().questions
    
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
                                        Image(systemName: "chevron.forward")
                                    }
                                    .foregroundColor(.black)
                                    .padding([.horizontal])
                                    .padding([.vertical], 4)

                                    Divider()
                                }
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            for item in self.items {
                guard item.originialCategory == "top-interview-question",
                      let stringId = item.originalId,
                      let integerId = Int(stringId),
                      integerId > 0,
                      integerId <= topInterviewQuestions.count
                else { continue }
                
                
                // The items list starts with an id that starts with "1"
                let index = integerId - 1
                
                print("The saved item:", item.identifier, item.response)
                print("Original item:", self.topInterviewQuestions[index].response)
        
                self.topInterviewQuestions[index] = item
            }
        }
        .onChange(of: Array(self.items)) { newItems in
            for item in newItems {
                guard item.originialCategory == "top-interview-question",
                      let stringId = item.originalId,
                      let integerId = Int(stringId),
                      integerId > 0,
                      integerId <= topInterviewQuestions.count
                else { continue }
                
                
                // The items list starts with an id that starts with "1"
                let index = integerId - 1
                
                print("The saved item:", item.identifier, item.response)
                print("Original item:", self.topInterviewQuestions[index].response)
        
                self.topInterviewQuestions[index] = item
            }
        }
    }
}

//                    .alignmentGuide(.listRowSeparatorTrailing) { vd in
//                        return vd[.listRowSeparatorTrailing]

//                    }
//                    List {
//
//                    }
//                    .listStyle(.plain)

//    private func addItem() {
//        withAnimation {
//            let newItem = Item(context: viewContext)
//            newItem.timestamp = Date()
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
//
//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            offsets.map { items[$0] }.forEach(viewContext.delete)
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
//}
        
        //                ForEach(items) { item in
        //                    NavigationLink {
        //                        Text("Item at \(item.timestamp!, formatter: itemFormatter)")
        //                    } label: {
        //                        Text(item.timestamp!, formatter: itemFormatter)
        //                    }
        //                }
        //                .onDelete(perform: deleteItems)
//            }
    //            .toolbar {
    //                ToolbarItem(placement: .navigationBarTrailing) {
    //                    EditButton()
    //                }
    //                ToolbarItem {
    //                    Button(action: addItem) {
    //                        Label("Add Item", systemImage: "plus")
    //                    }
    //                }
    //            }
    //            Text("Select an item")

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
