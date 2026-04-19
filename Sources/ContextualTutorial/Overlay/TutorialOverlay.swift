import SwiftUI

/// Composition layer for an active tutorial step. Draws the dim + cutout,
/// positions the bubble, and handles tap-to-advance. Also hosts the
/// persistent dismiss button in the top-trailing corner.
struct TutorialOverlay: View {

    /// Overlay's own geometry proxy, used to resolve the current step's
    /// anchor to a concrete rect in overlay coordinates.
    let proxy: GeometryProxy

    /// The currently-active step, or `nil` if the tour is idle.
    let step: TutorialStep?

    let style: TutorialStyle

    /// Called when the user taps anywhere on the dim/cutout area.
    let onAdvance: () -> Void

    /// Called when the user taps the persistent dismiss button.
    let onDismiss: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            TutorialOverlayContent(proxy: proxy, step: step, style: style)
                .contentShape(.rect)
                .onTapGesture(count: 1) {
                    onAdvance()
                }

            TutorialDismissButton(action: onDismiss)
                .padding()
        }
        .animation(style.animation, value: step?.id)
    }
}

/// Dim + cutout + bubble for the current step. Separated so `TutorialOverlay`
/// can attach tap-to-advance at the right layer without the dismiss button
/// swallowing the gesture.
private struct TutorialOverlayContent: View {
    let proxy: GeometryProxy
    let step: TutorialStep?
    let style: TutorialStyle

    var body: some View {
        if let step, let rect = resolvedRect(for: step) {
            let inflated = rect.insetBy(dx: -style.cutoutPadding, dy: -style.cutoutPadding)
            ZStack {
                TutorialDimmingView(cutout: inflated, style: style)
                TutorialBubble(
                    step: step,
                    cutout: inflated,
                    containerSize: proxy.size,
                    safeArea: proxy.safeAreaInsets,
                    style: style
                )
                .id(step.id)
                .transition(style.transition)
            }
        } else {
            style.dimColor
        }
    }

    private func resolvedRect(for step: TutorialStep) -> CGRect? {
        guard let anchor = step.anchor else { return nil }
        let rect = proxy[anchor]
        guard rect.width > 0, rect.height > 0 else {
            TutorialLog.engine.debug("Step has zero-sized frame; skipping bubble placement.")
            return nil
        }
        let container = CGRect(origin: .zero, size: proxy.size)
        guard rect.intersects(container) else {
            TutorialLog.engine.debug("Step is off-screen; falling back to dim-only.")
            return nil
        }
        return rect
    }
}
