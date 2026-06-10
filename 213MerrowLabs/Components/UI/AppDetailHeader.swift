import SwiftUI

struct AppDetailHeader: View {
    let value: String
    let unit: String
    var subtitle: String
    var chips: [(String, String)] = []

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .lastTextBaseline, spacing: 6) {
                    Text(value)
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text(unit)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
                if !chips.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(chips.indices, id: \.self) { index in
                            AppChip(text: chips[index].0, icon: chips[index].1, tint: "AppAccent")
                        }
                    }
                }
            }
        }
    }
}

struct AppFormCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(title: title)
            AppCard(showAccentStripe: false) {
                content
            }
        }
    }
}
