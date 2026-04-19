import SwiftUI

/// A single registered tutorial step.
///
/// Instances are produced by the internal hint modifier and aggregated up
/// the view tree via ``TutorialPreferenceKey``. Each step carries the target
/// view's bounds as an `Anchor<CGRect>`, which the overlay host resolves
/// against its `GeometryProxy` to place the cutout and bubble.
struct TutorialStep: Identifiable, Equatable {
    /// Stable identifier for this registration site.
    ///
    /// The hint modifier stores this as `@State`, so it survives view
    /// re-evaluations and lets SwiftUI recognize the same step across
    /// preference-collection passes.
    let id: UUID

    /// Optional explicit ordering value. See
    /// ``TutorialOrdering/sort(steps:yProvider:)`` for the full rules.
    let order: Int?

    /// Heading shown in the hint bubble.
    let title: LocalizedStringKey

    /// Body text shown beneath the title.
    let description: LocalizedStringKey

    /// Anchor representing the tagged view's bounds, resolved at the overlay
    /// host.
    ///
    /// Always populated by the internal hint modifier. Nil only in
    /// test-constructed values, which never flow through overlay rendering.
    let anchor: Anchor<CGRect>?
}
