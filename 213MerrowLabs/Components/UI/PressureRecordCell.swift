import SwiftUI

struct PressureRecordCell: View {
    let record: PressureRecord
    var locationName: String?
    var showChevron: Bool = true
    var deviation: Double?

    var body: some View {
        AppCard(accentColor: deviationAccent, elevation: .flat) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(String(format: "%.1f", record.pressureLevel))
                        .font(.title2.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text("hPa")
                        .font(.caption2)
                        .foregroundStyle(Color("AppTextSecondary"))
                }

                Rectangle()
                    .fill(Color("AppTextPrimary").opacity(0.1))
                    .frame(width: 1, height: 36)

                VStack(alignment: .leading, spacing: 4) {
                    Text(record.timestamp, style: .date)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text(record.timestamp, style: .time)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                    if let locationName {
                        AppChip(text: locationName, icon: "mappin.circle", tint: "AppPrimary")
                    }
                    if let wellness = record.wellnessNote {
                        AppChip(text: wellness.title, icon: wellness.systemImage, tint: "AppAccent")
                    }
                }

                Spacer(minLength: 0)

                if let deviation {
                    Text(String(format: "%+.1f", deviation))
                        .font(.caption.bold())
                        .foregroundStyle(Color(deviationAccent))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(deviationAccent).opacity(0.2))
                        .clipShape(Capsule())
                }

                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
        }
    }

    private var deviationAccent: String {
        guard let deviation else { return "AppPrimary" }
        if abs(deviation) >= 3 { return "AppComfortAlert" }
        if abs(deviation) >= 1.5 { return "AppComfortWarning" }
        return "AppComfortGood"
    }
}
