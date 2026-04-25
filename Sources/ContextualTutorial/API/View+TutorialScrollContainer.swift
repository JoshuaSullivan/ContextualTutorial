import SwiftUI

extension View {

    /// Attaches contextual-tutorial scroll coordination to a `ScrollView` or
    /// `List`.
    ///
    /// When the engine activates a step whose tagged view is inside this
    /// scroll container, the container scrolls the step into the visible
    /// region before the cutout renders. Works with lazy content
    /// (`LazyVStack`, `List`) and with hints nested deep inside non-lazy
    /// containers — scrolling is driven by frame measurement, not by id
    /// matching, so the depth and structural identity of the tagged view
    /// don't affect reachability.
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
    /// Multiple scroll containers in the same hierarchy are supported. Each
    /// owns its own scope; descendant hints register with the nearest
    /// enclosing scope, and only that scope reacts to their activation.
    public func tutorialScrollContainer() -> some View {
        modifier(TutorialScrollContainerModifier())
    }
}

/// Pair of scroll-view metrics that the container needs to translate a
/// registered hint frame into a scroll offset.
private struct ScrollMetrics: Equatable {
    var offsetY: CGFloat
    var visibleHeight: CGFloat
}

/// Internal modifier implementing ``SwiftUICore/View/tutorialScrollContainer()``.
///
/// Owns:
/// - A ``TutorialScrollScope`` published into the environment so descendant
///   hints can register their frames in the scope's named coordinate space.
/// - A `ScrollPosition` bound to the modified scroll view, used to scroll
///   programmatically by y offset.
///
/// On activation of a step that the scope has a registered frame for, the
/// container computes the scroll offset that centers that frame in the
/// visible area, then animates the scroll.
struct TutorialScrollContainerModifier: ViewModifier {
    @State private var scope = TutorialScrollScope()
    @State private var scrollPosition = ScrollPosition()
    @State private var metrics = ScrollMetrics(offsetY: 0, visibleHeight: 0)
    @Environment(\.tutorialCurrentStepID) private var currentStepID

    func body(content: Content) -> some View {
        content
            .coordinateSpace(.named(scope.coordinateSpaceName))
            .scrollPosition($scrollPosition)
            .environment(\.tutorialScrollScope, scope)
            .onScrollGeometryChange(for: ScrollMetrics.self) { geometry in
                ScrollMetrics(
                    offsetY: geometry.contentOffset.y,
                    visibleHeight: geometry.containerSize.height
                )
            } action: { (_: ScrollMetrics, newMetrics: ScrollMetrics) in
                metrics = newMetrics
                scope.scrollOffsetY = newMetrics.offsetY
            }
            .onChange(of: currentStepID) { (_: UUID?, newID: UUID?) in
                guard let newID,
                      let centerY = scope.contentCenterY(forStepID: newID)
                else { return }
                let targetOffsetY = centerY - metrics.visibleHeight / 2
                withAnimation(.smooth) {
                    scrollPosition.scrollTo(y: targetOffsetY)
                }
            }
    }
}
