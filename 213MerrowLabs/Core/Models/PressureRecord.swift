import Foundation

struct PressureRecord: Identifiable, Codable, Equatable {
    let id: UUID
    var timestamp: Date
    var pressureLevel: Double
    var locationId: UUID?
    var wellnessNote: WellnessNote?

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        pressureLevel: Double,
        locationId: UUID? = nil,
        wellnessNote: WellnessNote? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.pressureLevel = pressureLevel
        self.locationId = locationId
        self.wellnessNote = wellnessNote
    }
}

struct PressureHistoryPoint: Identifiable, Codable, Equatable {
    let id: UUID
    var timestamp: Date
    var value: Double

    init(id: UUID = UUID(), timestamp: Date = Date(), value: Double) {
        self.id = id
        self.timestamp = timestamp
        self.value = value
    }
}
