import SwiftUI

/// Customization surface for a ``SwiftUICore/View/contextualTutorial(isActive:)``
/// session.
///
/// Apply via ``SwiftUICore/View/tutorialStyle(_:)`` anywhere in the view
/// hierarchy above the tutorial root:
///
/// ```swift
/// ContentView()
///     .contextualTutorial(isActive: $showing)
///     .tutorialStyle(
///         TutorialStyle(dimColor: .black.opacity(0.7))
///     )
/// ```
///
/// The type deliberately isn't `Sendable` because `AnyTransition` and
/// `Animation` aren't. Environment values don't require `Sendable`.
public struct TutorialStyle {

    /// Corner radius used for the rounded-rectangle cutout.
    public var cutoutCornerRadius: CGFloat

    /// Additional inset applied around each target's frame before drawing
    /// the cutout — gives the highlight a comfortable halo.
    public var cutoutPadding: CGFloat

    /// Fill for the dim overlay that surrounds the cutout.
    public var dimColor: Color

    /// Gap between the cutout edge and the hint bubble.
    public var bubbleSpacing: CGFloat

    /// Maximum width for the hint bubble. The bubble grows vertically beyond
    /// this width for longer descriptions.
    public var bubbleMaxWidth: CGFloat

    /// Corner radius of the hint bubble.
    public var bubbleCornerRadius: CGFloat

    /// Background style applied to the hint bubble.
    public var bubbleBackground: AnyShapeStyle

    /// Transition used when moving between steps.
    public var transition: AnyTransition

    /// Animation used when moving the cutout and cross-fading the bubble.
    public var animation: Animation

    /// Creates a tutorial style. All parameters have reasonable defaults.
    public init(
        cutoutCornerRadius: CGFloat = 12,
        cutoutPadding: CGFloat = 8,
        dimColor: Color = .black.opacity(0.55),
        bubbleSpacing: CGFloat = 12,
        bubbleMaxWidth: CGFloat = 280,
        bubbleCornerRadius: CGFloat = 14,
        bubbleBackground: AnyShapeStyle = AnyShapeStyle(.regularMaterial),
        transition: AnyTransition = .opacity.combined(with: .scale(scale: 0.98)),
        animation: Animation = .smooth(duration: 0.28)
    ) {
        self.cutoutCornerRadius = cutoutCornerRadius
        self.cutoutPadding = cutoutPadding
        self.dimColor = dimColor
        self.bubbleSpacing = bubbleSpacing
        self.bubbleMaxWidth = bubbleMaxWidth
        self.bubbleCornerRadius = bubbleCornerRadius
        self.bubbleBackground = bubbleBackground
        self.transition = transition
        self.animation = animation
    }

    /// The default style. Equivalent to `TutorialStyle()`.
    ///
    /// Marked `nonisolated(unsafe)` because `TutorialStyle` holds
    /// `AnyTransition` / `Animation`, neither of which is `Sendable`. The
    /// value itself is deep-immutable via its initializer, so the unchecked
    /// escape is accurate in practice.
    nonisolated(unsafe) public static let `default` = TutorialStyle()
}
