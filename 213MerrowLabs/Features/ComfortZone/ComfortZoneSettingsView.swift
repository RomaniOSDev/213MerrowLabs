import SwiftUI

struct ComfortZoneSettingsView: View {
    @EnvironmentObject private var storage: AppStorageManager
    @State private var minInput = ""
    @State private var maxInput = ""
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            BackgroundView()
            ScrollView {
                VStack(spacing: 16) {
                    previewCard
                    AppFormCard(title: "Comfort Range") {
                        VStack(spacing: 14) {
                            fieldRow(label: "Minimum hPa", text: $minInput)
                            fieldRow(label: "Maximum hPa", text: $maxInput)
                            if let errorMessage {
                                Text(errorMessage)
                                    .font(.caption)
                                    .foregroundStyle(Color("AppComfortAlert"))
                            }
                            Button("Save Range") { save() }
                                .buttonStyle(PrimaryButtonStyle())
                        }
                    }
                    AppCard {
                        Text("The gauge highlights green inside your range, yellow near the edges, and red outside.")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
                .padding(16)
            }
            .appScreenStyle()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Comfort Zone")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            minInput = String(format: "%.0f", storage.comfortMin)
            maxInput = String(format: "%.0f", storage.comfortMax)
        }
    }

    private var previewCard: some View {
        let sample = storage.currentPressure > 0 ? storage.currentPressure : 1013
        let level = storage.comfortLevel(for: sample)
        return AppCard(accentColor: level.colorName) {
            HStack(spacing: 14) {
                AppIconCircle(systemName: "gauge.medium", colorName: level.colorName, size: 44)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Live Preview")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                    Text(ComfortZoneService.label(for: level))
                        .font(.title3.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text(String(format: "%.1f hPa current", sample))
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
        }
    }

    private func fieldRow(label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.caption).foregroundStyle(Color("AppTextSecondary"))
            TextField(label, text: text)
                .keyboardType(.decimalPad)
                .foregroundStyle(Color("AppTextPrimary"))
                .padding(12)
                .background(Color("AppBackground").opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    private func save() {
        guard let min = Double(minInput), let max = Double(maxInput), min < max, min >= 900, max <= 1100 else {
            errorMessage = "Enter a valid range (min < max)."
            FeedbackService.warning()
            return
        }
        errorMessage = nil
        storage.comfortMin = min
        storage.comfortMax = max
        FeedbackService.success()
    }
}
