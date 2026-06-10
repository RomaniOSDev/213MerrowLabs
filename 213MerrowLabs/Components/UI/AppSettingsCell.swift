import SwiftUI

struct AppSettingsCell: View {
  let title: String
  let icon: String
  var subtitle: String?
  var iconColor: String = "AppPrimary"
  var isDestructive: Bool = false
  var action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: 14) {
        AppIconCircle(
          systemName: icon,
          colorName: isDestructive ? "AppComfortAlert" : iconColor,
          size: 38
        )
        VStack(alignment: .leading, spacing: 2) {
          Text(title)
            .font(.body.weight(.medium))
            .foregroundStyle(isDestructive ? Color("AppComfortAlert") : Color("AppTextPrimary"))
            .lineLimit(1)
          if let subtitle {
            Text(subtitle)
              .font(.caption)
              .foregroundStyle(Color("AppTextSecondary"))
              .lineLimit(2)
          }
        }
        Spacer(minLength: 8)
        Image(systemName: "chevron.right")
          .font(.caption.weight(.semibold))
          .foregroundStyle(Color("AppTextSecondary"))
      }
      .padding(.horizontal, 14)
      .padding(.vertical, 12)
      .frame(minHeight: 44)
      .contentShape(Rectangle())
    }
    .buttonStyle(PressableButtonStyle())
  }
}

struct AppSettingsGroup<Content: View>: View {
  @ViewBuilder let content: Content

  var body: some View {
    VStack(spacing: 0) {
      content
    }
    .appCardChrome(elevation: .soft)
  }
}
