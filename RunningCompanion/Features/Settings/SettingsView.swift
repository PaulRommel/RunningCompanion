//
//  SettingsView.swift
//  RunningCompanion
//
//  Created by Попов Павел on 11.01.2026.
//

import SwiftUI

enum AppSettings {
    static let weeklyGoalKmKey = "weekly_goal_km"
}

struct SettingsView: View {
    @AppStorage(AppSettings.weeklyGoalKmKey) private var weeklyGoalKm: Double = 20

    var body: some View {
        Form {
            Section("Goals") {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Weekly goal")
                        Spacer()
                        Text("\(Int(weeklyGoalKm)) км")
                            .foregroundStyle(.secondary)
                    }

                    Slider(value: $weeklyGoalKm, in: 5...200, step: 1)
                }
                .padding(.vertical, 6)
            }

            Section("About") {
                Text("Running Companion — pet-проект на SwiftUI + SwiftData + HealthKit.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings")
    }
}
