import Combine
import Foundation
import SwiftUI

@MainActor
final class PressureTrackerViewModel: ObservableObject {
    @Published var showHistory = false
    @Published var showAlertSheet = false
    @Published var thresholdInput = ""
    @Published var thresholdError: String?
    @Published var shakeTrigger = 0
    @Published var showSuccess = false
    @Published var needleAngle: Double = -90

    private var timer: AnyCancellable?
    private var storage: AppStorageManager?
    private var basePressure: Double = 1013.0

    func configure(storage: AppStorageManager) {
        self.storage = storage
        thresholdInput = String(format: "%.1f", storage.alertThreshold)
        updateNeedle(for: storage.currentPressure)
        if storage.isTracking {
            startTimer()
        }
    }

    func startTracking() {
        guard let storage else { return }
        storage.isTracking = true
        storage.startSession()
        basePressure = storage.currentPressure > 0 ? storage.currentPressure : 1013.0
        if storage.currentPressure == 0 {
            let initial = basePressure
            storage.addPressureReading(initial)
            updateNeedle(for: initial)
        }
        FeedbackService.mediumAction()
        startTimer()
    }

    func stopTracking() {
        storage?.isTracking = false
        timer?.cancel()
        timer = nil
        storage?.completeSession()
        showSuccess = true
    }

    func saveAlertThreshold() {
        guard let storage else { return }
        guard let value = Double(thresholdInput), value > 0, value <= 50 else {
            thresholdError = "Enter a value between 0.1 and 50 hPa"
            shakeTrigger += 1
            FeedbackService.warning()
            return
        }
        thresholdError = nil
        let isNewAlert = storage.alertThreshold != value
        storage.alertThreshold = value
        if isNewAlert {
            storage.configureAlert()
        }
        FeedbackService.alertThresholdSet()
        showAlertSheet = false
        showSuccess = true
    }

    func openHistory() {
        storage?.markHistoricalTrendsViewed()
        storage?.lastViewedDate = Date()
        showHistory = true
    }

    private func startTimer() {
        timer?.cancel()
        timer = Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.simulateReading()
            }
    }

    func pauseTimer() {
        timer?.cancel()
        timer = nil
    }

    func resumeTimerIfNeeded() {
        guard storage?.isTracking == true, timer == nil else { return }
        startTimer()
    }

    private func simulateReading() {
        guard let storage else { return }
        let delta = Double.random(in: -1.5...1.5)
        basePressure = min(1040, max(980, basePressure + delta))
        storage.addPressureReading(basePressure)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            updateNeedle(for: basePressure)
        }
        let change = abs(basePressure - (storage.pressureHistory.dropLast().last?.value ?? basePressure))
        if change >= storage.alertThreshold {
            FeedbackService.warning()
        }
    }

    private func updateNeedle(for pressure: Double) {
        let normalized = (pressure - 980) / 60
        needleAngle = -135 + normalized * 270
    }

    var last24Hours: [PressureHistoryPoint] {
        let dayAgo = Date().addingTimeInterval(-24 * 3600)
        return (storage?.pressureHistory ?? []).filter { $0.timestamp >= dayAgo }
    }

    var weekHistory: [PressureHistoryPoint] {
        storage?.pressureHistory ?? []
    }

    var currentPressure: Double {
        storage?.currentPressure ?? 0
    }

    var isTracking: Bool {
        storage?.isTracking ?? false
    }

    var hasData: Bool {
        currentPressure > 0
    }
}
