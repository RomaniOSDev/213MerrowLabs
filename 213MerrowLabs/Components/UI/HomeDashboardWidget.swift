import SwiftUI

struct HomeDashboardWidget: View {
  let title: String
  let value: String
  var subtitle: String?
  var icon: String
  var accent: String = "AppPrimary"
  var imageName: String?
  var action: (() -> Void)?

  var body: some View {
    Group {
      if let action {
        Button(action: action) { widgetContent }
          .buttonStyle(PressableButtonStyle())
      } else {
        widgetContent
      }
    }
  }

  private var widgetContent: some View {
    ZStack(alignment: .bottomLeading) {
      if let imageName {
        Image(imageName)
          .resizable()
          .scaledToFill()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .clipped()
          .opacity(0.35)
      }
      LinearGradient(
        colors: [Color("AppSurface").opacity(0.1), Color("AppSurface").opacity(0.92)],
        startPoint: .top,
        endPoint: .bottom
      )
      VStack(alignment: .leading, spacing: 8) {
        HStack {
          AppIconCircle(systemName: icon, colorName: accent, size: 32)
          Spacer()
        }
        Spacer(minLength: 0)
        Text(title)
          .font(.caption)
          .foregroundStyle(Color("AppTextSecondary"))
          .lineLimit(1)
        Text(value)
          .font(.title3.bold())
          .foregroundStyle(Color("AppTextPrimary"))
          .lineLimit(2)
          .minimumScaleFactor(0.7)
        if let subtitle {
          Text(subtitle)
            .font(.caption2)
            .foregroundStyle(Color("AppTextSecondary"))
            .lineLimit(2)
            .minimumScaleFactor(0.7)
        }
      }
      .padding(12)
    }
    .frame(height: 130)
    .appCardChrome(elevation: .soft, accentBorder: accent)
  }
}
