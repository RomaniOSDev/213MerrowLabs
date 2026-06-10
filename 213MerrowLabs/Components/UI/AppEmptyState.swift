import SwiftUI

struct AppEmptyState: View {
  let icon: String
  let title: String
  let message: String
  var buttonTitle: String?
  var action: (() -> Void)?

  var body: some View {
    VStack(spacing: 20) {
      ZStack {
        Circle()
          .fill(AppGradients.iconCircle("AppPrimary"))
          .frame(width: 100, height: 100)
        Circle()
          .stroke(Color("AppPrimary").opacity(0.2), lineWidth: 1.5)
          .frame(width: 100, height: 100)
        Image(systemName: icon)
          .font(.system(size: 40))
          .foregroundStyle(Color("AppPrimary"))
      }
      VStack(spacing: 8) {
        Text(title)
          .font(.title3.bold())
          .foregroundStyle(Color("AppTextPrimary"))
          .multilineTextAlignment(.center)
        Text(message)
          .font(.body)
          .foregroundStyle(Color("AppTextSecondary"))
          .multilineTextAlignment(.center)
      }
      if let buttonTitle, let action {
        Button(buttonTitle, action: action)
          .buttonStyle(PrimaryButtonStyle())
          .padding(.top, 4)
      }
    }
    .padding(24)
    .appCardChrome(elevation: .soft)
  }
}
