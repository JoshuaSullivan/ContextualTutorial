import SwiftUI

/// Internal view modifier implementing ``SwiftUICore/View/tutorialHint(order:title:description:)``.
///
/// Publishes a single-element `[TutorialStep]` via ``TutorialPreferenceKey``
/// carrying a `.bounds` anchor — which the overlay host later resolves
/// against its geometry to position the cutout and bubble.
struct TutorialHintModifier: ViewModifier {

    /// Stable id for this registration site across view re-evaluations.
    @State private var id = UUID()

    let order: Int?
    let title: LocalizedStringKey
    let description: LocalizedStringKey

    func body(content: Content) -> some View {
        content.anchorPreference(
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
    }
}
