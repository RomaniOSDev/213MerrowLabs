import SwiftUI

struct SuccessCheckmark: View {
    @Binding var isVisible: Bool

    var body: some View {
        if isVisible {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color("AppAccent"))
                .transition(.scale.combined(with: .opacity))
                .onAppear {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {}
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isVisible = false
                        }
                    }
                }
        }
    }
}

struct SuccessCheckmarkOverlay: ViewModifier {
    @Binding var showSuccess: Bool

    func body(content: Content) -> some View {
        ZStack {
            content
            if showSuccess {
                SuccessCheckmark(isVisible: $showSuccess)
            }
        }
    }
}

extension View {
    func successOverlay(show: Binding<Bool>) -> some View {
        modifier(SuccessCheckmarkOverlay(showSuccess: show))
    }
}
