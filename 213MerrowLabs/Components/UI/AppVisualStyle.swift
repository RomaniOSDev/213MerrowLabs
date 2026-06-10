import SwiftUI

// MARK: - Elevation

enum AppElevation {
  /// Gradient + border only — for scroll lists (no shadow redraw cost).
  case flat
  /// Single soft shadow — default cards.
  case soft
  /// Tab bar, banners, hero blocks.
  case raised
  /// Rare overlays (achievement toast).
  case floating

  var shadowOpacity: Double {
    switch self {
    case .flat: return 0
    case .soft: return 0.16
    case .raised: return 0.22
    case .floating: return 0.28
    }
  }

  var shadowRadius: CGFloat {
    switch self {
    case .flat: return 0
    case .soft: return 6
    case .raised: return 10
    case .floating: return 14
    }
  }

  var shadowY: CGFloat {
    switch self {
    case .flat: return 0
    case .soft: return 3
    case .raised: return 5
    case .floating: return 8
    }
  }
}

// MARK: - Gradients

enum AppGradients {
  static let surface = LinearGradient(
    colors: [
      Color("AppSurface"),
      Color("AppSurface").opacity(0.9),
      Color("AppBackground").opacity(0.5)
    ],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
  )

  static let surfaceSubtle = LinearGradient(
    colors: [
      Color("AppSurface").opacity(0.95),
      Color("AppBackground").opacity(0.35)
    ],
    startPoint: .top,
    endPoint: .bottom
  )

  static let background = LinearGradient(
    colors: [
      Color("AppBackground"),
      Color("AppSurface").opacity(0.55),
      Color("AppBackground")
    ],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
  )

  static let primaryButton = LinearGradient(
    colors: [
      Color("AppPrimary").opacity(1),
      Color("AppPrimary").opacity(0.72)
    ],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
  )

  static let tabBar = LinearGradient(
    colors: [
      Color("AppSurface").opacity(0.98),
      Color("AppSurface").opacity(0.88)
    ],
    startPoint: .top,
    endPoint: .bottom
  )

  static let borderHighlight = LinearGradient(
    colors: [
      Color("AppTextPrimary").opacity(0.16),
      Color("AppTextPrimary").opacity(0.04)
    ],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
  )

  static func accent(_ colorName: String) -> LinearGradient {
    LinearGradient(
      colors: [
        Color(colorName).opacity(0.32),
        Color(colorName).opacity(0.14)
      ],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
  }

  static func iconCircle(_ colorName: String) -> RadialGradient {
    RadialGradient(
      colors: [
        Color(colorName).opacity(0.3),
        Color(colorName).opacity(0.08)
      ],
      center: .topLeading,
      startRadius: 0,
      endRadius: 48
    )
  }
}

// MARK: - Chrome modifier

struct AppCardChromeModifier: ViewModifier {
  var cornerRadius: CGFloat = 16
  var elevation: AppElevation = .soft
  var accentBorder: String?
  var showsSurfaceFill: Bool = true

  func body(content: Content) -> some View {
    content
      .background {
        if showsSurfaceFill {
          RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(AppGradients.surface)
        }
      }
      .overlay {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
          .stroke(AppGradients.borderHighlight, lineWidth: 1)
      }
      .overlay {
        if let accentBorder {
          RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .stroke(Color(accentBorder).opacity(0.4), lineWidth: 1.5)
        }
      }
      .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
      .modifier(AppShadowModifier(elevation: elevation))
  }
}

/// Applies compositingGroup + a single shadow only when elevation needs it.
private struct AppShadowModifier: ViewModifier {
  let elevation: AppElevation

  func body(content: Content) -> some View {
    if elevation == .flat {
      content
    } else {
      content
        .compositingGroup()
        .shadow(
          color: .black.opacity(elevation.shadowOpacity),
          radius: elevation.shadowRadius,
          x: 0,
          y: elevation.shadowY
        )
    }
  }
}

extension View {
  /// Hides system scroll/navigation backgrounds so `BackgroundView` stays visible.
  func appScreenStyle() -> some View {
    scrollContentBackground(.hidden)
      .toolbarBackground(.hidden, for: .navigationBar)
  }

  func appCardChrome(
    cornerRadius: CGFloat = 16,
    elevation: AppElevation = .soft,
    accentBorder: String? = nil,
    showsSurfaceFill: Bool = true
  ) -> some View {
    modifier(AppCardChromeModifier(
      cornerRadius: cornerRadius,
      elevation: elevation,
      accentBorder: accentBorder,
      showsSurfaceFill: showsSurfaceFill
    ))
  }
}
