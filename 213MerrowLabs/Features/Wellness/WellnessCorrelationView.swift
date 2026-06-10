import SwiftUI

struct WellnessCorrelationView: View {
    @EnvironmentObject private var storage: AppStorageManager

    private var stats: [WellnessStat] {
        WellnessCorrelationService.stats(from: storage.pressureLogs)
    }

    var body: some View {
        AppCard(accentColor: "AppAccent") {
            VStack(alignment: .leading, spacing: 14) {
                AppSectionHeader(
                    title: "Wellness Correlation",
                    subtitle: WellnessCorrelationService.summary(from: storage.pressureLogs),
                    icon: "heart.text.square"
                )
                ForEach(stats) { item in
                    WellnessStatCell(item: item)
                }
            }
        }
    }
}

private struct WellnessStatCell: View {
    let item: WellnessStat

    var body: some View {
        HStack(spacing: 12) {
            AppIconCircle(systemName: item.note.systemImage, colorName: tint, size: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.note.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("AppTextPrimary"))
                Text("\(item.count) entries")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            Spacer()
            if item.count > 0 {
                Text(String(format: "%.1f hPa", item.averagePressure))
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(tint).opacity(0.25))
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 4)
    }

    private var tint: String {
        switch item.note {
        case .headache: return "AppComfortAlert"
        case .normal: return "AppComfortGood"
        case .fatigue: return "AppComfortWarning"
        }
    }
}
