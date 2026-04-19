import SwiftUI

extension View {

    /// Activates a contextual tutorial over this view's content when
    /// `isActive` becomes `true`.
    ///
    /// The engine collects every descendant tagged with
    /// ``SwiftUICore/View/tutorialHint(order:title:description:)``, sorts
    /// them once at session start, and then steps through each one, dimming
    /// the surrounding UI and displaying an info bubble next to the
    /// highlighted view.
    ///
    /// ## Advancement
    ///
    /// - Tap anywhere on the overlay to advance to the next step.
    /// - The final tap dismisses the tour (sets `isActive` back to `false`).
    /// - A persistent dismiss button in the corner lets the user end the
    ///   tour at any time.
    ///
    /// ## Styling
    ///
    /// Customize the appearance by attaching ``SwiftUICore/View/tutorialStyle(_:)``
    /// anywhere above this modifier.
    ///
    /// - Parameter isActive: Binding that starts the tour on `true` and is
    ///   set back to `false` when the tour ends or is dismissed.
    public func contextualTutorial(isActive: Binding<Bool>) -> some View {
        modifier(ContextualTutorialModifier(isActive: isActive))
    }
}

#if DEBUG
private struct TutorialDemoScreen: View {
    @State private var showing = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    Text("Ada Lovelace")
                        .tutorialHint(
                            order: 1,
                            title: "Your name",
                            description: "Tap here to change your display name."
                        )
                    Text("Online")
                        .foregroundStyle(.secondary)
                        .tutorialHint(
                            title: "Status",
                            description: "Shows whether you're available to chat."
                        )
                }
                Section("Actions") {
                    Button("Sign out", systemImage: "rectangle.portrait.and.arrow.right") {}
                        .tutorialHint(
                            order: 99,
                            title: "Sign out",
                            description: "Ends your session on this device."
                        )
                }
            }
            .navigationTitle("ContextualTutorial")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Start tour", systemImage: "play.fill") {
                        showing = true
                    }
                }
            }
        }
        .contextualTutorial(isActive: $showing)
    }
}

#Preview("Tutorial demo") {
    TutorialDemoScreen()
}
#endif
