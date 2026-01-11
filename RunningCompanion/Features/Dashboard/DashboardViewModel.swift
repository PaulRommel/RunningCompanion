//
//  DashboardViewModel.swift
//  RunningCompanion
//
//  Created by Попов Павел on 11.01.2026.
//

import Foundation
import Combine

@MainActor
final class DashboardViewModel: ObservableObject {
    private let repository: RunsRepository

    @Published var isSyncing = false
    @Published var toast: String?

    init(repository: RunsRepository) {
        self.repository = repository
    }

    func sync() async {
        guard !isSyncing else { return }
        isSyncing = true
        defer { isSyncing = false }

        do {
            let inserted = try await repository.syncRuns(after: nil)
            toast = inserted == 0 ? "Новых пробежек нет" : "Импортировано: \(inserted)"
        } catch {
            toast = "Ошибка: \(error.localizedDescription)"
        }
    }
}

