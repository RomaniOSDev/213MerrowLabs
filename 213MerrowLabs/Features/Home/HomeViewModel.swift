import Combine
import Foundation
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var showTrackerSheet = false
    @Published var needleAngle: Double = -90

    private var storage: AppStorageManager?
    private var timer: AnyCancellable?
    private var basePressure: Double = 1013.0

    func configure(storage: AppStorageManager) {
        self.storage = storage
        updateNeedle(for: storage.currentPressure)
    }

    var currentPressure: Double { storage?.currentPressure ?? 0 }
    var hasPressure: Bool { currentPressure > 0 }
    var isTracking: Bool { storage?.isTracking ?? false }
    var locationName: String { storage?.selectedLocation?.name ?? "My Area" }
    var comfortLevel: ComfortLevel { storage?.comfortLevel(for: currentPressure) ?? .warning }

    var forecast: PressureForecast? {
        guard let storage, currentPressure > 0 else { return nil }
        return PressureForecastService.forecast(from: storage.pressureHistory, current: currentPressure)
    }

    var change3h: Double {
        guard let storage else { return 0 }
        let cutoff = Date().addingTimeInterval(-3 * 3600)
        let recent = storage.pressureHistory.filter { $0.timestamp >= cutoff }.sorted { $0.timestamp < $1.timestamp }
        guard let first = recent.first else { return 0 }
        return currentPressure - first.value
    }

    var last24h: [PressureHistoryPoint] {
        let dayAgo = Date().addingTimeInterval(-24 * 3600)
        return (storage?.pressureHistory ?? []).filter { $0.timestamp >= dayAgo }
    }

    var recentLogs: [PressureLog] {
        Array((storage?.pressureLogs ?? []).prefix(3))
    }

    var streakDays: Int { storage?.streakDays ?? 0 }
    var totalEntries: Int { storage?.itemsCreated ?? 0 }
    var weeklyAverage: Double { storage?.averageWeeklyPressure ?? 0 }

    func startTracking() {
        guard let storage else { return }
        storage.isTracking = true
        storage.startSession()
        basePressure = currentPressure > 0 ? currentPressure : 1013.0
        if currentPressure == 0 {
            storage.addPressureReading(basePressure)
            updateNeedle(for: basePressure)
        }
        FeedbackService.mediumAction()
        startTimer()
    }

    func stopTracking() {
        storage?.isTracking = false
        timer?.cancel()
        timer = nil
        storage?.completeSession()
    }

    func pauseTimer() {
        timer?.cancel()
        timer = nil
    }

    func resumeTimerIfNeeded() {
        guard storage?.isTracking == true, timer == nil else { return }
        startTimer()
    }

    private func startTimer() {
        timer?.cancel()
        timer = Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.simulateReading() }
    }

    private func simulateReading() {
        guard let storage else { return }
        let delta = Double.random(in: -1.5...1.5)
        basePressure = min(1040, max(980, basePressure + delta))
        storage.addPressureReading(basePressure)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            updateNeedle(for: basePressure)
        }
    }

    private func updateNeedle(for pressure: Double) {
        guard pressure > 0 else { return }
        let normalized = (pressure - 980) / 60
        needleAngle = -135 + normalized * 270
    }
}
