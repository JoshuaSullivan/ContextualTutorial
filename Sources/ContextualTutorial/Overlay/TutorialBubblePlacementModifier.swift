import SwiftUI

/// Positions the hint bubble next to the cutout. Measures the bubble's own
/// size via `onGeometryChange` (not `GeometryReader`) and asks
/// ``TutorialBubblePlacement`` where to center it.
///
/// While the measured size is still zero (first layout pass), the bubble is
/// hidden to avoid a visible jump from origin to its final position.
struct TutorialBubblePlacementModifier: ViewModifier {
    let cutout: CGRect
    let containerSize: CGSize
    let safeArea: EdgeInsets
    let spacing: CGFloat

    @State private var measuredSize: CGSize = .zero

    func body(content: Content) -> some View {
        content
            .onGeometryChange(for: CGSize.self) { proxy in
                proxy.size
            } action: { newSize in
                measuredSize = newSize
            }
            .position(
                TutorialBubblePlacement.position(
                    cutout: cutout,
                    bubbleSize: measuredSize,
                    container: containerSize,
                    safeArea: safeArea,
                    spacing: spacing
                )
            )
            .opacity(measuredSize == .zero ? 0 : 1)
    }
}
