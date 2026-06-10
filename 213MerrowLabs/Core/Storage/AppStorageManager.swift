import Combine
import Foundation
import SwiftUI
import UIKit

final class AppStorageManager: ObservableObject {
    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let totalSessionsCompleted = "totalSessionsCompleted"
        static let totalMinutesUsed = "totalMinutesUsed"
        static let streakDays = "streakDays"
        static let lastActivityDate = "lastActivityDate"
        static let achievementsUnlocked = "achievementsUnlocked"
        static let itemsCreated = "itemsCreated"
        static let alertsConfigured = "alertsConfigured"
        static let currentPressure = "currentPressure"
        static let pressureHistory = "pressureHistory"
        static let alertThreshold = "alertThreshold"
        static let lastViewedDate = "lastViewedDate"
        static let isTracking = "isTracking"
        static let pressureLogs = "pressureLogs"
        static let logLastViewed = "logLastViewed"
        static let logShowedIntro = "logShowedIntro"
        static let pressureRecords = "pressureRecords"
        static let averageWeeklyPressure = "averageWeeklyPressure"
        static let insightsLastUpdated = "insightsLastUpdated"
        static let hasViewedHistoricalTrends = "hasViewedHistoricalTrends"
        static let sessionStartDate = "sessionStartDate"
        static let locations = "locations"
        static let selectedLocationId = "selectedLocationId"
        static let comfortMin = "comfortMin"
        static let comfortMax = "comfortMax"
        static let reminderDismissedDate = "reminderDismissedDate"
    }

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private var cancellables = Set<AnyCancellable>()

    @Published var hasSeenOnboarding: Bool { didSet { defaults.set(hasSeenOnboarding, forKey: Keys.hasSeenOnboarding) } }
    @Published var totalSessionsCompleted: Int { didSet { defaults.set(totalSessionsCompleted, forKey: Keys.totalSessionsCompleted) } }
    @Published var totalMinutesUsed: Int { didSet { defaults.set(totalMinutesUsed, forKey: Keys.totalMinutesUsed) } }
    @Published var streakDays: Int { didSet { defaults.set(streakDays, forKey: Keys.streakDays) } }
    @Published var lastActivityDate: Date? {
        didSet {
            if let date = lastActivityDate { defaults.set(date, forKey: Keys.lastActivityDate) }
            else { defaults.removeObject(forKey: Keys.lastActivityDate) }
            updateBadge()
        }
    }
    @Published var achievementsUnlocked: [String: Date] { didSet { saveDictionary(achievementsUnlocked, key: Keys.achievementsUnlocked) } }
    @Published var itemsCreated: Int { didSet { defaults.set(itemsCreated, forKey: Keys.itemsCreated) } }
    @Published var alertsConfigured: Int { didSet { defaults.set(alertsConfigured, forKey: Keys.alertsConfigured) } }
    @Published var currentPressure: Double { didSet { defaults.set(currentPressure, forKey: Keys.currentPressure) } }
    @Published var pressureHistory: [PressureHistoryPoint] { didSet { saveArray(pressureHistory, key: Keys.pressureHistory) } }
    @Published var alertThreshold: Double { didSet { defaults.set(alertThreshold, forKey: Keys.alertThreshold) } }
    @Published var lastViewedDate: Date { didSet { defaults.set(lastViewedDate, forKey: Keys.lastViewedDate) } }
    @Published var isTracking: Bool { didSet { defaults.set(isTracking, forKey: Keys.isTracking) } }
    @Published var pressureLogs: [PressureLog] { didSet { saveArray(pressureLogs, key: Keys.pressureLogs) } }
    @Published var logLastViewed: Date { didSet { defaults.set(logLastViewed, forKey: Keys.logLastViewed) } }
    @Published var logShowedIntro: Bool { didSet { defaults.set(logShowedIntro, forKey: Keys.logShowedIntro) } }
    @Published var pressureRecords: [PressureRecord] {
        didSet { saveArray(pressureRecords, key: Keys.pressureRecords); recalculateWeeklyAverage() }
    }
    @Published var averageWeeklyPressure: Double { didSet { defaults.set(averageWeeklyPressure, forKey: Keys.averageWeeklyPressure) } }
    @Published var insightsLastUpdated: Date { didSet { defaults.set(insightsLastUpdated, forKey: Keys.insightsLastUpdated) } }
    @Published var hasViewedHistoricalTrends: Bool { didSet { defaults.set(hasViewedHistoricalTrends, forKey: Keys.hasViewedHistoricalTrends) } }
    @Published var locations: [SavedLocation] { didSet { saveArray(locations, key: Keys.locations) } }
    @Published var selectedLocationId: UUID? {
        didSet {
            if let id = selectedLocationId { defaults.set(id.uuidString, forKey: Keys.selectedLocationId) }
            else { defaults.removeObject(forKey: Keys.selectedLocationId) }
        }
    }
    @Published var comfortMin: Double { didSet { defaults.set(comfortMin, forKey: Keys.comfortMin) } }
    @Published var comfortMax: Double { didSet { defaults.set(comfortMax, forKey: Keys.comfortMax) } }
    @Published var reminderDismissedDate: Date? {
        didSet {
            if let date = reminderDismissedDate { defaults.set(date, forKey: Keys.reminderDismissedDate) }
            else { defaults.removeObject(forKey: Keys.reminderDismissedDate) }
            updateBadge()
        }
    }

    @Published var newlyUnlockedAchievement: Achievement?
    @Published private(set) var achievementQueue: [Achievement] = []

    private var sessionStartDate: Date?

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalSessionsCompleted = defaults.integer(forKey: Keys.totalSessionsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        streakDays = defaults.integer(forKey: Keys.streakDays)
        lastActivityDate = defaults.object(forKey: Keys.lastActivityDate) as? Date
        achievementsUnlocked = Self.loadDictionary(from: defaults, key: Keys.achievementsUnlocked)
        itemsCreated = defaults.integer(forKey: Keys.itemsCreated)
        alertsConfigured = defaults.integer(forKey: Keys.alertsConfigured)
        currentPressure = defaults.object(forKey: Keys.currentPressure) as? Double ?? 0
        pressureHistory = Self.loadArray(from: defaults, key: Keys.pressureHistory) ?? []
        alertThreshold = defaults.object(forKey: Keys.alertThreshold) as? Double ?? 5.0
        lastViewedDate = defaults.object(forKey: Keys.lastViewedDate) as? Date ?? Date()
        isTracking = defaults.bool(forKey: Keys.isTracking)
        pressureLogs = Self.loadArray(from: defaults, key: Keys.pressureLogs) ?? []
        logLastViewed = defaults.object(forKey: Keys.logLastViewed) as? Date ?? Date()
        logShowedIntro = defaults.bool(forKey: Keys.logShowedIntro)
        pressureRecords = Self.loadArray(from: defaults, key: Keys.pressureRecords) ?? []
        averageWeeklyPressure = defaults.object(forKey: Keys.averageWeeklyPressure) as? Double ?? 0
        insightsLastUpdated = defaults.object(forKey: Keys.insightsLastUpdated) as? Date ?? Date()
        hasViewedHistoricalTrends = defaults.bool(forKey: Keys.hasViewedHistoricalTrends)
        locations = Self.loadArray(from: defaults, key: Keys.locations) ?? []
        if let idString = defaults.string(forKey: Keys.selectedLocationId), let id = UUID(uuidString: idString) {
            selectedLocationId = id
        } else {
            selectedLocationId = nil
        }
        comfortMin = defaults.object(forKey: Keys.comfortMin) as? Double ?? 1008
        comfortMax = defaults.object(forKey: Keys.comfortMax) as? Double ?? 1018
        reminderDismissedDate = defaults.object(forKey: Keys.reminderDismissedDate) as? Date
        ensureDefaultLocation()
        NotificationCenter.default.publisher(for: .dataReset)
            .sink { [weak self] _ in self?.reloadFromDefaults() }
            .store(in: &cancellables)
        updateBadge()
    }

    var selectedLocation: SavedLocation? {
        if let id = selectedLocationId { return locations.first { $0.id == id } }
        return locations.first { $0.isDefault } ?? locations.first
    }

    var shouldShowInAppReminder: Bool {
        guard hasSeenOnboarding else { return false }
        if hasActivityToday { return false }
        if let dismissed = reminderDismissedDate, Calendar.current.isDateInToday(dismissed) { return false }
        return true
    }

    var hasActivityToday: Bool {
        guard let last = lastActivityDate else { return false }
        return Calendar.current.isDateInToday(last)
    }

    func locationName(for id: UUID?) -> String {
        guard let id, let location = locations.first(where: { $0.id == id }) else {
            return selectedLocation?.name ?? "Unknown"
        }
        return location.name
    }

    func comfortLevel(for pressure: Double) -> ComfortLevel {
        ComfortZoneService.level(for: pressure, min: comfortMin, max: comfortMax)
    }

    func dismissReminderForToday() {
        reminderDismissedDate = Date()
        FeedbackService.lightTap()
    }

    func addLocation(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let location = SavedLocation(name: trimmed, isDefault: locations.isEmpty)
        locations.append(location)
        if locations.count == 1 { selectedLocationId = location.id }
        registerActivity()
    }

    func deleteLocation(_ location: SavedLocation) {
        locations.removeAll { $0.id == location.id }
        pressureLogs = pressureLogs.map { log in
            var copy = log
            if copy.locationId == location.id { copy.locationId = selectedLocationId }
            return copy
        }
        pressureRecords = pressureRecords.map { record in
            var copy = record
            if copy.locationId == location.id { copy.locationId = selectedLocationId }
            return copy
        }
        if selectedLocationId == location.id {
            selectedLocationId = locations.first { $0.isDefault }?.id ?? locations.first?.id
        }
        ensureDefaultLocation()
    }

    func setDefaultLocation(_ location: SavedLocation) {
        locations = locations.map { item in
            var copy = item
            copy.isDefault = item.id == location.id
            return copy
        }
        selectedLocationId = location.id
    }

    func completeOnboarding() {
        hasSeenOnboarding = true
        registerActivity()
    }

    func registerActivity() {
        let today = Calendar.current.startOfDay(for: Date())
        if let last = lastActivityDate {
            let lastDay = Calendar.current.startOfDay(for: last)
            let diff = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if diff == 1 { streakDays += 1 }
            else if diff > 1 { streakDays = 1 }
        } else {
            streakDays = 1
        }
        lastActivityDate = Date()
        evaluateAchievements()
    }

    func incrementItemCreated() {
        itemsCreated += 1
        registerActivity()
        evaluateAchievements()
    }

    func configureAlert() {
        alertsConfigured += 1
        incrementItemCreated()
    }

    func markHistoricalTrendsViewed() {
        hasViewedHistoricalTrends = true
        registerActivity()
        evaluateAchievements()
    }

    func startSession() {
        sessionStartDate = Date()
        registerActivity()
    }

    func completeSession() {
        if let start = sessionStartDate {
            totalMinutesUsed += max(1, Int(Date().timeIntervalSince(start) / 60))
        } else {
            totalMinutesUsed += 1
        }
        totalSessionsCompleted += 1
        sessionStartDate = nil
        registerActivity()
        evaluateAchievements()
        FeedbackService.success()
    }

    func addPressureReading(_ value: Double) {
        currentPressure = value
        pressureHistory.append(PressureHistoryPoint(timestamp: Date(), value: value))
        let weekCutoff = Date().addingTimeInterval(-7 * 24 * 3600)
        pressureHistory = pressureHistory.filter { $0.timestamp >= weekCutoff }
        incrementItemCreated()
    }

    func addLog(_ log: PressureLog) {
        pressureLogs.insert(log, at: 0)
        incrementItemCreated()
    }

    func addQuickLog(preset: TimeOfDayPreset, pressure: Double, wellness: WellnessNote?) {
        let log = PressureLog(
            timestamp: preset.timestamp(),
            pressure: pressure,
            locationId: selectedLocationId,
            wellnessNote: wellness,
            timePreset: preset
        )
        addLog(log)
    }

    func updateLog(_ log: PressureLog) {
        if let index = pressureLogs.firstIndex(where: { $0.id == log.id }) {
            pressureLogs[index] = log
        }
    }

    func deleteLog(_ log: PressureLog) {
        pressureLogs.removeAll { $0.id == log.id }
    }

    func addRecord(_ record: PressureRecord) {
        pressureRecords.insert(record, at: 0)
        incrementItemCreated()
    }

    func deleteRecord(_ record: PressureRecord) {
        pressureRecords.removeAll { $0.id == record.id }
    }

    func applyImport(_ export: AppDataExport) {
        locations = export.locations
        comfortMin = export.comfortMin
        comfortMax = export.comfortMax
        currentPressure = export.currentPressure
        pressureHistory = export.pressureHistory
        pressureLogs = export.pressureLogs
        pressureRecords = export.pressureRecords
        itemsCreated = export.itemsCreated
        streakDays = export.streakDays
        ensureDefaultLocation()
        selectedLocationId = locations.first { $0.isDefault }?.id ?? locations.first?.id
        registerActivity()
    }

    func resetAllData() {
        let domain = Bundle.main.bundleIdentifier ?? ""
        defaults.removePersistentDomain(forName: domain)
        defaults.synchronize()
        NotificationCenter.default.post(name: .dataReset, object: nil)
    }

    func reloadFromDefaults() {
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalSessionsCompleted = defaults.integer(forKey: Keys.totalSessionsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        streakDays = defaults.integer(forKey: Keys.streakDays)
        lastActivityDate = defaults.object(forKey: Keys.lastActivityDate) as? Date
        achievementsUnlocked = Self.loadDictionary(from: defaults, key: Keys.achievementsUnlocked)
        itemsCreated = defaults.integer(forKey: Keys.itemsCreated)
        alertsConfigured = defaults.integer(forKey: Keys.alertsConfigured)
        currentPressure = defaults.object(forKey: Keys.currentPressure) as? Double ?? 0
        pressureHistory = Self.loadArray(from: defaults, key: Keys.pressureHistory) ?? []
        alertThreshold = defaults.object(forKey: Keys.alertThreshold) as? Double ?? 5.0
        lastViewedDate = defaults.object(forKey: Keys.lastViewedDate) as? Date ?? Date()
        isTracking = defaults.bool(forKey: Keys.isTracking)
        pressureLogs = Self.loadArray(from: defaults, key: Keys.pressureLogs) ?? []
        logLastViewed = defaults.object(forKey: Keys.logLastViewed) as? Date ?? Date()
        logShowedIntro = defaults.bool(forKey: Keys.logShowedIntro)
        pressureRecords = Self.loadArray(from: defaults, key: Keys.pressureRecords) ?? []
        averageWeeklyPressure = defaults.object(forKey: Keys.averageWeeklyPressure) as? Double ?? 0
        insightsLastUpdated = defaults.object(forKey: Keys.insightsLastUpdated) as? Date ?? Date()
        hasViewedHistoricalTrends = defaults.bool(forKey: Keys.hasViewedHistoricalTrends)
        locations = Self.loadArray(from: defaults, key: Keys.locations) ?? []
        if let idString = defaults.string(forKey: Keys.selectedLocationId) {
            selectedLocationId = UUID(uuidString: idString)
        } else {
            selectedLocationId = nil
        }
        comfortMin = defaults.object(forKey: Keys.comfortMin) as? Double ?? 1008
        comfortMax = defaults.object(forKey: Keys.comfortMax) as? Double ?? 1018
        reminderDismissedDate = defaults.object(forKey: Keys.reminderDismissedDate) as? Date
        achievementQueue = []
        newlyUnlockedAchievement = nil
        sessionStartDate = nil
        ensureDefaultLocation()
        updateBadge()
    }

    func isAchievementUnlocked(_ achievement: Achievement) -> Bool {
        achievementsUnlocked[achievement.id] != nil
    }

    func dismissAchievementBanner() {
        newlyUnlockedAchievement = nil
        if !achievementQueue.isEmpty {
            let next = achievementQueue.removeFirst()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.showAchievement(next)
            }
        }
    }

    private func ensureDefaultLocation() {
        if locations.isEmpty {
            let home = SavedLocation(name: "My Area", isDefault: true)
            locations = [home]
            selectedLocationId = home.id
        } else if !locations.contains(where: \.isDefault), let first = locations.first {
            setDefaultLocation(first)
        }
    }

    private func updateBadge() {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = self.shouldShowInAppReminder ? 1 : 0
        }
    }

    private func evaluateAchievements() {
        var toUnlock: [Achievement] = []
        for achievement in Achievement.all {
            guard achievementsUnlocked[achievement.id] == nil else { continue }
            if shouldUnlock(achievement) { toUnlock.append(achievement) }
        }
        for achievement in toUnlock {
            achievementsUnlocked[achievement.id] = Date()
            if newlyUnlockedAchievement == nil { showAchievement(achievement) }
            else { achievementQueue.append(achievement) }
        }
    }

    private func shouldUnlock(_ achievement: Achievement) -> Bool {
        switch achievement.id {
        case "first_reading": return itemsCreated >= 1
        case "alert_ready": return itemsCreated >= 2
        case "historical_insight": return itemsCreated >= 3
        case "daily_checker": return streakDays >= 30
        case "alert_specialist": return itemsCreated >= 5
        case "getting_going": return itemsCreated >= 10
        case "power_user": return itemsCreated >= 50
        case "active_user": return totalSessionsCompleted >= 10
        default: return false
        }
    }

    private func showAchievement(_ achievement: Achievement) {
        FeedbackService.achievementUnlocked()
        newlyUnlockedAchievement = achievement
    }

    private func recalculateWeeklyAverage() {
        let weekAgo = Date().addingTimeInterval(-7 * 24 * 3600)
        let recent = pressureRecords.filter { $0.timestamp >= weekAgo }
        guard !recent.isEmpty else {
            averageWeeklyPressure = 0
            return
        }
        averageWeeklyPressure = recent.map(\.pressureLevel).reduce(0, +) / Double(recent.count)
        insightsLastUpdated = Date()
    }

    private func saveArray<T: Codable>(_ value: [T], key: String) {
        if let data = try? encoder.encode(value) { defaults.set(data, forKey: key) }
    }

    private func saveDictionary(_ value: [String: Date], key: String) {
        let stringKeyed = value.mapValues { $0.timeIntervalSince1970 }
        if let data = try? encoder.encode(stringKeyed) { defaults.set(data, forKey: key) }
    }

    private static func loadArray<T: Codable>(from defaults: UserDefaults, key: String) -> [T]? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode([T].self, from: data)
    }

    private static func loadDictionary(from defaults: UserDefaults, key: String) -> [String: Date] {
        guard let data = defaults.data(forKey: key),
              let raw = try? JSONDecoder().decode([String: Double].self, from: data) else { return [:] }
        return raw.mapValues { Date(timeIntervalSince1970: $0) }
    }
}
