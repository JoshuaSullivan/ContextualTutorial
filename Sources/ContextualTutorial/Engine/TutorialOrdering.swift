import CoreGraphics

/// Pure sort used by the tutorial engine to order steps at session start.
/// Lives in its own namespace and is generic over the step type so it can be
/// unit-tested without constructing a SwiftUI `Anchor`.
///
/// Rules, in order of precedence:
/// 1. Any step with a non-nil order is presented before any step with a nil
///    order.
/// 2. Within the non-nil group: ascending by order; ties broken by ascending
///    y (top-to-bottom).
/// 3. Within the nil group: ascending by y (top-to-bottom).
/// 4. The sort is stable: steps equal on every key retain their input order.
enum TutorialOrdering {
    /// Sorts `steps` using the rules above.
    ///
    /// - Parameters:
    ///   - steps: The steps to sort.
    ///   - orderProvider: Returns each step's optional explicit order.
    ///   - yProvider: Returns each step's vertical position in the overlay's
    ///     coordinate space. In production this is `proxy[step.anchor].minY`.
    /// - Returns: A new array of steps in display order.
    static func sort<Step>(
        steps: [Step],
        orderProvider: (Step) -> Int?,
        yProvider: (Step) -> CGFloat
    ) -> [Step] {
        let decorated = steps.map { (step: $0, y: yProvider($0), order: orderProvider($0)) }
        let explicit = decorated.filter { $0.order != nil }
        let implicit = decorated.filter { $0.order == nil }

        let sortedExplicit = explicit.sorted { lhs, rhs in
            let lo = lhs.order ?? 0
            let ro = rhs.order ?? 0
            if lo != ro { return lo < ro }
            return lhs.y < rhs.y
        }

        let sortedImplicit = implicit.sorted { $0.y < $1.y }

        return (sortedExplicit + sortedImplicit).map(\.step)
    }
}
