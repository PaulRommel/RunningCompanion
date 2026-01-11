//
//  RootView.swift
//  RunningCompanion
//
//  Created by Попов Павел on 11.01.2026.
//

import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        RootContentView(modelContext: modelContext)
    }
}

private struct RootContentView: View {
    let modelContext: ModelContext

    @State private var runsVM: RunsListViewModel
    @State private var dashboardVM: DashboardViewModel

    init(modelContext: ModelContext) {
        self.modelContext = modelContext

        let hk = HealthKitClientLive()
        let repo = RunsRepository(hk: hk, context: modelContext)

        _runsVM = State(initialValue: RunsListViewModel(repository: repo))
        _dashboardVM = State(initialValue: DashboardViewModel(repository: repo))
    }

    var body: some View {
        TabView {
            NavigationStack {
                DashboardView(viewModel: dashboardVM)
            }
            .tabItem { Label("Dashboard", systemImage: "chart.bar") }

            NavigationStack {
                RunsListView(viewModel: runsVM)
            }
            .tabItem { Label("Runs", systemImage: "figure.run") }

            NavigationStack {
                SettingsView()
            }
            .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}

#Preview {
    RootView()
}
