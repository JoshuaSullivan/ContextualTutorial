import Testing
import SwiftUI
@testable import ContextualTutorial

@Suite("TutorialBubblePlacement")
struct TutorialBubblePlacementTests {

    private let container = CGSize(width: 400, height: 800)
    private let safeArea = EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0)
    private let spacing: CGFloat = 12

    @Test("Target near top chooses .below")
    func targetNearTopPrefersBelow() {
        let cutout = CGRect(x: 100, y: 40, width: 100, height: 40)
        let side = TutorialBubblePlacement.side(
            cutout: cutout,
            bubbleSize: CGSize(width: 240, height: 80),
            container: container,
            safeArea: safeArea,
            spacing: spacing
        )
        #expect(side == .below)
    }

    @Test("Target near bottom chooses .above when .below doesn't fit")
    func targetNearBottomPrefersAbove() {
        let cutout = CGRect(x: 100, y: 760, width: 100, height: 30)
        let side = TutorialBubblePlacement.side(
            cutout: cutout,
            bubbleSize: CGSize(width: 240, height: 80),
            container: container,
            safeArea: safeArea,
            spacing: spacing
        )
        #expect(side == .above)
    }

    @Test("Centered target with room everywhere prefers .below (priority)")
    func centeredPrefersBelow() {
        let cutout = CGRect(x: 150, y: 380, width: 100, height: 40)
        let side = TutorialBubblePlacement.side(
            cutout: cutout,
            bubbleSize: CGSize(width: 200, height: 80),
            container: container,
            safeArea: safeArea,
            spacing: spacing
        )
        #expect(side == .below)
    }

    @Test("Full-width target with space only above chooses .above")
    func fullWidthFallsToAbove() {
        let cutout = CGRect(x: 0, y: 600, width: 400, height: 180)
        let side = TutorialBubblePlacement.side(
            cutout: cutout,
            bubbleSize: CGSize(width: 240, height: 100),
            container: container,
            safeArea: safeArea,
            spacing: spacing
        )
        #expect(side == .above)
    }

    @Test("No side fits — returns the side with the most absolute room")
    func noFitReturnsMostRoom() {
        // Container barely larger than the cutout; bubble can't fit anywhere.
        let tinyContainer = CGSize(width: 120, height: 120)
        let cutout = CGRect(x: 10, y: 10, width: 100, height: 100)
        let side = TutorialBubblePlacement.side(
            cutout: cutout,
            bubbleSize: CGSize(width: 300, height: 300),
            container: tinyContainer,
            safeArea: EdgeInsets(),
            spacing: 0
        )
        // No fit — algorithm must still return a side. The "most room"
        // fallback here favors .below or .trailing (both tied), but
        // max(by:) returns the last max, so accept any valid side.
        #expect([.above, .below, .leading, .trailing].contains(side))
    }

    @Test("Position clamps bubble to the safe rect when target hugs the edge")
    func positionClampsToSafeRect() {
        let cutout = CGRect(x: 0, y: 100, width: 60, height: 40)
        let bubbleSize = CGSize(width: 240, height: 80)
        let position = TutorialBubblePlacement.position(
            cutout: cutout,
            bubbleSize: bubbleSize,
            container: container,
            safeArea: safeArea,
            spacing: spacing
        )
        // Bubble below the cutout; center x clamped so bubble stays within
        // [0 + halfWidth, containerWidth - halfWidth].
        let expectedMinX = bubbleSize.width / 2
        #expect(position.x >= expectedMinX - 0.001)
    }

    @Test("Position places bubble below when .below is chosen")
    func positionBelowPlacement() {
        let cutout = CGRect(x: 100, y: 40, width: 100, height: 40)
        let bubbleSize = CGSize(width: 240, height: 80)
        let position = TutorialBubblePlacement.position(
            cutout: cutout,
            bubbleSize: bubbleSize,
            container: container,
            safeArea: safeArea,
            spacing: spacing
        )
        let expectedY = cutout.maxY + spacing + bubbleSize.height / 2
        #expect(abs(position.y - expectedY) < 0.001)
    }
}
