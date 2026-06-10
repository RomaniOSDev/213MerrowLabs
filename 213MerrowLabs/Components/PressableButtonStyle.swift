import SwiftUI

struct PressableButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
      .animation(.spring(response: 0.4, dampingFraction: 0.7), value: configuration.isPressed)
      .onChange(of: configuration.isPressed) { pressed in
        if pressed {
          FeedbackService.lightTap()
        }
      }
  }
}

struct SecondaryButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.headline)
      .lineLimit(1)
      .minimumScaleFactor(0.7)
      .foregroundStyle(Color("AppTextPrimary"))
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .frame(minHeight: 44)
      .appCardChrome(cornerRadius: 12, elevation: .flat, accentBorder: "AppPrimary")
      .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
      .animation(.spring(response: 0.4, dampingFraction: 0.7), value: configuration.isPressed)
      .onChange(of: configuration.isPressed) { pressed in
        if pressed { FeedbackService.lightTap() }
      }
  }
}

struct PrimaryButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.headline)
      .lineLimit(1)
      .minimumScaleFactor(0.7)
      .foregroundStyle(Color("AppTextPrimary"))
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .frame(minHeight: 44)
      .background(AppGradients.primaryButton)
      .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
      .overlay(
        RoundedRectangle(cornerRadius: 12, style: .continuous)
          .stroke(Color("AppTextPrimary").opacity(0.12), lineWidth: 1)
      )
      .compositingGroup()
      .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
      .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
      .animation(.spring(response: 0.4, dampingFraction: 0.7), value: configuration.isPressed)
      .onChange(of: configuration.isPressed) { pressed in
        if pressed {
          FeedbackService.lightTap()
        }
      }
  }
}
