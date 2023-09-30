//
//  InterviewHelperPOCApp.swift
//  InterviewHelperPOC
//
//  Created by Mona Zheng on 9/9/23.
//

import SwiftUI

@main
struct InterviewHelperPOCApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
