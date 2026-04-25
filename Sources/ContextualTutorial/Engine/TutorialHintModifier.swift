import SwiftUI

/// Internal view modifier implementing ``SwiftUICore/View/tutorialHint(order:title:description:)``.
///
/// Two responsibilities:
/// 1. Publishes a single-element `[TutorialStep]` via ``TutorialPreferenceKey``
///    carrying a `.bounds` anchor — which the overlay host later resolves
///    against its geometry to position the cutout and bubble.
/// 2. If a ``TutorialScrollScope`` is present in the environment (i.e. the
///    tagged view is inside a `tutorialScrollContainer`), captures its own
///    frame in the scope's named coordinate space and registers it with
///    the scope so the container can scroll to it on activation.
///
/// The modifier deliberately does NOT apply `.id(_:)` to the tagged view.
/// `.id(_:)` introduces an identity boundary that interferes with anchor
/// preference resolution in ancestor overlays, leaving cutouts misaligned
/// or unresolved. Scroll coordination instead uses point-based programmatic
/// scroll driven by the container, so no id matching is required.
struct TutorialHintModifier: ViewModifier {

    /// Stable id for this registration site across view re-evaluations.
    @State private var id = UUID()

    @Environment(\.tutorialScrollScope) private var scrollScope

    let order: Int?
    let title: LocalizedStringKey
    let description: LocalizedStringKey

    func body(content: Content) -> some View {
        // Capture the scope's coordinate-space name as a Sendable String so
        // the geometry transform closure (which strict concurrency treats
        // as Sendable) doesn't have to reach into main-actor-isolated state.
        let coordSpaceName = scrollScope?.coordinateSpaceName

        return content
            .anchorPreference(
                key: TutorialPreferenceKey.self,
                value: .bounds
            ) { anchor in
                [
                    TutorialStep(
                        id: id,
                        order: order,
                        title: title,
                        description: description,
                        anchor: anchor
                    )
                ]
            }
            .onGeometryChange(for: CGRect.self) { proxy in
                guard let coordSpaceName else { return .zero }
                return proxy.frame(in: .named(coordSpaceName))
            } action: { newFrame in
                guard let scope = scrollScope else { return }
                if newFrame.width > 0, newFrame.height > 0 {
                    scope.register(stepID: id, frame: newFrame)
                } else {
                    scope.unregister(stepID: id)
                }
            }
            .onDisappear {
                scrollScope?.unregister(stepID: id)
            }
    }
}
