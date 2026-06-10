import Foundation

struct WellnessStat: Identifiable {
    let note: WellnessNote
    let count: Int
    let averagePressure: Double

    var id: String { note.rawValue }
}

enum WellnessCorrelationService {
    static func stats(from logs: [PressureLog]) -> [WellnessStat] {
        WellnessNote.allCases.map { note in
            let filtered = logs.filter { $0.wellnessNote == note }
            let avg = filtered.isEmpty ? 0 : filtered.map(\.pressure).reduce(0, +) / Double(filtered.count)
            return WellnessStat(note: note, count: filtered.count, averagePressure: avg)
        }
    }

    static func summary(from logs: [PressureLog]) -> String {
        let stats = stats(from: logs).filter { $0.count > 0 }
        guard !stats.isEmpty else { return "Add wellness notes to see correlations." }
        if let headache = stats.first(where: { $0.note == .headache }), headache.count >= 2 {
            return "Headache entries average \(String(format: "%.1f", headache.averagePressure)) hPa."
        }
        if let fatigue = stats.first(where: { $0.note == .fatigue }), fatigue.count >= 2 {
            return "Fatigue entries average \(String(format: "%.1f", fatigue.averagePressure)) hPa."
        }
        return "Keep logging wellness to refine your personal patterns."
    }
}
