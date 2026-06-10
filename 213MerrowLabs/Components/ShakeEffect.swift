import SwiftUI

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 8
    var shakes: CGFloat = 2
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(translationX: amount * sin(animatableData * .pi * shakes), y: 0)
        )
    }
}

extension View {
    func shake(trigger: Int) -> some View {
        modifier(ShakeModifier(trigger: trigger))
    }
}

private struct ShakeModifier: ViewModifier {
    let trigger: Int
    @State private var shakeAmount: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .modifier(ShakeEffect(animatableData: shakeAmount))
            .onChange(of: trigger) { _ in
                withAnimation(.default) {
                    shakeAmount = 1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    shakeAmount = 0
                }
            }
    }
}
