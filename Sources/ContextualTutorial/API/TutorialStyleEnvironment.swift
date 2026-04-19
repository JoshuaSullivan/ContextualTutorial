import SwiftUI

extension EnvironmentValues {
    /// Style used by the active contextual tutorial overlay.
    @Entry public var tutorialStyle: TutorialStyle = .default
}

extension View {
    /// Applies a ``TutorialStyle`` to the contextual tutorial overlay.
    ///
    /// Has no effect on views not enclosed in a
    /// ``SwiftUICore/View/contextualTutorial(isActive:)`` modifier.
    public func tutorialStyle(_ style: TutorialStyle) -> some View {
        environment(\.tutorialStyle, style)
    }
}
