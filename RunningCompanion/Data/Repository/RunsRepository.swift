//
//  RunsRepository.swift
//  RunningCompanion
//
//  Created by Попов Павел on 11.01.2026.
//

import Foundation
import SwiftData
import HealthKit

final class RunsRepository {
    private let hk: HealthKitClient
    private let context: ModelContext

    init(hk: HealthKitClient, context: ModelContext) {
        self.hk = hk
        self.context = context
    }

    /// Импортирует пробежки из HealthKit в SwiftData, не создавая дубликатов.
    func syncRuns(after date: Date? = nil) async throws -> Int {
        try await hk.requestAuthorization()

        let workouts = try await hk.fetchRuns(after: date)
        var insertedCount = 0

        for w in workouts {
            let uuid = w.uuid

            let exists = try context.fetch(
                FetchDescriptor<RunEntity>(predicate: #Predicate { $0.healthKitUUID == uuid })
            ).first != nil

            if exists { continue }

            let distance = w.totalDistance?.doubleValue(for: .meter()) ?? 0
            let duration = w.duration

            // Можно убрать HR/ккал из синка и грузить их только в деталях.
            async let hr = hk.fetchAverageHeartRate(for: w)
            async let kcal = hk.fetchActiveEnergy(for: w)

            let entity = RunEntity(
                healthKitUUID: uuid,
                startDate: w.startDate,
                endDate: w.endDate,
                distanceMeters: distance,
                durationSeconds: duration,
                avgHeartRate: try await hr,
                kcal: try await kcal
            )

            context.insert(entity)
            insertedCount += 1
        }

        if insertedCount > 0 {
            try context.save()
        }

        return insertedCount
    }
}

