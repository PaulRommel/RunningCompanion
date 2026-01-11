//
//  Run.swift
//  RunningCompanion
//
//  Created by Попов Павел on 11.01.2026.
//

import Foundation

struct Run: Identifiable, Hashable {
    let id: UUID
    let startDate: Date
    let endDate: Date
    let distanceMeters: Double
    let durationSeconds: Double
    let avgHeartRate: Double?
    let kcal: Double?

    var distanceKm: Double { distanceMeters / 1000.0 }
    var paceSecPerKm: Double? {
        guard distanceMeters > 0 else { return nil }
        return durationSeconds / (distanceMeters / 1000.0)
    }
}
