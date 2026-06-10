import SwiftUI

struct OnboardingPage: Identifiable {
  let id: Int
  let headline: String
  let description: String
  let icon: String
  let accent: String
  let chip: String
  let highlights: [String]
  let imageName: String?
}

struct OnboardingView: View {
  @EnvironmentObject private var storage: AppStorageManager
  @State private var currentPage = 0

  private let pages: [OnboardingPage] = [
    OnboardingPage(
      id: 0,
      headline: "Track Pressure",
      description: "Monitor atmospheric pressure in your area with a live gauge and comfort indicators.",
      icon: "gauge.with.dots.needle.67percent",
      accent: "AppPrimary",
      chip: "Step 1",
      highlights: ["Live gauge", "Comfort zone", "24h trend"],
      imageName: "HomePressureWidget"
    ),
    OnboardingPage(
      id: 1,
      headline: "Set Alerts",
      description: "Get notified when pressure shifts enough to affect how you feel during the day.",
      icon: "bell.badge.fill",
      accent: "AppAccent",
      chip: "Step 2",
      highlights: ["Smart alerts", "Daily reminders", "Threshold control"],
      imageName: "HomeHero"
    ),
    OnboardingPage(
      id: 2,
      headline: "Start Tracking",
      description: "Log readings, explore insights, and build a clear picture of pressure over time.",
      icon: "chart.line.uptrend.xyaxis",
      accent: "AppComfortGood",
      chip: "Step 3",
      highlights: ["Change log", "Insights", "Achievements"],
      imageName: "HomeTrendWidget"
    )
  ]

  private var isLastPage: Bool { currentPage >= pages.count - 1 }

  var body: some View {
    ZStack {
      BackgroundView()

      VStack(spacing: 0) {
        topBar
          .padding(.horizontal, 24)
          .padding(.top, 16)

        TabView(selection: $currentPage) {
          ForEach(pages) { page in
            OnboardingPageView(page: page, isActive: currentPage == page.id)
              .tag(page.id)
          }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .background(Color.clear)
        .animation(.easeInOut(duration: 0.3), value: currentPage)

        bottomControls
          .padding(.horizontal, 24)
          .padding(.bottom, 36)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  private var topBar: some View {
    HStack {
      AppChip(text: pages[currentPage].chip, icon: "sparkles", tint: pages[currentPage].accent)
      Spacer()
      Text("\(currentPage + 1) / \(pages.count)")
        .font(.caption.bold())
        .foregroundStyle(Color("AppTextSecondary"))
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(AppGradients.surfaceSubtle)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color("AppTextPrimary").opacity(0.08), lineWidth: 1))
    }
  }

  private var bottomControls: some View {
    VStack(spacing: 20) {
      pageIndicator

      HStack(spacing: 12) {
        if !isLastPage {
          Button("Skip") {
            FeedbackService.lightTap()
            storage.completeOnboarding()
          }
          .buttonStyle(SecondaryButtonStyle())
        }

        Button {
          FeedbackService.lightTap()
          if isLastPage {
            storage.completeOnboarding()
          } else {
            withAnimation(.easeInOut(duration: 0.3)) {
              currentPage += 1
            }
          }
        } label: {
          Text(isLastPage ? "Get Started" : "Next")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PrimaryButtonStyle())
      }
    }
  }

  private var pageIndicator: some View {
    HStack(spacing: 6) {
      ForEach(pages) { page in
        Capsule()
          .fill(
            currentPage == page.id
              ? AnyShapeStyle(AppGradients.primaryButton)
              : AnyShapeStyle(Color("AppTextSecondary").opacity(0.35))
          )
          .frame(width: currentPage == page.id ? 32 : 8, height: 8)
          .animation(.easeInOut(duration: 0.3), value: currentPage)
      }
    }
  }
}

// MARK: - Page

private struct OnboardingPageView: View {
  let page: OnboardingPage
  let isActive: Bool
  @State private var appeared = false

  var body: some View {
    ScrollView(showsIndicators: false) {
      VStack(spacing: 24) {
        illustrationHero
          .scaleEffect(appeared ? 1 : 0.92)
          .opacity(appeared ? 1 : 0)

        AppCard(accentColor: page.accent, elevation: .raised) {
          VStack(alignment: .leading, spacing: 14) {
            Text(page.headline)
              .font(.title.bold())
              .foregroundStyle(Color("AppTextPrimary"))
              .frame(maxWidth: .infinity, alignment: .leading)

            Text(page.description)
              .font(.body)
              .foregroundStyle(Color("AppTextSecondary"))
              .fixedSize(horizontal: false, vertical: true)

            ScrollView(.horizontal, showsIndicators: false) {
              HStack(spacing: 8) {
                ForEach(page.highlights, id: \.self) { highlight in
                  AppChip(text: highlight, icon: "checkmark", tint: page.accent)
                }
              }
            }
          }
        }
      }
      .padding(.horizontal, 24)
      .padding(.top, 20)
      .padding(.bottom, 16)
    }
    .scrollContentBackground(.hidden)
    .onChange(of: isActive) { active in
      if active {
        appeared = false
        withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
          appeared = true
        }
      } else {
        appeared = false
      }
    }
    .onAppear {
      if isActive {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
          appeared = true
        }
      }
    }
  }

  private var illustrationHero: some View {
    ZStack {
      if let imageName = page.imageName {
        Image(imageName)
          .resizable()
          .scaledToFill()
          .frame(maxWidth: .infinity)
          .frame(height: 200)
          .clipped()
      }

      LinearGradient(
        colors: [
          Color(page.accent).opacity(0.15),
          Color("AppBackground").opacity(0.75)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )

      VStack(spacing: 16) {
        ZStack {
          Circle()
            .fill(AppGradients.iconCircle(page.accent))
            .frame(width: 96, height: 96)
          Circle()
            .stroke(Color(page.accent).opacity(0.35), lineWidth: 1.5)
            .frame(width: 96, height: 96)
          Image(systemName: page.icon)
            .font(.system(size: 40, weight: .semibold))
            .foregroundStyle(Color(page.accent))
        }
        .compositingGroup()
        .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 4)

        AppChip(text: page.chip, icon: page.icon, tint: page.accent)
      }
      .padding(.vertical, 28)
    }
    .frame(height: 220)
    .appCardChrome(cornerRadius: 24, elevation: .raised, accentBorder: page.accent)
  }
}
