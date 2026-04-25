import SwiftUI

/// Internal view modifier implementing ``SwiftUICore/View/tutorialHint(order:title:description:)``.
///
/// Publishes a single-element `[TutorialStep]` via ``TutorialPreferenceKey``
/// carrying a `.bounds` anchor — which the overlay host later resolves
/// against its geometry to position the cutout and bubble.
///
/// For scroll-view coordination, we also attach a zero-sized invisible
/// companion view in `.background` carrying a matching `.id(stepID)`.
/// `ScrollViewReader.scrollTo(_:anchor:)` can find that id and scroll the
/// target into view. Keeping the id on a companion (rather than directly on
/// the tagged view via `.id(...)`) avoids the identity boundary that would
/// otherwise interfere with how the tagged view's anchor preference is
/// resolved in the overlay's coordinate space.
struct TutorialHintModifier: ViewModifier {

    /// Stable id for this registration site across view re-evaluations.
    @State private var id = UUID()

    let order: Int?
    let title: LocalizedStringKey
    let description: LocalizedStringKey

    func body(content: Content) -> some View {
        content
            .background(alignment: .center) {
                Color.clear
                    .frame(width: 0, height: 0)
                    .allowsHitTesting(false)
                    .id(id)
            }
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
    }
}
