//
//  DashboardView.swift
//  RunningCompanion
//
//  Created by Попов Павел on 11.01.2026.
//

import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel

    @Query(sort: \RunEntity.startDate, order: .reverse)
    private var runs: [RunEntity]

    @AppStorage(AppSettings.weeklyGoalKmKey) private var weeklyGoalKm: Double = 20

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                header

                if runs.isEmpty {
                    EmptyStateView(
                        title: "Нет данных",
                        subtitle: "Сделай Sync, чтобы импортировать пробежки из HealthKit.",
                        systemImage: "heart.text.square"
                    )
                    .padding(.top, 16)
                } else {
                    metricsGrid
                    weeklyChart
                    goalProgress
                }
            }
            .padding()
        }
        .navigationTitle("Dashboard")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task { await viewModel.sync() }
                } label: {
                    if viewModel.isSyncing {
                        ProgressView()
                    } else {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }
                }
                .accessibilityLabel("Sync")
            }
        }
        .refreshable { await viewModel.sync() }
        .overlay(alignment: .bottom) {
            if let toast = viewModel.toast {
                Text(toast)
                    .font(.footnote)
                    .padding(10)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding()
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Статистика")
                .font(.title2).bold()
            Text("По данным HealthKit (Running)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Metrics

    private var metricsGrid: some View {
        let last7 = MetricsCalculator.lastDays(runs: runs, days: 7)
        let last30 = MetricsCalculator.lastDays(runs: runs, days: 30)

        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            MetricCard(title: "7 дней", value: String(format: "%.1f км", last7.totalKm), subtitle: "Дистанция")
            MetricCard(title: "30 дней", value: String(format: "%.1f км", last30.totalKm), subtitle: "Дистанция")
            MetricCard(title: "Средний темп", value: PaceFormatter.paceString(secondsPerKm: last7.avgPaceSecPerKm), subtitle: "за 7 дней")
            MetricCard(title: "Streak", value: "\(MetricsCalculator.streakDays(runs: runs)) дн", subtitle: "подряд")
        }
    }

    // MARK: - Weekly chart

    private var weeklyChart: some View {
        let weeks = MetricsCalculator.weeklyDistanceKm(runs: runs, numberOfWeeks: 8)

        return VStack(alignment: .leading, spacing: 10) {
            Text("Дистанция по неделям")
                .font(.headline)

            Chart(weeks) { item in
                BarMark(
                    x: .value("Week", item.weekStart),
                    y: .value("Km", item.km)
                )
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .weekOfYear)) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(date, format: .dateTime.month(.abbreviated).day())
                        }
                    }
                }
            }
            .frame(height: 180)
            .padding()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
    }

    // MARK: - Goal

    private var goalProgress: some View {
        let currentWeekKm = MetricsCalculator.currentWeekDistanceKm(runs: runs)
        let progress = weeklyGoalKm > 0 ? min(currentWeekKm / weeklyGoalKm, 1.0) : 0

        return VStack(alignment: .leading, spacing: 10) {
            Text("Цель недели")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(String(format: "%.1f / %.0f км", currentWeekKm, weeklyGoalKm))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(Int((progress * 100).rounded()))%")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                ProgressView(value: progress)
            }
            .padding()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
    }
}

