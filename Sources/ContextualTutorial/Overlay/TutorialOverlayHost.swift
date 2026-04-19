import SwiftUI

/// Hosts the tutorial overlay at the same layer as `.contextualTutorial`'s
/// content. Owns the `GeometryReader` that resolves per-step anchors via
/// `proxy[anchor]`.
///
/// `GeometryReader` is used here — rather than the typically-preferred
/// `onGeometryChange` / `visualEffect` / `containerRelativeFrame` — because
/// the anchor subscript (`proxy[step.anchor]`) requires the `GeometryProxy`
/// value itself, which none of the lighter-weight alternatives expose.
struct TutorialOverlayHost: View {
    let steps: [TutorialStep]
    @Binding var isActive: Bool
    let controller: TutorialController
    let style: TutorialStyle

    var body: some View {
        GeometryReader { proxy in
            TutorialOverlay(
                proxy: proxy,
                step: controller.currentStep,
                style: style,
                onAdvance: {
                    handleAdvance()
                },
                onDismiss: {
                    handleDismiss()
                }
            )
            .opacity(controller.isRunning ? 1 : 0)
            .allowsHitTesting(controller.isRunning)
            .onChange(of: isActive, initial: true) { _, nowActive in
                if nowActive {
                    beginSession(proxy: proxy)
                } else {
                    controller.stop()
                }
            }
        }
        // Apply ignoresSafeArea on the GeometryReader so the proxy's
        // coordinate space spans the full overlay render area. This keeps
        // anchor-resolved rects and rendered shape positions in the same
        // space — otherwise the proxy lives in safe-area coordinates while
        // the shape renders in full-screen coordinates, shifting the
        // cutout by the safe-area inset.
        .ignoresSafeArea()
    }

    private func beginSession(proxy: GeometryProxy) {
        controller.start(with: steps) { step in
            guard let anchor = step.anchor else { return 0 }
            return proxy[anchor].minY
        }
        // If start is a no-op (empty steps), immediately turn off isActive
        // so the caller's binding reflects reality.
        if !controller.isRunning {
            isActive = false
        }
    }

    private func handleAdvance() {
        if controller.advance() == false {
            isActive = false
        }
    }

    private func handleDismiss() {
        isActive = false
    }
}
