//
//  RunsListView.swift
//  RunningCompanion
//
//  Created by Попов Павел on 11.01.2026.
//

import SwiftUI
import SwiftData

struct RunsListView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var viewModel: RunsListViewModel

    @Query(
        sort: [SortDescriptor(\RunEntity.startDate, order: .reverse)]
    )
    private var runs: [RunEntity]

    @State private var searchText: String = ""

    private var filteredRuns: [RunEntity] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return runs }
        let query = searchText.lowercased()
        return runs.filter { run in
            // Поиск по дате (строка), дистанции/пейсу/длительности
            var haystacks: [String] = []
            do {
                let df = DateFormatter()
                df.dateStyle = .medium
                df.timeStyle = .none
                haystacks.append(df.string(from: run.startDate).lowercased())
            }
            haystacks.append(PaceFormatter.kmString(run.distanceKm).lowercased())
            haystacks.append(PaceFormatter.durationString(seconds: run.durationSeconds).lowercased())
            if run.distanceKm > 0 {
                let paceSecPerKm = Double(run.durationSeconds) / run.distanceKm
                haystacks.append(PaceFormatter.paceString(secondsPerKm: paceSecPerKm).lowercased())
            }
            if let hr = run.avgHeartRate {
                haystacks.append("hr \(Int(hr.rounded()))")
                haystacks.append("heart \(Int(hr.rounded()))")
            }
            return haystacks.contains { $0.contains(query) }
        }
    }

    private var runsByMonth: [(key: String, value: [RunEntity])] {
        let df = DateFormatter()
        df.dateFormat = "LLLL yyyy" // Полное имя месяца + год

        // Group runs by month key
        let groups = Dictionary(grouping: filteredRuns) { (run: RunEntity) -> String in
            return df.string(from: run.startDate)
        }

        // Create an array with a representative date for each group to simplify sorting
        var annotated: [(key: String, value: [RunEntity], date: Date)] = []
        annotated.reserveCapacity(groups.count)
        for (key, value) in groups {
            let dates: [Date] = value.map { $0.startDate }
            let representativeDate: Date = dates.max() ?? Date.distantPast
            annotated.append((key: key, value: value, date: representativeDate))
        }

        // Sort by the representative date descending
        let sortedAnnotated: [(key: String, value: [RunEntity], date: Date)] = annotated.sorted { (lhs, rhs) -> Bool in
            return lhs.date > rhs.date
        }

        // Drop the date afterward
        let sorted: [(key: String, value: [RunEntity])] = sortedAnnotated.map { item in
            return (key: item.key, value: item.value)
        }

        return sorted
    }

    var body: some View {
        Group {
            if runs.isEmpty {
                // Show a full-screen placeholder instead of embedding ContentUnavailableView in a List
                ContentUnavailableView(
                    "Нет пробежек",
                    systemImage: "figure.run",
                    description: Text("Нажми “Sync”, чтобы импортировать из HealthKit.")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .background(Color.clear)
            } else {
                List {
                    ForEach(runsByMonth, id: \.key) { month, monthRuns in
                        Section(header: Text(month)) {
                            ForEach(monthRuns, id: \RunEntity.persistentModelID) { run in
                                NavigationLink(destination: RunDetailsView(run: run)) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(run.startDate, style: .date)
                                            .font(.headline)

                                        HStack(spacing: 10) {
                                            Text(PaceFormatter.kmString(run.distanceKm))
                                            Text(PaceFormatter.durationString(seconds: run.durationSeconds))
                                            if run.distanceKm > 0 {
                                                let paceSecPerKm = Double(run.durationSeconds) / run.distanceKm
                                                Text(PaceFormatter.paceString(secondsPerKm: paceSecPerKm))
                                            }
                                        }
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)

                                        if let hr = run.avgHeartRate {
                                            Text("Avg HR: \(Int(hr.rounded())) bpm")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        delete(run)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                }
                #if os(macOS)
                .listStyle(.inset)
                #else
                .listStyle(.insetGrouped)
                #endif
            }
        }
        .navigationTitle("Runs")
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
        .refreshable {
            await viewModel.sync()
        }
        .overlay(alignment: .bottom) {
            if let msg = viewModel.lastSyncResult {
                Text(msg)
                    .font(.footnote)
                    .padding(10)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .searchable(text: $searchText, placement: .automatic, prompt: Text("Поиск пробежек"))
    }

    private func delete(_ run: RunEntity) {
        modelContext.delete(run)
        do {
            try modelContext.save()
        } catch {
            // В реальном приложении можно показать ошибку пользователю
            print("Failed to delete run: \(error)")
        }
    }
}

