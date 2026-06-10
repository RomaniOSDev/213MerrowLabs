import Foundation

struct AppDataExport: Codable {
    let version: Int
    let exportedAt: Date
    let locations: [SavedLocation]
    let comfortMin: Double
    let comfortMax: Double
    let currentPressure: Double
    let pressureHistory: [PressureHistoryPoint]
    let pressureLogs: [PressureLog]
    let pressureRecords: [PressureRecord]
    let itemsCreated: Int
    let streakDays: Int
}
