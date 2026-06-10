import Combine
import Foundation
import SwiftUI

@MainActor
final class PressureLogViewModel: ObservableObject {
    @Published var showAddSheet = false
    @Published var showEditSheet = false
    @Published var showDetailSheet = false
    @Published var selectedLog: PressureLog?
    @Published var pressureInput = ""
    @Published var noteInput = ""
    @Published var selectedLocationId: UUID?
    @Published var selectedWellness: WellnessNote? = .normal
    @Published var selectedPreset: TimeOfDayPreset? = .now
    @Published var pressureError: String?
    @Published var shakeTrigger = 0
    @Published var showSuccess = false

    private var storage: AppStorageManager?

    func configure(storage: AppStorageManager) {
        self.storage = storage
    }

    var logs: [PressureLog] {
        storage?.pressureLogs ?? []
    }

    func openAdd() {
        let current = storage?.currentPressure ?? 0
        pressureInput = current > 0 ? String(format: "%.1f", current) : "1013.0"
        noteInput = ""
        selectedLocationId = storage?.selectedLocationId
        selectedWellness = .normal
        selectedPreset = .now
        pressureError = nil
        showAddSheet = true
    }

    func quickAdd(preset: TimeOfDayPreset) {
        let current = storage?.currentPressure ?? 0
        let value = current > 0 ? current : 1013.0
        storage?.addQuickLog(preset: preset, pressure: value, wellness: selectedWellness)
        FeedbackService.logEntrySaved()
        FeedbackService.success()
        showSuccess = true
        storage?.logLastViewed = Date()
    }

    func saveNewEntry() {
        guard let value = Double(pressureInput), value >= 900, value <= 1100 else {
            pressureError = "Enter a valid pressure between 900 and 1100 hPa"
            shakeTrigger += 1
            FeedbackService.warning()
            return
        }
        let timestamp = selectedPreset?.timestamp() ?? Date()
        let log = PressureLog(
            timestamp: timestamp,
            pressure: value,
            note: noteInput.trimmingCharacters(in: .whitespacesAndNewlines),
            locationId: selectedLocationId ?? storage?.selectedLocationId,
            wellnessNote: selectedWellness,
            timePreset: selectedPreset
        )
        storage?.addLog(log)
        FeedbackService.logEntrySaved()
        FeedbackService.success()
        showSuccess = true
        showAddSheet = false
        storage?.logLastViewed = Date()
    }

    func saveEdit() {
        guard var log = selectedLog else { return }
        guard let value = Double(pressureInput), value >= 900, value <= 1100 else {
            pressureError = "Enter a valid pressure between 900 and 1100 hPa"
            shakeTrigger += 1
            FeedbackService.warning()
            return
        }
        log.pressure = value
        log.note = noteInput.trimmingCharacters(in: .whitespacesAndNewlines)
        log.locationId = selectedLocationId
        log.wellnessNote = selectedWellness
        storage?.updateLog(log)
        FeedbackService.success()
        showSuccess = true
        showEditSheet = false
    }

    func delete(_ log: PressureLog) {
        storage?.deleteLog(log)
        FeedbackService.lightTap()
    }

    func selectForDetail(_ log: PressureLog) {
        selectedLog = log
        showDetailSheet = true
    }

    func selectForEdit(_ log: PressureLog) {
        selectedLog = log
        pressureInput = String(format: "%.1f", log.pressure)
        noteInput = log.note
        selectedLocationId = log.locationId ?? storage?.selectedLocationId
        selectedWellness = log.wellnessNote ?? .normal
        pressureError = nil
        showEditSheet = true
    }
}
