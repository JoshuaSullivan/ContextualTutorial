import Testing
import SwiftUI
@testable import ContextualTutorial

@Suite("TutorialCutoutShape")
struct TutorialCutoutShapeTests {

    @Test("Path is non-empty for a sensible cutout")
    func pathIsNonEmpty() {
        let shape = TutorialCutoutShape(
            cutout: CGRect(x: 20, y: 20, width: 60, height: 40),
            cornerRadius: 8
        )
        let path = shape.path(in: CGRect(x: 0, y: 0, width: 200, height: 200))
        #expect(path.isEmpty == false)
    }

    @Test("Path bounding box covers the full container, not just the cutout")
    func pathCoversContainer() {
        let container = CGRect(x: 0, y: 0, width: 300, height: 300)
        let cutout = CGRect(x: 50, y: 50, width: 100, height: 60)
        let shape = TutorialCutoutShape(cutout: cutout, cornerRadius: 8)
        let path = shape.path(in: container)
        // The outer rectangle is added first, so the path's bounding rect
        // should match the container, not the cutout.
        #expect(path.boundingRect.width == container.width)
        #expect(path.boundingRect.height == container.height)
    }

    @Test("AnimatableData round-trips")
    func animatableDataRoundTrips() {
        var shape = TutorialCutoutShape(
            cutout: CGRect(x: 10, y: 20, width: 30, height: 40),
            cornerRadius: 6
        )
        let original = shape.animatableData
        shape.animatableData = original
        #expect(shape.cutout.origin.x == 10)
        #expect(shape.cutout.origin.y == 20)
        #expect(shape.cutout.size.width == 30)
        #expect(shape.cutout.size.height == 40)
        #expect(shape.cornerRadius == 6)
    }
}
