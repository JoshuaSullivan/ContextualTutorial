import SwiftUI

extension View {

    /// Registers this view as a step in any enclosing
    /// ``SwiftUICore/View/contextualTutorial(isActive:)`` session.
    ///
    /// During an active session, the engine dims the rest of the UI, cuts
    /// a rounded rectangle around this view, and shows a bubble with
    /// `title` and `description` next to it.
    ///
    /// ## Ordering
    ///
    /// - Steps with a non-nil `order` are presented **before** any step
    ///   without one.
    /// - Within each group, ties break by ascending y position
    ///   (top-to-bottom).
    /// - Within the non-nil group, `order` itself is the primary sort key.
    ///
    /// - Parameters:
    ///   - order: Optional explicit ordering value. Leave `nil` to
    ///     participate in pure top-to-bottom ordering.
    ///   - title: Heading shown in the hint bubble.
    ///   - description: Body text shown beneath the title.
    /// - Returns: A view that publishes its frame as a tutorial step.
    public func tutorialHint(
        order: Int? = nil,
        title: LocalizedStringKey,
        description: LocalizedStringKey
    ) -> some View {
        modifier(
            TutorialHintModifier(
                order: order,
                title: title,
                description: description
            )
        )
    }
}
