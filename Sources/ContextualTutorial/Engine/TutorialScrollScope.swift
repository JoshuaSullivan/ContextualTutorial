import SwiftUI

/// Reference shared between a single ``SwiftUICore/View/tutorialScrollContainer()``
/// and the ``SwiftUICore/View/tutorialHint(order:title:description:)`` modifiers
/// nested inside it.
///
/// The container creates a scope and injects it into the environment via
/// ``EnvironmentValues/tutorialScrollScope``. Each descendant hint reads
/// the same scope, captures its own frame in the scope's named coordinate
/// space, and registers that frame here. When the engine activates a step,
/// the container asks the scope where to scroll.
///
/// Frames are stored in the scope's coordinate space, which is attached to
/// the scroll view itself — so frame y measures from the scroll view's
/// top-left, in screen units. To convert to the scroll view's content
/// coordinates (what `ScrollPosition.scrollTo(point:anchor:)` expects), the
/// scope adds the current scroll offset, which the container keeps in sync
/// via `onScrollGeometryChange`.
@MainActor
@Observable
public final class TutorialScrollScope {

    /// Name of the SwiftUI coordinate space attached by the container to its
    /// scroll view. Hints capture their frames in this space.
    public let coordinateSpaceName: String

    /// Latest vertical scroll offset, kept in sync by the container.
    public var scrollOffsetY: CGFloat = 0

    /// Map of step id → frame relative to the scroll view's screen origin.
    private(set) var registeredFrames: [UUID: CGRect] = [:]

    /// Creates a new scope with a unique coordinate-space name.
    public init() {
        self.coordinateSpaceName = "ContextualTutorialScrollScope-\(UUID().uuidString)"
    }

    /// Records or replaces the frame for a step in this scope.
    func register(stepID: UUID, frame: CGRect) {
        registeredFrames[stepID] = frame
    }

    /// Removes a step's recorded frame. Called when a tagged view leaves
    /// the hierarchy or its frame collapses to zero.
    func unregister(stepID: UUID) {
        registeredFrames.removeValue(forKey: stepID)
    }

    /// Whether the given step is registered with this scope.
    public func contains(stepID: UUID) -> Bool {
        registeredFrames[stepID] != nil
    }

    /// Returns the y in scroll-content coordinates suitable for centering
    /// the registered step via `ScrollPosition.scrollTo(point:anchor:)`
    /// with `anchor: .center`. Returns `nil` if the step isn't registered.
    func contentCenterY(forStepID stepID: UUID) -> CGFloat? {
        guard let frame = registeredFrames[stepID] else { return nil }
        return frame.midY + scrollOffsetY
    }
}
