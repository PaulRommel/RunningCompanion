//
//  RunsListViewModel.swift
//  RunningCompanion
//
//  Created by Попов Павел on 11.01.2026.
//

import Foundation
import Combine

@MainActor
final class RunsListViewModel: ObservableObject {
    private let repository: RunsRepository

    @Published var isSyncing = false
    @Published var lastSyncResult: String?

    init(repository: RunsRepository) {
        self.repository = repository
    }

    func sync() async {
        guard !isSyncing else { return }
        isSyncing = true
        defer { isSyncing = false }

        do {
            let inserted = try await repository.syncRuns(after: nil)
            lastSyncResult = inserted == 0 ? "Новых пробежек нет" : "Импортировано: \(inserted)"
        } catch {
            lastSyncResult = "Ошибка синка: \(error.localizedDescription)"
        }
    }
}

