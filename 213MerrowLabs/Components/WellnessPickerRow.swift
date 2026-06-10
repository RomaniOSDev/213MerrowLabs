import SwiftUI

struct WellnessPickerRow: View {
    @Binding var selected: WellnessNote?

    var body: some View {
        Picker("Wellness", selection: Binding(
            get: { selected ?? .normal },
            set: { selected = $0 }
        )) {
            ForEach(WellnessNote.allCases) { note in
                Label(note.title, systemImage: note.systemImage).tag(note)
            }
        }
        .foregroundStyle(Color("AppTextPrimary"))
    }
}
