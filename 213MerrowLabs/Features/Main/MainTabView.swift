import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var storage: AppStorageManager
    @State private var selectedTab: AppTab = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            
                Group {
                    switch selectedTab {
                    case .home:
                        HomeView(selectedTab: $selectedTab)
                    case .logInsights:
                        LogInsightsContainerView()
                    case .settings:
                        SettingsView()
                    }
                }
                

                CustomTabBar(selectedTab: $selectedTab)
            

            if storage.shouldShowInAppReminder {
                VStack {
                    InAppReminderBanner(
                        onDismiss: { storage.dismissReminderForToday() },
                        onCheckNow: {
                            selectedTab = .home
                            storage.dismissReminderForToday()
                        }
                    )
                    Spacer()
                }
                .zIndex(90)
            }

            if let achievement = storage.newlyUnlockedAchievement {
                AchievementBannerView(achievement: achievement) {
                    storage.dismissAchievementBanner()
                }
                .zIndex(100)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
