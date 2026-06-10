import SwiftUI

struct AppCard<Content: View>: View {
  var accentColor: String = "AppPrimary"
  var showAccentStripe: Bool = true
  var elevation: AppElevation = .soft
  @ViewBuilder let content: Content

  var body: some View {
    HStack(spacing: 0) {
      if showAccentStripe {
        RoundedRectangle(cornerRadius: 2)
          .fill(
            LinearGradient(
              colors: [
                Color(accentColor),
                Color(accentColor).opacity(0.65)
              ],
              startPoint: .top,
              endPoint: .bottom
            )
          )
          .frame(width: 4)
          .padding(.vertical, 10)
      }
      content
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
    }
    .appCardChrome(elevation: elevation)
  }
}

struct AppSectionHeader: View {
  let title: String
  var subtitle: String?
  var icon: String?

  var body: some View {
    HStack(alignment: .top, spacing: 10) {
      if let icon {
        AppIconCircle(systemName: icon, colorName: "AppPrimary", size: 36)
      }
      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .font(.headline)
          .foregroundStyle(Color("AppTextPrimary"))
        if let subtitle {
          Text(subtitle)
            .font(.caption)
            .foregroundStyle(Color("AppTextSecondary"))
        }
      }
      Spacer(minLength: 0)
    }
  }
}

struct AppIconCircle: View {
  let systemName: String
  var colorName: String = "AppPrimary"
  var size: CGFloat = 40

  var body: some View {
    ZStack {
      Circle()
        .fill(AppGradients.iconCircle(colorName))
        .frame(width: size, height: size)
      Circle()
        .stroke(Color(colorName).opacity(0.22), lineWidth: 1)
        .frame(width: size, height: size)
      Image(systemName: systemName)
        .font(.system(size: size * 0.42, weight: .semibold))
        .foregroundStyle(Color(colorName))
    }
  }
}

struct AppChip: View {
  let text: String
  var icon: String?
  var tint: String = "AppAccent"

  var body: some View {
    HStack(spacing: 4) {
      if let icon {
        Image(systemName: icon)
          .font(.caption2)
      }
      Text(text)
        .font(.caption.bold())
        .lineLimit(1)
        .minimumScaleFactor(0.7)
    }
    .foregroundStyle(Color("AppTextPrimary"))
    .padding(.horizontal, 10)
    .padding(.vertical, 5)
    .background(AppGradients.accent(tint))
    .clipShape(Capsule())
    .overlay(
      Capsule()
        .stroke(Color(tint).opacity(0.25), lineWidth: 0.5)
    )
  }
}
