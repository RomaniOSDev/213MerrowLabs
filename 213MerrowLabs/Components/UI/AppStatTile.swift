import SwiftUI

struct AppStatTile: View {
  let label: String
  let value: String
  var icon: String
  var tint: String = "AppAccent"

  var body: some View {
    VStack(spacing: 10) {
      AppIconCircle(systemName: icon, colorName: tint, size: 34)
      Text(value)
        .font(.title3.bold())
        .foregroundStyle(Color("AppTextPrimary"))
        .lineLimit(1)
        .minimumScaleFactor(0.7)
      Text(label)
        .font(.caption)
        .foregroundStyle(Color("AppTextSecondary"))
        .lineLimit(1)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 14)
    .appCardChrome(cornerRadius: 12, elevation: .flat)
  }
}

struct AppMetricCard: View {
  let title: String
  let value: String
  let subtitle: String
  var icon: String
  var accent: String = "AppPrimary"

  var body: some View {
    AppCard(accentColor: accent) {
      HStack(spacing: 12) {
        AppIconCircle(systemName: icon, colorName: accent, size: 42)
        VStack(alignment: .leading, spacing: 4) {
          Text(title)
            .font(.caption)
            .foregroundStyle(Color("AppTextSecondary"))
          Text(value)
            .font(.title3.bold())
            .foregroundStyle(Color("AppTextPrimary"))
            .lineLimit(1)
            .minimumScaleFactor(0.7)
          Text(subtitle)
            .font(.caption2)
            .foregroundStyle(Color("AppTextSecondary"))
        }
      }
    }
  }
}
