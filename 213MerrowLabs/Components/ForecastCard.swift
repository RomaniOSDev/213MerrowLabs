import SwiftUI

struct ForecastCard: View {
    let forecast: PressureForecast

    private var accentColor: String {
        switch forecast.level {
        case .stable: return "AppComfortGood"
        case .caution: return "AppComfortWarning"
        case .alert: return "AppComfortAlert"
        }
    }

    private var icon: String {
        switch forecast.level {
        case .stable: return "sun.max.fill"
        case .caution: return "cloud.fill"
        case .alert: return "cloud.bolt.fill"
        }
    }

    var body: some View {
        AppCard(accentColor: accentColor) {
            HStack(alignment: .top, spacing: 14) {
                AppIconCircle(systemName: icon, colorName: accentColor, size: 44)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Local Forecast")
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text(forecast.message)
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .fixedSize(horizontal: false, vertical: true)
                    AppChip(
                        text: String(format: "%+.1f hPa in 6 h", forecast.change6h),
                        icon: "arrow.left.arrow.right",
                        tint: accentColor
                    )
                }
            }
        }
    }
}
