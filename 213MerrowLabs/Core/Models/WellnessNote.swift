import Foundation

enum WellnessNote: String, Codable, CaseIterable, Identifiable {
    case headache
    case normal
    case fatigue

    var id: String { rawValue }

    var title: String {
        switch self {
        case .headache: return "Headache"
        case .normal: return "Normal"
        case .fatigue: return "Fatigue"
        }
    }

    var systemImage: String {
        switch self {
        case .headache: return "brain.head.profile"
        case .normal: return "face.smiling"
        case .fatigue: return "battery.25"
        }
    }
}
