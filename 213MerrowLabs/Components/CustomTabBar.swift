import SwiftUI

enum AppTab: Int, CaseIterable {
  case home
  case logInsights
  case settings

  var title: String {
    switch self {
    case .home: return "Home"
    case .logInsights: return "Log"
    case .settings: return "Settings"
    }
  }

  var icon: String {
    switch self {
    case .home: return "house.fill"
    case .logInsights: return "list.bullet.rectangle"
    case .settings: return "gearshape.fill"
    }
  }
}

struct CustomTabBar: View {
  @Binding var selectedTab: AppTab

  var body: some View {
    HStack(spacing: 4) {
      ForEach(AppTab.allCases, id: \.rawValue) { tab in
        Button {
          withAnimation(.easeInOut(duration: 0.25)) { selectedTab = tab }
        } label: {
          VStack(spacing: 3) {
            Image(systemName: tab.icon)
              .font(.system(size: 16, weight: .semibold))
              .frame(width: 32, height: 28)
              .background {
                if selectedTab == tab {
                  RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color("AppPrimary").opacity(0.28))
                }
              }
            Text(tab.title)
              .font(.system(size: 10, weight: .bold))
              .lineLimit(1)
          }
          .foregroundStyle(selectedTab == tab ? Color("AppTextPrimary") : Color("AppTextSecondary"))
          .frame(maxWidth: .infinity)
          .padding(.vertical, 4)
        }
        .buttonStyle(PressableButtonStyle())
      }
    }
    .padding(.horizontal, 8)
    .padding(.vertical, 6)
    .background(
      RoundedRectangle(cornerRadius: 16, style: .continuous)
        .fill(Color("AppBackground").opacity(0.96))
    )
    .overlay(
      RoundedRectangle(cornerRadius: 16, style: .continuous)
        .stroke(Color("AppTextPrimary").opacity(0.1), lineWidth: 1)
    )
    .compositingGroup()
    .shadow(color: .black.opacity(0.14), radius: 6, x: 0, y: -2)
    .padding(.horizontal, 16)
    .padding(.top, 6)
    .padding(.bottom, 4)
  }
}
