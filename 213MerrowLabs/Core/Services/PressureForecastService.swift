import Foundation

struct PressureForecast {
    enum Level {
        case stable
        case caution
        case alert
    }

    let level: Level
    let message: String
    let change6h: Double
}

enum PressureForecastService {
    static func forecast(from history: [PressureHistoryPoint], current: Double) -> PressureForecast? {
        guard current > 0 else { return nil }
        let sixHoursAgo = Date().addingTimeInterval(-6 * 3600)
        let sorted = history.filter { $0.timestamp >= sixHoursAgo }.sorted { $0.timestamp < $1.timestamp }
        guard let earliest = sorted.first else {
            return PressureForecast(level: .stable, message: "Not enough data for a local forecast yet.", change6h: 0)
        }
        let change = current - earliest.value
        if change <= -4 {
            return PressureForecast(
                level: .alert,
                message: "Pressure dropped \(String(format: "%.1f", abs(change))) hPa in 6 h. Possible discomfort or weather change ahead.",
                change6h: change
            )
        }
        if change <= -2 {
            return PressureForecast(
                level: .caution,
                message: "Pressure is falling. Monitor how you feel over the next few hours.",
                change6h: change
            )
        }
        if change >= 4 {
            return PressureForecast(
                level: .caution,
                message: "Pressure rose \(String(format: "%.1f", change)) hPa in 6 h. Conditions may stabilize.",
                change6h: change
            )
        }
        return PressureForecast(
            level: .stable,
            message: "Pressure is relatively stable over the last 6 hours.",
            change6h: change
        )
    }
}
