//
//  ContentView.swift
//  InterviewHelperPOC
//
//  Created by Mona Zheng on 9/9/23.
//

import CoreData
import SwiftUI

private let kScrollViewTopPadding: CGFloat = 1

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
   
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    TopInterviewQuestionsHeader()
                    TopInterviewQuestionsListView()
                        .environment(\.managedObjectContext, viewContext)
                }
            }
            .padding(.top, kScrollViewTopPadding) // Prevents the status bar from being transparent.
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
