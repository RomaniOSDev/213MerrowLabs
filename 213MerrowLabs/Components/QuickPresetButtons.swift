import SwiftUI

struct QuickPresetButtons: View {
  let onSelect: (TimeOfDayPreset) -> Void

  var body: some View {
    HStack(spacing: 10) {
      ForEach(TimeOfDayPreset.allCases) { preset in
        Button { onSelect(preset) } label: {
          VStack(spacing: 6) {
            AppIconCircle(systemName: preset.systemImage, colorName: "AppPrimary", size: 36)
            Text(preset.title)
              .font(.caption.bold())
              .lineLimit(1)
              .minimumScaleFactor(0.7)
          }
          .foregroundStyle(Color("AppTextPrimary"))
          .frame(maxWidth: .infinity)
          .padding(.vertical, 10)
          .appCardChrome(cornerRadius: 12, elevation: .flat, accentBorder: "AppPrimary")
        }
        .buttonStyle(PressableButtonStyle())
      }
    }
  }
}
