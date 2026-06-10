import Foundation

enum TimeOfDayPreset: String, Codable, CaseIterable, Identifiable {
    case now
    case morning
    case evening

    var id: String { rawValue }

    var title: String {
        switch self {
        case .now: return "Now"
        case .morning: return "Morning"
        case .evening: return "Evening"
        }
    }

    var systemImage: String {
        switch self {
        case .now: return "clock.fill"
        case .morning: return "sunrise.fill"
        case .evening: return "moon.stars.fill"
        }
    }

    func timestamp(for date: Date = Date()) -> Date {
        let calendar = Calendar.current
        switch self {
        case .now:
            return date
        case .morning:
            return calendar.date(bySettingHour: 8, minute: 0, second: 0, of: date) ?? date
        case .evening:
            return calendar.date(bySettingHour: 20, minute: 0, second: 0, of: date) ?? date
        }
    }
}
