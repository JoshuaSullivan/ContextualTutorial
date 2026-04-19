import SwiftUI

extension View {

    /// Attaches contextual-tutorial scroll coordination to a `ScrollView` or
    /// `List`.
    ///
    /// When the active step's tagged view is inside this scroll container,
    /// the engine drives a `ScrollPosition` to bring the step into view
    /// before rendering the cutout. Works with lazy content (`LazyVStack`,
    /// `List`), which `ScrollPosition` will render as needed.
    ///
    /// Apply once per scroll view that may contain tutorial steps:
    ///
    /// ```swift
    /// ScrollView {
    ///     LazyVStack {
    ///         Text("Pan").tutorialHint(title: "Pan", description: "...")
    ///         Text("Zoom").tutorialHint(title: "Zoom", description: "...")
    ///     }
    /// }
    /// .tutorialScrollContainer()
    /// ```
    ///
    /// Applying the modifier to multiple scroll views in the same hierarchy
    /// is safe — each only reacts to steps whose ids it recognizes.
    public func tutorialScrollContainer() -> some View {
        modifier(TutorialScrollContainerModifier())
    }
}

/// Internal modifier implementing ``SwiftUICore/View/tutorialScrollContainer()``.
/// Owns a `ScrollPosition` bound to the container and reacts to changes in
/// the current step's id to scroll the target into view.
struct TutorialScrollContainerModifier: ViewModifier {
    @State private var position = ScrollPosition(idType: UUID.self)
    @Environment(\.tutorialCurrentStepID) private var currentStepID

    func body(content: Content) -> some View {
        content
            .scrollPosition($position, anchor: .center)
            .onChange(of: currentStepID) { _, newID in
                guard let newID else { return }
                withAnimation(.smooth) {
                    position.scrollTo(id: newID, anchor: .center)
                }
            }
    }
}
