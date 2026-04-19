/// # ContextualTutorial
///
/// A SwiftUI library for overlaying guided hints on top of an app's UI.
///
/// Tag any view with ``SwiftUICore/View/tutorialHint(order:title:description:)`` to
/// register it as a tutorial step. Wrap a root view with
/// ``SwiftUICore/View/contextualTutorial(isActive:)`` and drive a `Bool` binding
/// to run the tour. While running, the engine dims the surrounding UI, cuts a
/// rounded rectangle around the active step's view, and displays an info bubble
/// next to it.
///
/// See ``TutorialStyle`` to customize colors, corner radii, spacing, and
/// animations via the ``SwiftUICore/View/tutorialStyle(_:)`` modifier.
