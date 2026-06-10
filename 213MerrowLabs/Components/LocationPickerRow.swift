import SwiftUI

struct LocationPickerRow: View {
    @EnvironmentObject private var storage: AppStorageManager
    @Binding var selectedLocationId: UUID?

    var body: some View {
        Picker("Location", selection: Binding(
            get: { selectedLocationId ?? storage.selectedLocationId ?? storage.locations.first?.id },
            set: { selectedLocationId = $0 }
        )) {
            ForEach(storage.locations) { location in
                Text(location.name).tag(Optional(location.id))
            }
        }
        .foregroundStyle(Color("AppTextPrimary"))
    }
}
