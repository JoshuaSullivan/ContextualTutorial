import SwiftUI

/// Internal view modifier implementing ``SwiftUICore/View/contextualTutorial(isActive:)``.
///
/// Collects all steps registered by descendant `.tutorialHint` modifiers via
/// `overlayPreferenceValue`, then hands them off to a ``TutorialOverlayHost``
/// that renders the dim / cutout / bubble UI when `isActive` is `true`.
struct ContextualTutorialModifier: ViewModifier {
    @Binding var isActive: Bool
    @State private var controller = TutorialController()
    @Environment(\.tutorialStyle) private var style

    func body(content: Content) -> some View {
        content.overlayPreferenceValue(TutorialPreferenceKey.self) { steps in
            TutorialOverlayHost(
                steps: steps,
                isActive: $isActive,
                controller: controller,
                style: style
            )
        }
    }
}
