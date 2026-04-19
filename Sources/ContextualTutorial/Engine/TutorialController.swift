import SwiftUI

/// State machine that drives a single tutorial session. Created as `@State`
/// inside the internal tutorial modifier so its lifetime is tied to the
/// enclosing view.
///
/// The controller snapshots its step list at ``start(with:yProvider:)`` time
/// and ignores any subsequent preference updates for the remainder of the
/// session. This matches the spec requirement that mid-session view changes
/// don't disturb an in-flight tour.
@MainActor
@Observable
final class TutorialController {

    /// Steps in display order, as produced by ``TutorialOrdering`` at the
    /// start of the session.
    private(set) var sortedSteps: [TutorialStep] = []

    /// Zero-based index into ``sortedSteps``.
    private(set) var currentIndex: Int = 0

    /// Whether a tour is currently in progress.
    private(set) var isRunning: Bool = false

    /// The step currently being presented, or `nil` when the tour is not
    /// running or the index is out of bounds.
    var currentStep: TutorialStep? {
        guard isRunning, sortedSteps.indices.contains(currentIndex) else { return nil }
        return sortedSteps[currentIndex]
    }

    /// Begins a tour with the supplied steps. Returns immediately (as a
    /// no-op) if `steps` is empty.
    ///
    /// - Parameters:
    ///   - steps: The steps collected from the preference key.
    ///   - yProvider: Resolves each step's vertical position for ordering.
    func start(with steps: [TutorialStep], yProvider: (TutorialStep) -> CGFloat) {
        guard !steps.isEmpty else {
            TutorialLog.engine.warning("contextualTutorial activated with no registered steps.")
            sortedSteps = []
            currentIndex = 0
            isRunning = false
            return
        }
        sortedSteps = TutorialOrdering.sort(
            steps: steps,
            orderProvider: { $0.order },
            yProvider: yProvider
        )
        currentIndex = 0
        isRunning = true
    }

    /// Advances to the next step. Returns `true` if there is still a step to
    /// show after advancing; returns `false` if the tour has finished (the
    /// caller should then dismiss the overlay).
    @discardableResult
    func advance() -> Bool {
        guard isRunning else { return false }
        let next = currentIndex + 1
        if next >= sortedSteps.count {
            stop()
            return false
        }
        currentIndex = next
        return true
    }

    /// Ends the tour and resets internal state.
    func stop() {
        sortedSteps = []
        currentIndex = 0
        isRunning = false
    }
}
