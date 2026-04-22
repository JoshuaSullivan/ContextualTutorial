import SwiftUI

extension View {

    /// Attaches contextual-tutorial scroll coordination to a `ScrollView` or
    /// `List`.
    ///
    /// When the active step's tagged view is inside this scroll container,
    /// the engine scrolls the step into view before rendering the cutout.
    /// Works with lazy content (`LazyVStack`, `List`) and with tagged views
    /// nested deep inside non-lazy containers.
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
    /// is safe — each only reacts to steps whose ids exist in its subtree.
    public func tutorialScrollContainer() -> some View {
        modifier(TutorialScrollContainerModifier())
    }
}

/// Internal modifier implementing ``SwiftUICore/View/tutorialScrollContainer()``.
///
/// Uses `ScrollViewReader` rather than iOS 17+'s `.scrollPosition(id:)` /
/// `ScrollPosition`, because the id emitted by `.tutorialHint` is typically
/// attached deep inside the scroll view's content (nested containers like
/// `VStack > Section > Row > Control`). `.scrollPosition(id:)` only resolves
/// ids on direct children of the scrollable content container;
/// `ScrollViewReader.scrollTo(_:anchor:)` walks the full subtree and finds
/// nested ids reliably.
struct TutorialScrollContainerModifier: ViewModifier {
    @Environment(\.tutorialCurrentStepID) private var currentStepID

    func body(content: Content) -> some View {
        ScrollViewReader { proxy in
            content
                .onChange(of: currentStepID) { _, newID in
                    guard let newID else { return }
                    withAnimation(.smooth) {
                        proxy.scrollTo(newID, anchor: .center)
                    }
                }
        }
    }
}
