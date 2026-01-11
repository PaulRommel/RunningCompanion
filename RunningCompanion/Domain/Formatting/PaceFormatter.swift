//
//  PaceFormatter.swift
//  RunningCompanion
//
//  Created by Попов Павел on 11.01.2026.
//

import Foundation

enum PaceFormatter {
    static func paceString(secondsPerKm: Double?) -> String {
        guard let secondsPerKm, secondsPerKm.isFinite, secondsPerKm > 0 else { return "—" }
        let total = Int(secondsPerKm.rounded())
        let m = total / 60
        let s = total % 60
        return "\(m):" + String(format: "%02d", s) + " /км"
    }

    static func kmString(_ km: Double) -> String {
        String(format: "%.2f км", km)
    }

    static func durationString(seconds: Double) -> String {
        let total = Int(seconds.rounded())
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60

        if h > 0 { return "\(h)ч \(m)м" }
        if m > 0 { return "\(m)м \(s)с" }
        return "\(s)с"
    }
}

