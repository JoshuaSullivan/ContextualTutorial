import SwiftUI

/// The four sides of a cutout that a hint bubble can be placed on, relative
/// to the target view.
enum TutorialBubbleSide: Sendable {
    case above
    case below
    case leading
    case trailing
}

/// Pure placement algorithm for the hint bubble. Chooses a side and computes
/// a center point that keeps the bubble inside the safe rect whenever
/// possible.
///
/// Priority — when multiple sides can fit the bubble, the algorithm prefers
/// `below → above → trailing → leading` (matching common coach-mark
/// conventions). If no side fits, it falls back to whichever side has the
/// most absolute room.
enum TutorialBubblePlacement {

    /// Picks the best side for the bubble.
    ///
    /// - Parameters:
    ///   - cutout: The (already-padded) target frame in overlay coordinates.
    ///   - bubbleSize: The bubble's measured size.
    ///   - container: The overlay's total size.
    ///   - safeArea: The overlay's safe-area insets.
    ///   - spacing: Gap between the cutout and the bubble.
    static func side(
        cutout: CGRect,
        bubbleSize: CGSize,
        container: CGSize,
        safeArea: EdgeInsets,
        spacing: CGFloat
    ) -> TutorialBubbleSide {
        let safe = safeRect(container: container, safeArea: safeArea)

        let roomAbove = cutout.minY - safe.minY - spacing
        let roomBelow = safe.maxY - cutout.maxY - spacing
        let roomLeading = cutout.minX - safe.minX - spacing
        let roomTrailing = safe.maxX - cutout.maxX - spacing

        let candidates: [(side: TutorialBubbleSide, room: CGFloat, fits: Bool)] = [
            (.below, roomBelow, roomBelow >= bubbleSize.height),
            (.above, roomAbove, roomAbove >= bubbleSize.height),
            (.trailing, roomTrailing, roomTrailing >= bubbleSize.width),
            (.leading, roomLeading, roomLeading >= bubbleSize.width)
        ]

        if let fitting = candidates.first(where: \.fits) {
            return fitting.side
        }
        return candidates.max(by: { $0.room < $1.room })?.side ?? .below
    }

    /// Computes the center position for the bubble on the chosen side.
    static func position(
        cutout: CGRect,
        bubbleSize: CGSize,
        container: CGSize,
        safeArea: EdgeInsets,
        spacing: CGFloat
    ) -> CGPoint {
        let chosen = side(
            cutout: cutout,
            bubbleSize: bubbleSize,
            container: container,
            safeArea: safeArea,
            spacing: spacing
        )
        let safe = safeRect(container: container, safeArea: safeArea)
        let halfWidth = bubbleSize.width / 2
        let halfHeight = bubbleSize.height / 2

        switch chosen {
        case .above:
            return CGPoint(
                x: clamp(cutout.midX, min: safe.minX + halfWidth, max: safe.maxX - halfWidth),
                y: cutout.minY - spacing - halfHeight
            )
        case .below:
            return CGPoint(
                x: clamp(cutout.midX, min: safe.minX + halfWidth, max: safe.maxX - halfWidth),
                y: cutout.maxY + spacing + halfHeight
            )
        case .leading:
            return CGPoint(
                x: cutout.minX - spacing - halfWidth,
                y: clamp(cutout.midY, min: safe.minY + halfHeight, max: safe.maxY - halfHeight)
            )
        case .trailing:
            return CGPoint(
                x: cutout.maxX + spacing + halfWidth,
                y: clamp(cutout.midY, min: safe.minY + halfHeight, max: safe.maxY - halfHeight)
            )
        }
    }

    private static func safeRect(container: CGSize, safeArea: EdgeInsets) -> CGRect {
        CGRect(
            x: safeArea.leading,
            y: safeArea.top,
            width: max(0, container.width - safeArea.leading - safeArea.trailing),
            height: max(0, container.height - safeArea.top - safeArea.bottom)
        )
    }

    private static func clamp(_ value: CGFloat, min lower: CGFloat, max upper: CGFloat) -> CGFloat {
        // Guard against inverted bounds from pathological inputs (container
        // smaller than bubble + safe area).
        guard lower <= upper else { return (lower + upper) / 2 }
        return Swift.min(Swift.max(value, lower), upper)
    }
}
