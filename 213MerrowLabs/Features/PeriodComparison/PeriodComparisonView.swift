import SwiftUI

struct PeriodComparisonView: View {
    @EnvironmentObject private var storage: AppStorageManager

    private var comparison: PeriodComparison {
        PeriodComparisonService.compare(logs: storage.pressureLogs, records: storage.pressureRecords)
    }

    var body: some View {
        AppCard(accentColor: "AppPrimary") {
            VStack(alignment: .leading, spacing: 14) {
                AppSectionHeader(
                    title: "This Week vs Last Week",
                    subtitle: "Compare averages and spikes",
                    icon: "calendar.badge.clock"
                )
                HStack(spacing: 10) {
                    PeriodStatCell(title: "This Week", stats: comparison.thisWeek, tint: "AppPrimary")
                    PeriodStatCell(title: "Last Week", stats: comparison.lastWeek, tint: "AppAccent")
                }
                HStack {
                    deltaPill("Avg Δ", value: String(format: "%+.1f hPa", comparison.averageDelta))
                    Spacer()
                    deltaPill("Spikes Δ", value: "\(comparison.spikesDelta >= 0 ? "+" : "")\(comparison.spikesDelta)")
                }
            }
        }
    }

    private func deltaPill(_ label: String, value: String) -> some View {
        HStack(spacing: 6) {
            Text(label).font(.caption).foregroundStyle(Color("AppTextSecondary"))
            Text(value).font(.caption.bold()).foregroundStyle(Color("AppTextPrimary"))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color("AppBackground").opacity(0.4))
        .clipShape(Capsule())
    }
}

private struct PeriodStatCell: View {
    let title: String
    let stats: PeriodStats
    let tint: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.bold())
                .foregroundStyle(Color(tint))
            Text(String(format: "%.1f hPa", stats.average))
                .font(.title3.bold())
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text("Min \(Int(stats.minimum)) · Max \(Int(stats.maximum))")
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
            Text("\(stats.sharpSpikes) spikes · \(stats.entryCount) entries")
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color("AppBackground").opacity(0.35))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
