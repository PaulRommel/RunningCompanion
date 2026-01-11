//
//  ModelContainerFactory.swift
//  RunningCompanion
//
//  Created by Попов Павел on 11.01.2026.
//

import SwiftData

enum ModelContainerFactory {
    static func make() -> ModelContainer {
        let schema = Schema([RunEntity.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try! ModelContainer(for: schema, configurations: [config])
    }
}

