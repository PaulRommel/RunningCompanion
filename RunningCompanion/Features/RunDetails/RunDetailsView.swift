//
//  RunDetailsView.swift
//  RunningCompanion
//
//  Created by Попов Павел on 11.01.2026.
//

import SwiftUI

struct RunDetailsView: View {
    let run: RunEntity

    private var avgPaceSecPerKm: Double {
        let distanceKm = run.distanceMeters / 1000
        guard distanceKm > 0 else { return 0 }
        return run.durationSeconds / distanceKm
    }

    var body: some View {
        List {
            Section("Summary") {
                row("Date", run.startDate.formatted(date: .abbreviated, time: .shortened))
                row("Distance", PaceFormatter.kmString(run.distanceMeters / 1000))
                row("Duration", PaceFormatter.durationString(seconds: run.durationSeconds))
                row("Avg pace", PaceFormatter.paceString(secondsPerKm: avgPaceSecPerKm))

                if let hr = run.avgHeartRate {
                    row("Avg HR", "\(Int(hr.rounded())) bpm")
                }
                if let kcal = run.kcal {
                    row("Active energy", "\(Int(kcal.rounded())) kcal")
                }
            }
        }
        .navigationTitle("Run")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}

