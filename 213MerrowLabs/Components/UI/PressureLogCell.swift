import SwiftUI

struct PressureLogCell: View {
    let log: PressureLog
    let locationName: String

    private var accentColor: String {
        let change = log.changeMagnitude
        if change <= -3 { return "AppComfortAlert" }
        if change >= 3 { return "AppComfortWarning" }
        return "AppComfortGood"
    }

    var body: some View {
        AppCard(accentColor: accentColor, elevation: .flat) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(format: "%.1f", log.pressure))
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text("hPa")
                            .font(.caption.bold())
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 6) {
                        changeBadge
                        Text(log.timestamp, style: .time)
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }

                HStack(spacing: 6) {
                    AppChip(text: locationName, icon: "mappin.circle", tint: "AppPrimary")
                    if let preset = log.timePreset {
                        AppChip(text: preset.title, icon: preset.systemImage, tint: "AppAccent")
                    }
                    if let wellness = log.wellnessNote {
                        AppChip(text: wellness.title, icon: wellness.systemImage, tint: "AppSurface")
                    }
                }

                HStack {
                    Text(log.timestamp, style: .date)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Color("AppTextSecondary"))
                }

                if !log.note.isEmpty {
                    Text(log.note)
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextPrimary").opacity(0.92))
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppGradients.surfaceSubtle)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }

    private var changeBadge: some View {
        let change = log.changeMagnitude
        let sign = change >= 0 ? "+" : ""
        return Text("\(sign)\(String(format: "%.1f", change))")
            .font(.caption.bold())
            .foregroundStyle(Color("AppTextPrimary"))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color(accentColor).opacity(0.35))
            .clipShape(Capsule())
    }
}
