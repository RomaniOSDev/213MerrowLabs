import Combine
import Foundation
import SwiftUI

@MainActor
final class PressureInsightsViewModel: ObservableObject {
    @Published var showAddSheet = false
    @Published var showDetailSheet = false
    @Published var selectedRecord: PressureRecord?
    @Published var pressureInput = ""
    @Published var pressureError: String?
    @Published var shakeTrigger = 0
    @Published var showSuccess = false
    @Published var selectedPeriod: InsightPeriod = .daily
    @Published var selectedLocationId: UUID?
    @Published var selectedWellness: WellnessNote? = .normal

    private var storage: AppStorageManager?

    enum InsightPeriod: String, CaseIterable {
        case daily = "Daily"
        case weekly = "Weekly"
    }

    func configure(storage: AppStorageManager) {
        self.storage = storage
    }

    var records: [PressureRecord] {
        storage?.pressureRecords ?? []
    }

    var hasData: Bool {
        !records.isEmpty
    }

    var filteredRecords: [PressureRecord] {
        let cutoff: Date
        switch selectedPeriod {
        case .daily:
            cutoff = Date().addingTimeInterval(-24 * 3600)
        case .weekly:
            cutoff = Date().addingTimeInterval(-7 * 24 * 3600)
        }
        return records.filter { $0.timestamp >= cutoff }
    }

    var averagePressure: Double {
        let data = filteredRecords
        guard !data.isEmpty else { return 0 }
        return data.map(\.pressureLevel).reduce(0, +) / Double(data.count)
    }

    var significantDeviations: [PressureRecord] {
        let avg = averagePressure
        guard avg > 0 else { return [] }
        return filteredRecords.filter { abs($0.pressureLevel - avg) >= 3 }
    }

    func openAdd() {
        let current = storage?.currentPressure ?? 0
        pressureInput = current > 0
            ? String(format: "%.1f", current)
            : "1013.0"
        selectedLocationId = storage?.selectedLocationId
        selectedWellness = .normal
        pressureError = nil
        showAddSheet = true
    }

    func saveRecord() {
        guard let value = Double(pressureInput), value >= 900, value <= 1100 else {
            pressureError = "Enter a valid pressure between 900 and 1100 hPa"
            shakeTrigger += 1
            FeedbackService.warning()
            return
        }
        let record = PressureRecord(
            pressureLevel: value,
            locationId: selectedLocationId ?? storage?.selectedLocationId,
            wellnessNote: selectedWellness
        )
        storage?.addRecord(record)
        storage?.markHistoricalTrendsViewed()
        FeedbackService.insightDataSaved()
        FeedbackService.success()
        showSuccess = true
        showAddSheet = false
    }

    func delete(_ record: PressureRecord) {
        storage?.deleteRecord(record)
        FeedbackService.lightTap()
    }

    func selectRecord(_ record: PressureRecord) {
        selectedRecord = record
        showDetailSheet = true
    }

    func markViewed() {
        storage?.markHistoricalTrendsViewed()
    }
}
