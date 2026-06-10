import Foundation

enum DataExportService {
    static func makeExport(from storage: AppStorageManager) -> AppDataExport {
        AppDataExport(
            version: 1,
            exportedAt: Date(),
            locations: storage.locations,
            comfortMin: storage.comfortMin,
            comfortMax: storage.comfortMax,
            currentPressure: storage.currentPressure,
            pressureHistory: storage.pressureHistory,
            pressureLogs: storage.pressureLogs,
            pressureRecords: storage.pressureRecords,
            itemsCreated: storage.itemsCreated,
            streakDays: storage.streakDays
        )
    }

    static func exportJSON(from storage: AppStorageManager) throws -> Data {
        let export = makeExport(from: storage)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(export)
    }

    static func exportCSV(from storage: AppStorageManager) -> String {
        var lines = ["type,timestamp,pressure,location,wellness,note,preset"]
        for log in storage.pressureLogs {
            let location = storage.locationName(for: log.locationId)
            let wellness = log.wellnessNote?.title ?? ""
            let preset = log.timePreset?.title ?? ""
            let note = log.note.replacingOccurrences(of: ",", with: ";")
            lines.append("log,\(iso(log.timestamp)),\(log.pressure),\(location),\(wellness),\(note),\(preset)")
        }
        for record in storage.pressureRecords {
            let location = storage.locationName(for: record.locationId)
            let wellness = record.wellnessNote?.title ?? ""
            lines.append("record,\(iso(record.timestamp)),\(record.pressureLevel),\(location),\(wellness),,")
        }
        return lines.joined(separator: "\n")
    }

    static func importJSON(_ data: Data, into storage: AppStorageManager) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let export = try decoder.decode(AppDataExport.self, from: data)
        storage.applyImport(export)
    }

    private static func iso(_ date: Date) -> String {
        ISO8601DateFormatter().string(from: date)
    }
}
