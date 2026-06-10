import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var storage: AppStorageManager
    @Binding var selectedTab: AppTab
    @StateObject private var viewModel = HomeViewModel()
    @Environment(\.scenePhase) private var scenePhase

    private let widgetColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                    .ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 18) {
                        heroSection
                        mainPressureWidget
                        widgetGrid
                        trendWidget
                        quickActions
                        recentSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 110)
                }
                .appScreenStyle()
            }
            //.navigationBarHidden(true)
            .onAppear { viewModel.configure(storage: storage) }
            .onChange(of: scenePhase) { phase in
                if phase == .active { viewModel.resumeTimerIfNeeded() }
                else { viewModel.pauseTimer() }
            }
            .sheet(isPresented: $viewModel.showTrackerSheet) {
                PressureTrackerView()
                    .environmentObject(storage)
            }
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            Image("HomeHero")
                .resizable()
                .scaledToFill()
                .frame(height: 160)
                .clipped()
            LinearGradient(
                colors: [Color.clear, Color("AppBackground").opacity(0.85)],
                startPoint: .top,
                endPoint: .bottom
            )
            VStack(alignment: .leading, spacing: 6) {
                AppChip(text: viewModel.locationName, icon: "mappin.circle.fill", tint: "AppPrimary")
                Text(greeting)
                    .font(.title2.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                Text(Date(), style: .date)
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            .padding(16)
        }
        .frame(height: 160)
        .appCardChrome(cornerRadius: 20, elevation: .raised)
        .padding(.top, 8)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<22: return "Good Evening"
        default: return "Good Night"
        }
    }

    // MARK: - Main pressure widget

    private var mainPressureWidget: some View {
        Button {
            viewModel.showTrackerSheet = true
            FeedbackService.lightTap()
        } label: {
            ZStack {
                HStack {
                    Spacer()
                    Image("HomePressureWidget")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 110, height: 110)
                        .opacity(0.9)
                        .padding(.trailing, 8)
                }
                HStack(alignment: .center, spacing: 16) {
                    if viewModel.hasPressure {
                        PressureGaugeView(
                            pressure: viewModel.currentPressure,
                            needleAngle: viewModel.needleAngle,
                            comfortColorName: viewModel.comfortLevel.colorName
                        )
                        .frame(width: 120, height: 100)
                    } else {
                        AppIconCircle(systemName: "gauge.with.dots.needle.67percent", colorName: "AppPrimary", size: 64)
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current Pressure")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                        if viewModel.hasPressure {
                            Text(String(format: "%.1f", viewModel.currentPressure))
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .foregroundStyle(Color("AppTextPrimary"))
                            Text("hPa")
                                .font(.caption.bold())
                                .foregroundStyle(Color("AppTextSecondary"))
                            AppChip(
                                text: ComfortZoneService.label(for: viewModel.comfortLevel),
                                icon: "heart.fill",
                                tint: viewModel.comfortLevel.colorName
                            )
                        } else {
                            Text("Not tracking")
                                .font(.title3.bold())
                                .foregroundStyle(Color("AppTextPrimary"))
                            Text("Tap to open tracker")
                                .font(.caption)
                                .foregroundStyle(Color("AppTextSecondary"))
                        }
                        if viewModel.isTracking {
                            AppChip(text: "Live", icon: "dot.radiowaves.left.and.right", tint: "AppComfortGood")
                        }
                    }
                    Spacer(minLength: 0)
                }
                .padding(16)
            }
            .appCardChrome(
                cornerRadius: 20,
                elevation: .raised,
                accentBorder: viewModel.comfortLevel.colorName
            )
        }
        .buttonStyle(PressableButtonStyle())
    }

    // MARK: - Widget grid

    private var widgetGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(title: "Dashboard", subtitle: "At-a-glance metrics", icon: "square.grid.2x2.fill")
            LazyVGrid(columns: widgetColumns, spacing: 12) {
                if let forecast = viewModel.forecast {
                    HomeDashboardWidget(
                        title: "Forecast",
                        value: forecastLevelTitle(forecast.level),
                        subtitle: String(format: "%+.1f hPa / 6h", forecast.change6h),
                        icon: "cloud.sun.fill",
                        accent: forecastAccent(forecast.level),
                        imageName: "HomeTrendWidget"
                    ) {
                        viewModel.showTrackerSheet = true
                    }
                } else {
                    HomeDashboardWidget(
                        title: "Forecast",
                        value: "Start tracking",
                        subtitle: "Local 6h prediction",
                        icon: "cloud.sun.fill",
                        accent: "AppPrimary",
                        imageName: "HomeTrendWidget"
                    ) {
                        viewModel.startTracking()
                    }
                }
                HomeDashboardWidget(
                    title: "3h Change",
                    value: String(format: "%+.1f hPa", viewModel.change3h),
                    subtitle: "Since 3 hours ago",
                    icon: "arrow.left.arrow.right",
                    accent: abs(viewModel.change3h) >= 3 ? "AppComfortAlert" : "AppAccent",
                    imageName: "HomeTrendWidget"
                ) {
                    viewModel.showTrackerSheet = true
                }
                HomeDashboardWidget(
                    title: "Streak",
                    value: "\(viewModel.streakDays) days",
                    subtitle: "Daily activity",
                    icon: "flame.fill",
                    accent: "AppComfortWarning"
                )
                HomeDashboardWidget(
                    title: "Comfort",
                    value: ComfortZoneService.label(for: viewModel.comfortLevel),
                    subtitle: "\(Int(storage.comfortMin))–\(Int(storage.comfortMax)) hPa",
                    icon: "heart.text.square",
                    accent: viewModel.comfortLevel.colorName
                ) {
                    selectedTab = .settings
                }
                HomeDashboardWidget(
                    title: "Weekly Avg",
                    value: viewModel.weeklyAverage > 0 ? String(format: "%.1f hPa", viewModel.weeklyAverage) : "—",
                    subtitle: "Last 7 days",
                    icon: "calendar",
                    accent: "AppPrimary"
                ) {
                    selectedTab = .logInsights
                }
                HomeDashboardWidget(
                    title: "Entries",
                    value: "\(viewModel.totalEntries)",
                    subtitle: "Total logged",
                    icon: "tray.full.fill",
                    accent: "AppAccent"
                ) {
                    selectedTab = .logInsights
                }
            }
        }
    }

    // MARK: - Trend widget

    private var trendWidget: some View {
        AppCard(accentColor: "AppAccent") {
            VStack(alignment: .leading, spacing: 12) {
                AppSectionHeader(title: "24h Trend", subtitle: "Pressure movement", icon: "chart.xyaxis.line")
                ZStack {
                    Image("HomeTrendWidget")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 120)
                        .clipped()
                        .opacity(0.2)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    PressureLineChart(points: viewModel.last24h)
                        .frame(height: 120)
                }
            }
        }
    }

    // MARK: - Quick actions

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(title: "Quick Actions", icon: "bolt.fill")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    actionChip(
                        title: viewModel.isTracking ? "Stop" : "Start",
                        icon: viewModel.isTracking ? "stop.fill" : "play.fill",
                        accent: viewModel.isTracking ? "AppComfortAlert" : "AppComfortGood"
                    ) {
                        if viewModel.isTracking { viewModel.stopTracking() }
                        else { viewModel.startTracking() }
                    }
                    actionChip(title: "Full Tracker", icon: "gauge", accent: "AppPrimary") {
                        viewModel.showTrackerSheet = true
                    }
                    actionChip(title: "Add Log", icon: "plus.circle.fill", accent: "AppAccent") {
                        selectedTab = .logInsights
                    }
                    actionChip(title: "Insights", icon: "chart.line.uptrend.xyaxis", accent: "AppPrimary") {
                        selectedTab = .logInsights
                    }
                    actionChip(title: "Settings", icon: "gearshape.fill", accent: "AppTextSecondary") {
                        selectedTab = .settings
                    }
                }
            }
        }
    }

    private func actionChip(title: String, icon: String, accent: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                AppIconCircle(systemName: icon, colorName: accent, size: 40)
                Text(title)
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
            }
            .frame(width: 88)
            .padding(.vertical, 12)
            .appCardChrome(cornerRadius: 14, elevation: .flat, accentBorder: accent)
        }
        .buttonStyle(PressableButtonStyle())
    }

    // MARK: - Recent logs

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                AppSectionHeader(title: "Recent Activity", subtitle: "Latest logs", icon: "clock.arrow.circlepath")
                Spacer()
                if !viewModel.recentLogs.isEmpty {
                    Button("See All") { selectedTab = .logInsights }
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
            if viewModel.recentLogs.isEmpty {
                AppEmptyState(
                    icon: "tray",
                    title: "No recent logs",
                    message: "Start tracking or add your first entry.",
                    buttonTitle: "Add Log"
                ) {
                    selectedTab = .logInsights
                }
            } else {
                ForEach(viewModel.recentLogs) { log in
                    PressureLogCell(log: log, locationName: storage.locationName(for: log.locationId))
                }
            }
        }
    }

    private func forecastLevelTitle(_ level: PressureForecast.Level) -> String {
        switch level {
        case .stable: return "Stable"
        case .caution: return "Caution"
        case .alert: return "Alert"
        }
    }

    private func forecastAccent(_ level: PressureForecast.Level) -> String {
        switch level {
        case .stable: return "AppComfortGood"
        case .caution: return "AppComfortWarning"
        case .alert: return "AppComfortAlert"
        }
    }
}
