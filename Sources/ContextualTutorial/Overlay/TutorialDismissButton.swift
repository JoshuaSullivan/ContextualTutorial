import SwiftUI

/// Persistent close button rendered in a corner of the overlay. Remains
/// visible for every step so the user can quit the tour at any time.
///
/// The underlying `Button` swallows taps, so advancing (which happens on
/// taps elsewhere in the overlay) does not fire when the user hits the X.
struct TutorialDismissButton: View {
    let action: () -> Void

    var body: some View {
        Button("Dismiss tutorial", systemImage: "xmark.circle.fill", action: action)
            .labelStyle(.iconOnly)
            .font(.title)
            .foregroundStyle(.white, .black.opacity(0.5))
            .accessibilityLabel(Text("Dismiss tutorial"))
    }
}
