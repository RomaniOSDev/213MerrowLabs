import SwiftUI

enum LogInsightsSection: String, CaseIterable {
    case log = "Change Log"
    case insights = "Insights"

    var icon: String {
        switch self {
        case .log: return "list.bullet.rectangle"
        case .insights: return "chart.line.uptrend.xyaxis"
        }
    }
}

struct LogInsightsContainerView: View {
    @State private var section: LogInsightsSection = .log

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                VStack(spacing: 0) {
                    segmentBar
                    Group {
                        switch section {
                        case .log: PressureLogView()
                        case .insights: PressureInsightsView()
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: section)
                }
                .appScreenStyle()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle(section == .log ? "Pressure Change Log" : "Pressure Insights")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var segmentBar: some View {
        AppCard(showAccentStripe: false) {
            HStack(spacing: 8) {
                ForEach(LogInsightsSection.allCases, id: \.self) { item in
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) { section = item }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: item.icon)
                                .font(.caption)
                            Text(item.rawValue)
                                .font(.caption.bold())
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        .foregroundStyle(section == item ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background {
                            if section == item {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(AppGradients.primaryButton)
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}
