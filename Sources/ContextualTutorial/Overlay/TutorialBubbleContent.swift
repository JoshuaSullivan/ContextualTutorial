import SwiftUI

/// Title + description stack rendered inside the hint bubble. Split into its
/// own view struct rather than a computed property so SwiftUI can diff it
/// cleanly.
struct TutorialBubbleContent: View {
    let title: LocalizedStringKey
    let description: LocalizedStringKey

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
                .bold()
            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
