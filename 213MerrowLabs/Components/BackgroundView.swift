import SwiftUI

struct BackgroundView: View {
  var body: some View {
    ZStack {
      AppGradients.background

      Circle()
        .fill(Color("AppPrimary").opacity(0.09))
        .frame(width: 300, height: 300)
        .offset(x: -130, y: -220)

      Circle()
        .fill(Color("AppAccent").opacity(0.07))
        .frame(width: 240, height: 240)
        .offset(x: 150, y: 320)

      LinearGradient(
        colors: [Color("AppPrimary").opacity(0.04), Color.clear],
        startPoint: .top,
        endPoint: .center
      )
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .ignoresSafeArea()
  }
}
