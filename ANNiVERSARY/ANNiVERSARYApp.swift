//
//  ANNiVERSARYApp.swift
//  ANNiVERSARY
//
//  Created by Lasse Saalmann on 15.03.25.
//

import SwiftUI

@main
struct ANNiVERSARYApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
