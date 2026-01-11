//
//  RunEntity.swift
//  RunningCompanion
//
//  Created by Попов Павел on 11.01.2026.
//

import Foundation
import SwiftData

@Model
final class RunEntity {
    // уникальный ключ из HealthKit
    @Attribute(.unique) var healthKitUUID: UUID

    var startDate: Date
    var endDate: Date

    // метрики храним в "базовых" единицах
    var distanceMeters: Double
    var durationSeconds: Double
    var avgHeartRate: Double?     // bpm
    var kcal: Double?            // active energy

    // производные можно хранить, но лучше считать на лету
    // var avgPaceSecPerKm: Double

    init(
        healthKitUUID: UUID,
        startDate: Date,
        endDate: Date,
        distanceMeters: Double,
        durationSeconds: Double,
        avgHeartRate: Double? = nil,
        kcal: Double? = nil
    ) {
        self.healthKitUUID = healthKitUUID
        self.startDate = startDate
        self.endDate = endDate
        self.distanceMeters = distanceMeters
        self.durationSeconds = durationSeconds
        self.avgHeartRate = avgHeartRate
        self.kcal = kcal
    }
}

