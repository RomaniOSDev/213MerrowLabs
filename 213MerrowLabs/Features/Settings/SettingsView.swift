import SwiftUI
import StoreKit
import UIKit

struct SettingsView: View {
  @EnvironmentObject private var storage: AppStorageManager
  @State private var showResetAlert = false
  @State private var showLocations = false
  @State private var showComfort = false
  @State private var showDataTransfer = false

  private let columns = [
    GridItem(.flexible(), spacing: 12),
    GridItem(.flexible(), spacing: 12)
  ]

  var body: some View {
    NavigationStack {
      ZStack {
        BackgroundView()
        ScrollView {
          VStack(spacing: 20) {
            statsCard
            achievementsSection
            preferencesGroup
            legalGroup
            dangerGroup
            versionFooter
          }
          .padding(.horizontal, 16)
          .padding(.bottom, 100)
        }
        .appScreenStyle()
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .navigationTitle("Settings")
      .navigationBarTitleDisplayMode(.inline)
      .navigationDestination(isPresented: $showLocations) { LocationsSettingsView() }
      .navigationDestination(isPresented: $showComfort) { ComfortZoneSettingsView() }
      .navigationDestination(isPresented: $showDataTransfer) { DataTransferView() }
      .alert("Reset All Data?", isPresented: $showResetAlert) {
        Button("Cancel", role: .cancel) {}
        Button("Reset", role: .destructive) {
          storage.resetAllData()
          FeedbackService.warning()
        }
      } message: {
        Text("This will permanently delete all saved data. This action cannot be undone.")
      }
    }
  }

  private var statsCard: some View {
    AppCard {
      VStack(alignment: .leading, spacing: 14) {
        AppSectionHeader(title: "Your Stats", subtitle: "Activity overview", icon: "chart.bar.fill")
        HStack(spacing: 10) {
          AppStatTile(label: "Entries", value: "\(storage.itemsCreated)", icon: "list.bullet")
          AppStatTile(label: "Minutes", value: "\(storage.totalMinutesUsed)", icon: "clock.fill", tint: "AppPrimary")
          AppStatTile(label: "Streak", value: "\(storage.streakDays)d", icon: "flame.fill", tint: "AppComfortWarning")
        }
      }
    }
    .padding(.top, 8)
  }

  private var achievementsSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      AppSectionHeader(
        title: "Achievements",
        subtitle: "\(storage.achievementsUnlocked.count) of \(Achievement.all.count) unlocked",
        icon: "star.fill"
      )
      LazyVGrid(columns: columns, spacing: 12) {
        ForEach(Achievement.all) { achievement in
          AchievementBadgeCell(
            achievement: achievement,
            isUnlocked: storage.isAchievementUnlocked(achievement)
          )
        }
      }
    }
  }

  private var preferencesGroup: some View {
    VStack(alignment: .leading, spacing: 10) {
      AppSectionHeader(title: "Preferences", icon: "slider.horizontal.3")
      AppSettingsGroup {
        AppSettingsCell(title: "Locations", icon: "mappin.and.ellipse", subtitle: storage.selectedLocation?.name ?? "Manage places") {
          showLocations = true
        }
        divider
        AppSettingsCell(title: "Comfort Zone", icon: "heart.text.square", subtitle: "\(Int(storage.comfortMin))–\(Int(storage.comfortMax)) hPa") {
          showComfort = true
        }
        divider
        AppSettingsCell(title: "Export / Import", icon: "square.and.arrow.up.on.square", subtitle: "Backup or restore data") {
          showDataTransfer = true
        }
      }
    }
  }

  private var legalGroup: some View {
    VStack(alignment: .leading, spacing: 10) {
      AppSectionHeader(title: "Legal", icon: "doc.text")
      AppSettingsGroup {
        AppSettingsCell(title: "Rate Us", icon: "star.fill", subtitle: "Enjoying the app? Leave a review") {
          rateApp()
        }
        divider
        AppSettingsCell(title: "Privacy Policy", icon: "hand.raised.fill", subtitle: "How your data is handled") {
          openLink(.privacyPolicy)
        }
        divider
        AppSettingsCell(title: "Terms of Use", icon: "doc.plaintext", subtitle: "Usage terms and conditions") {
          openLink(.termsOfUse)
        }
      }
    }
  }

  private var dangerGroup: some View {
    AppSettingsGroup {
      AppSettingsCell(title: "Reset All Data", icon: "trash.fill", subtitle: "Erase all local progress", isDestructive: true) {
        showResetAlert = true
      }
    }
  }

  private var divider: some View {
    Rectangle()
      .fill(Color("AppTextPrimary").opacity(0.06))
      .frame(height: 1)
      .padding(.leading, 66)
  }

  private var versionFooter: some View {
    Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
      .font(.caption)
      .foregroundStyle(Color("AppTextSecondary"))
      .frame(maxWidth: .infinity)
      .padding(.top, 4)
  }

  private func openLink(_ link: AppExternalLink) {
    if let url = link.url {
      UIApplication.shared.open(url)
    }
  }

  private func rateApp() {
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
      SKStoreReviewController.requestReview(in: windowScene)
    }
  }
}

private struct AchievementBadgeCell: View {
  let achievement: Achievement
  let isUnlocked: Bool

  var body: some View {
    VStack(spacing: 10) {
      ZStack {
        Circle()
          .fill(isUnlocked ? Color("AppPrimary").opacity(0.2) : Color("AppTextPrimary").opacity(0.06))
          .frame(width: 48, height: 48)
        Image(systemName: achievement.systemImage)
          .font(.title3)
          .foregroundStyle(isUnlocked ? Color("AppPrimary") : Color("AppTextSecondary").opacity(0.5))
      }
      Text(achievement.title)
        .font(.caption.bold())
        .foregroundStyle(Color("AppTextPrimary"))
        .lineLimit(2)
        .minimumScaleFactor(0.7)
        .multilineTextAlignment(.center)
      Text(achievement.description)
        .font(.caption2)
        .foregroundStyle(Color("AppTextSecondary"))
        .lineLimit(3)
        .minimumScaleFactor(0.7)
        .multilineTextAlignment(.center)
    }
    .padding(12)
    .frame(minHeight: 130)
    .background(Color("AppSurface"))
    .clipShape(RoundedRectangle(cornerRadius: 14))
    .overlay(
      RoundedRectangle(cornerRadius: 14)
        .stroke(isUnlocked ? Color("AppPrimary").opacity(0.4) : Color("AppTextPrimary").opacity(0.06), lineWidth: 1)
    )
    .opacity(isUnlocked ? 1 : 0.65)
  }
}
