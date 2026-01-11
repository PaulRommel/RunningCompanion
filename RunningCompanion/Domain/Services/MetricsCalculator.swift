//
//  MetricsCalculator.swift
//  RunningCompanion
//
//  Created by Попов Павел on 11.01.2026.
//

import Foundation

// Convenience computed properties for metrics calculations
extension RunEntity {
    var distanceKm: Double { distanceMeters / 1000.0 }
}

enum MetricsCalculator {

    struct WeekKm: Identifiable {
        let id = UUID()
        let weekStart: Date
        let km: Double
    }

    struct PeriodMetrics {
        let totalKm: Double
        let totalSeconds: Double
        let avgPaceSecPerKm: Double?
    }

    static func lastDays(runs: [RunEntity], days: Int, calendar: Calendar = .current) -> PeriodMetrics {
        let now = Date()
        let start = calendar.date(byAdding: .day, value: -max(days, 1), to: now) ?? now

        let filtered = runs.filter { $0.startDate >= start && $0.startDate <= now }

        let totalKm = filtered.reduce(into: 0.0) { $0 += $1.distanceKm }
        let totalSec = filtered.reduce(into: 0.0) { $0 += $1.durationSeconds }

        let avgPace: Double?
        if totalKm > 0 {
            avgPace = totalSec / totalKm
        } else {
            avgPace = nil
        }

        return PeriodMetrics(totalKm: totalKm, totalSeconds: totalSec, avgPaceSecPerKm: avgPace)
    }

    static func startOfWeek(for date: Date, calendar: Calendar = .current) -> Date {
        let comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: comps) ?? date
    }

    static func currentWeekDistanceKm(runs: [RunEntity], calendar: Calendar = .current) -> Double {
        let now = Date()
        let weekStart = startOfWeek(for: now, calendar: calendar)
        return runs
            .filter { $0.startDate >= weekStart && $0.startDate <= now }
            .reduce(into: 0.0) { $0 += $1.distanceKm }
    }

    /// Возвращает N недель (включая текущую) как точки для графика.
    static func weeklyDistanceKm(runs: [RunEntity], numberOfWeeks: Int, calendar: Calendar = .current) -> [WeekKm] {
        let now = Date()
        let thisWeekStart = startOfWeek(for: now, calendar: calendar)

        // Список стартов недель: [thisWeekStart, -1week, -2week, ...]
        let weekStarts: [Date] = (0..<max(numberOfWeeks, 1)).compactMap { offset in
            calendar.date(byAdding: .day, value: -(offset * 7), to: thisWeekStart)
        }.reversed()

        // Группируем пробежки по старту недели
        let grouped: [Date: Double] = Dictionary(grouping: runs, by: { startOfWeek(for: $0.startDate, calendar: calendar) })
            .mapValues { group in group.reduce(into: 0.0) { $0 += $1.distanceKm } }

        return weekStarts.map { WeekKm(weekStart: $0, km: grouped[$0] ?? 0) }
    }

    /// Streak = количество дней подряд (включая сегодня), когда была хотя бы 1 пробежка в день.
    static func streakDays(runs: [RunEntity], calendar: Calendar = .current) -> Int {
        guard !runs.isEmpty else { return 0 }

        // Уникальные "дни" с пробежками
        let daysWithRuns: Set<Date> = Set(
            runs.map { calendar.startOfDay(for: $0.startDate) }
        )

        var streak = 0
        var cursor = calendar.startOfDay(for: Date())

        while daysWithRuns.contains(cursor) {
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = prev
        }

        return streak
    }
}

