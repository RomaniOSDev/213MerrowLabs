import SwiftUI

struct AchievementBannerView: View {
  let achievement: Achievement
  let onDismiss: () -> Void

  @State private var offset: CGFloat = -120

  var body: some View {
    VStack {
      AppCard(accentColor: "AppPrimary", elevation: .floating) {
        HStack(spacing: 12) {
          AppIconCircle(systemName: achievement.systemImage, colorName: "AppPrimary", size: 40)
          VStack(alignment: .leading, spacing: 2) {
            Text("Achievement Unlocked")
              .font(.caption)
              .foregroundStyle(Color("AppTextSecondary"))
            Text(achievement.title)
              .font(.headline)
              .foregroundStyle(Color("AppTextPrimary"))
          }
          Spacer()
        }
      }
      .padding(.horizontal, 16)
      .offset(y: offset)

      Spacer()
    }
    .onAppear {
      withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
        offset = 0
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        withAnimation(.easeInOut(duration: 0.3)) {
          offset = -120
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
          onDismiss()
        }
      }
    }
  }
}
