//
//  RunningCompanionApp.swift
//  RunningCompanion
//
//  Created by Попов Павел on 11.01.2026.
//

import SwiftUI
import SwiftData

@main
struct RunningCompanionApp: App {
    private let container: ModelContainer = ModelContainerFactory.make()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(container)
    }
}


//-----
/*
import SwiftUI

@main
struct RunningCompanionApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
*/
