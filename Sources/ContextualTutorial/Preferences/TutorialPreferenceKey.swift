import SwiftUI

/// Aggregates ``TutorialStep`` values contributed by each tagged view up the
/// SwiftUI view tree, so the root `contextualTutorial` modifier can read the
/// complete step list via `overlayPreferenceValue`.
///
/// The reduce is append-only; the final display order is computed once at
/// session start by ``TutorialOrdering``.
struct TutorialPreferenceKey: PreferenceKey {
    nonisolated(unsafe) static let defaultValue: [TutorialStep] = []

    static func reduce(value: inout [TutorialStep], nextValue: () -> [TutorialStep]) {
        value.append(contentsOf: nextValue())
    }
}
