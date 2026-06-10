import SwiftUI

struct InAppReminderBanner: View {
    let onDismiss: () -> Void
    let onCheckNow: () -> Void

    var body: some View {
        AppCard(accentColor: "AppPrimary", elevation: .raised) {
            HStack(spacing: 12) {
                AppIconCircle(systemName: "bell.badge.fill", colorName: "AppPrimary", size: 38)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Daily Check")
                        .font(.subheadline.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text("Check your pressure today.")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                Spacer()
                Button("Check", action: onCheckNow)
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(AppGradients.primaryButton)
                    .clipShape(Capsule())
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}
