import Foundation

struct PressureLog: Identifiable, Codable, Equatable {
    let id: UUID
    var timestamp: Date
    var pressure: Double
    var note: String
    var locationId: UUID?
    var wellnessNote: WellnessNote?
    var timePreset: TimeOfDayPreset?

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        pressure: Double,
        note: String = "",
        locationId: UUID? = nil,
        wellnessNote: WellnessNote? = nil,
        timePreset: TimeOfDayPreset? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.pressure = pressure
        self.note = note
        self.locationId = locationId
        self.wellnessNote = wellnessNote
        self.timePreset = timePreset
    }

    var changeMagnitude: Double {
        pressure - 1013.25
    }
}
