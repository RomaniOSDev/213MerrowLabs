import Foundation

enum ComfortLevel {
    case good
    case warning
    case alert

    var colorName: String {
        switch self {
        case .good: return "AppComfortGood"
        case .warning: return "AppComfortWarning"
        case .alert: return "AppComfortAlert"
        }
    }
}

enum ComfortZoneService {
    static func level(for pressure: Double, min comfortMin: Double, max comfortMax: Double) -> ComfortLevel {
        guard pressure > 0 else { return .warning }
        if pressure >= comfortMin && pressure <= comfortMax { return .good }
        let distance = Swift.min(abs(pressure - comfortMin), abs(pressure - comfortMax))
        return distance <= 5 ? .warning : .alert
    }

    static func label(for level: ComfortLevel) -> String {
        switch level {
        case .good: return "Comfortable"
        case .warning: return "Borderline"
        case .alert: return "Outside comfort zone"
        }
    }
}
