//
//  HealthKitClientLive.swift
//  RunningCompanion
//
//  Created by Попов Павел on 11.01.2026.
//

import HealthKit

final class HealthKitClientLive: HealthKitClient {
    private let store = HKHealthStore()

    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let toRead: Set<HKObjectType> = [
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]

        try await store.requestAuthorization(toShare: [], read: toRead)
    }

    func fetchRuns(after date: Date?) async throws -> [HKWorkout] {
        let type = HKObjectType.workoutType()

        // только бег
        let running = HKQuery.predicateForWorkouts(with: .running)
        
        var predicates = [running]
        if let date {
            let datePredicate = HKQuery.predicateForSamples(withStart: date, end: nil, options: .strictStartDate)
            predicates.append(datePredicate)
        }
        
        let predicate: NSPredicate
        if predicates.count == 1 {
            predicate = predicates[0]
        } else {
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }

        // сортируем от новых к старым
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        return try await withCheckedThrowingContinuation { cont in
            let query = HKSampleQuery(sampleType: type,
                                      predicate: predicate,
                                      limit: 200,
                                      sortDescriptors: [sort]) { _, samples, error in
                if let error { cont.resume(throwing: error); return }
                let workouts = (samples as? [HKWorkout]) ?? []
                cont.resume(returning: workouts)
            }
            store.execute(query)
        }
    }

    func fetchAverageHeartRate(for workout: HKWorkout) async throws -> Double? {
        guard let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return nil }
        let predicate = HKQuery.predicateForObjects(from: workout)

        return try await withCheckedThrowingContinuation { cont in
            let query = HKStatisticsQuery(quantityType: hrType,
                                          quantitySamplePredicate: predicate,
                                          options: [.discreteAverage]) { _, stats, error in
                if let error { cont.resume(throwing: error); return }
                let bpm = stats?.averageQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                cont.resume(returning: bpm)
            }
            store.execute(query)
        }
    }

    func fetchActiveEnergy(for workout: HKWorkout) async throws -> Double? {
        guard let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return nil }
        let predicate = HKQuery.predicateForObjects(from: workout)

        return try await withCheckedThrowingContinuation { cont in
            let query = HKStatisticsQuery(quantityType: energyType,
                                          quantitySamplePredicate: predicate,
                                          options: [.cumulativeSum]) { _, stats, error in
                if let error { cont.resume(throwing: error); return }
                let kcal = stats?.sumQuantity()?.doubleValue(for: .kilocalorie())
                cont.resume(returning: kcal)
            }
            store.execute(query)
        }
    }
}

