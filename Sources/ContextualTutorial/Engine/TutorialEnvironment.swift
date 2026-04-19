import SwiftUI

extension EnvironmentValues {
    /// Identifier of the step currently being presented by the enclosing
    /// ``SwiftUICore/View/contextualTutorial(isActive:)`` modifier, or `nil`
    /// when no tour is active.
    ///
    /// Read by ``SwiftUICore/View/tutorialScrollContainer()`` to drive a
    /// `ScrollPosition` to the active step.
    @Entry var tutorialCurrentStepID: UUID? = nil
}
