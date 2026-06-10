import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss

    private var policyText: String {
        guard let url = Bundle.main.url(forResource: "privacy_policy", withExtension: "md"),
              let text = try? String(contentsOf: url, encoding: .utf8) else {
            return "# Privacy Policy\nThis app does NOT collect, store, or transmit any personal data."
        }
        return text
    }

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                ScrollView {
                    if #available(iOS 15.0, *) {
                        Text(.init(policyText))
                            .foregroundStyle(Color("AppTextPrimary"))
                            .tint(Color("AppPrimary"))
                            .padding(20)
                    } else {
                        Text(policyText)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .padding(20)
                    }
                }
                .appScreenStyle()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
    }
}
