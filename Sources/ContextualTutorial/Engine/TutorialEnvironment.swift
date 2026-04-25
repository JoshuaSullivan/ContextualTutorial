import SwiftUI

extension EnvironmentValues {
    /// Identifier of the step currently being presented by the enclosing
    /// ``SwiftUICore/View/contextualTutorial(isActive:)`` modifier, or `nil`
    /// when no tour is active.
    ///
    /// Read by ``SwiftUICore/View/tutorialScrollContainer()`` to drive a
    /// `ScrollPosition` to the active step.
    @Entry var tutorialCurrentStepID: UUID? = nil

    /// The nearest enclosing ``TutorialScrollScope``, set by
    /// ``SwiftUICore/View/tutorialScrollContainer()``. Tagged views read it
    /// to register their frame with the scope so the container can scroll
    /// to them when they become the active step.
    @Entry var tutorialScrollScope: TutorialScrollScope? = nil
}
