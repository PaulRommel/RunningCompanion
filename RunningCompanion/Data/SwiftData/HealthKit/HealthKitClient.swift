//
//  HealthKitClient.swift
//  RunningCompanion
//
//  Created by Попов Павел on 11.01.2026.
//

import HealthKit

protocol HealthKitClient {
    func requestAuthorization() async throws
    func fetchRuns(after date: Date?) async throws -> [HKWorkout]
    func fetchAverageHeartRate(for workout: HKWorkout) async throws -> Double?
    func fetchActiveEnergy(for workout: HKWorkout) async throws -> Double?
}

