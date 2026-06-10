import SwiftUI

struct LocationsSettingsView: View {
    @EnvironmentObject private var storage: AppStorageManager
    @State private var newLocationName = ""
    @State private var showError = false

    var body: some View {
        ZStack {
            BackgroundView()
            ScrollView {
                VStack(spacing: 16) {
                    addLocationCard
                    AppSectionHeader(
                        title: "Saved Places",
                        subtitle: "\(storage.locations.count) locations",
                        icon: "mappin.and.ellipse"
                    )
                    ForEach(storage.locations) { location in
                        LocationCell(
                            location: location,
                            isActive: storage.selectedLocationId == location.id,
                            canDelete: storage.locations.count > 1,
                            onActivate: { storage.selectedLocationId = location.id },
                            onSetDefault: { storage.setDefaultLocation(location) },
                            onDelete: { storage.deleteLocation(location) }
                        )
                    }
                }
                .padding(16)
                .padding(.bottom, 40)
            }
            .appScreenStyle()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Locations")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var addLocationCard: some View {
        AppFormCard(title: "Add Location") {
            VStack(spacing: 12) {
                TextField("e.g. My Area, Cabin", text: $newLocationName)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .padding(12)
                    .background(Color("AppBackground").opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Button("Add Location") { addLocation() }
                    .buttonStyle(PrimaryButtonStyle())
                if showError {
                    Text("Enter a location name.")
                        .font(.caption)
                        .foregroundStyle(Color("AppComfortAlert"))
                }
            }
        }
    }

    private func addLocation() {
        let trimmed = newLocationName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            showError = true
            FeedbackService.warning()
            return
        }
        showError = false
        storage.addLocation(name: trimmed)
        newLocationName = ""
        FeedbackService.success()
    }
}

private struct LocationCell: View {
    let location: SavedLocation
    let isActive: Bool
    let canDelete: Bool
    let onActivate: () -> Void
    let onSetDefault: () -> Void
    let onDelete: () -> Void

    var body: some View {
        AppCard(accentColor: "AppPrimary", showAccentStripe: isActive, elevation: .flat) {
            HStack(spacing: 12) {
                AppIconCircle(systemName: "mappin.circle.fill", colorName: isActive ? "AppPrimary" : "AppTextSecondary", size: 40)
                VStack(alignment: .leading, spacing: 4) {
                    Text(location.name)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                    HStack(spacing: 6) {
                        if location.isDefault {
                            AppChip(text: "Default", icon: "star.fill", tint: "AppAccent")
                        }
                        if isActive {
                            AppChip(text: "Active", icon: "checkmark", tint: "AppPrimary")
                        }
                    }
                }
                Spacer()
                Menu {
                    Button("Set Active", action: onActivate)
                    Button("Set Default", action: onSetDefault)
                    if canDelete {
                        Button("Delete", role: .destructive, action: onDelete)
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
        }
    }
}
