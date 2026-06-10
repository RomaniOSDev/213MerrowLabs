import Foundation

struct Achievement: Identifiable {
    let id: String
    let title: String
    let description: String
    let systemImage: String

    static let all: [Achievement] = [
        Achievement(id: "first_reading", title: "First Reading", description: "Recorded your first barometric pressure.", systemImage: "gauge.with.dots.needle.33percent"),
        Achievement(id: "alert_ready", title: "Alert Ready", description: "Set up your first alert notification.", systemImage: "bell.badge"),
        Achievement(id: "historical_insight", title: "Historical Insight", description: "Viewed historical data trends at least once.", systemImage: "chart.line.uptrend.xyaxis"),
        Achievement(id: "daily_checker", title: "Daily Checker", description: "Consulted the app once every day continuously for a month.", systemImage: "calendar"),
        Achievement(id: "alert_specialist", title: "Alert Specialist", description: "Configured multiple (5) different alerts.", systemImage: "bell.and.waves.left.and.right"),
        Achievement(id: "getting_going", title: "Getting Going", description: "Reached 10 items.", systemImage: "star"),
        Achievement(id: "power_user", title: "Power User", description: "Reached 50 items.", systemImage: "bolt.fill"),
        Achievement(id: "active_user", title: "Active User", description: "Completed 10 sessions.", systemImage: "figure.walk")
    ]
}
