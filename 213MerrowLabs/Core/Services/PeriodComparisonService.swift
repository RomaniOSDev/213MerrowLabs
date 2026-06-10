import Foundation

struct PeriodStats {
    let average: Double
    let minimum: Double
    let maximum: Double
    let sharpSpikes: Int
    let entryCount: Int
}

struct PeriodComparison {
    let thisWeek: PeriodStats
    let lastWeek: PeriodStats

    var averageDelta: Double { thisWeek.average - lastWeek.average }
    var spikesDelta: Int { thisWeek.sharpSpikes - lastWeek.sharpSpikes }
}

enum PeriodComparisonService {
    private static let spikeThreshold = 3.0

    static func compare(logs: [PressureLog], records: [PressureRecord]) -> PeriodComparison {
        let now = Date()
        let thisStart = now.addingTimeInterval(-7 * 24 * 3600)
        let lastStart = now.addingTimeInterval(-14 * 24 * 3600)
        return PeriodComparison(
            thisWeek: stats(from: logs, records: records, start: thisStart, end: now),
            lastWeek: stats(from: logs, records: records, start: lastStart, end: thisStart)
        )
    }

    private static func stats(from logs: [PressureLog], records: [PressureRecord], start: Date, end: Date) -> PeriodStats {
        let logValues = logs.filter { $0.timestamp >= start && $0.timestamp < end }.map(\.pressure)
        let recordValues = records.filter { $0.timestamp >= start && $0.timestamp < end }.map(\.pressureLevel)
        let values = logValues + recordValues
        guard !values.isEmpty else {
            return PeriodStats(average: 0, minimum: 0, maximum: 0, sharpSpikes: 0, entryCount: 0)
        }
        let sorted = values.sorted()
        var spikes = 0
        for index in 1..<sorted.count {
            if abs(sorted[index] - sorted[index - 1]) >= spikeThreshold {
                spikes += 1
            }
        }
        return PeriodStats(
            average: values.reduce(0, +) / Double(values.count),
            minimum: values.min() ?? 0,
            maximum: values.max() ?? 0,
            sharpSpikes: spikes,
            entryCount: values.count
        )
    }
}
