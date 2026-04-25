import Testing
import CoreGraphics
import Foundation
@testable import ContextualTutorial

@MainActor
@Suite("TutorialScrollScope")
struct TutorialScrollScopeTests {

    @Test("Newly created scope has unique coordinate-space names")
    func uniqueCoordSpaceName() {
        let a = TutorialScrollScope()
        let b = TutorialScrollScope()
        #expect(a.coordinateSpaceName != b.coordinateSpaceName)
    }

    @Test("Unregistered step returns nil center y")
    func unregisteredReturnsNil() {
        let scope = TutorialScrollScope()
        #expect(scope.contentCenterY(forStepID: UUID()) == nil)
    }

    @Test("Registered step at offset 0 returns frame midY")
    func registeredAtZeroOffset() {
        let scope = TutorialScrollScope()
        let id = UUID()
        scope.register(stepID: id, frame: CGRect(x: 0, y: 100, width: 200, height: 50))
        #expect(scope.contentCenterY(forStepID: id) == 125)
    }

    @Test("Center y accounts for scroll offset")
    func registeredWithOffset() {
        let scope = TutorialScrollScope()
        let id = UUID()
        scope.register(stepID: id, frame: CGRect(x: 0, y: 100, width: 200, height: 50))
        scope.scrollOffsetY = 200
        // Frame is in scope's space (relative to scroll view origin); to get
        // content y, we add the current scroll offset.
        #expect(scope.contentCenterY(forStepID: id) == 325)
    }

    @Test("Re-registering replaces the prior frame")
    func reregisterReplaces() {
        let scope = TutorialScrollScope()
        let id = UUID()
        scope.register(stepID: id, frame: CGRect(x: 0, y: 0, width: 100, height: 20))
        scope.register(stepID: id, frame: CGRect(x: 0, y: 500, width: 100, height: 40))
        #expect(scope.contentCenterY(forStepID: id) == 520)
    }

    @Test("Unregister removes the step")
    func unregisterRemoves() {
        let scope = TutorialScrollScope()
        let id = UUID()
        scope.register(stepID: id, frame: CGRect(x: 0, y: 100, width: 100, height: 40))
        #expect(scope.contains(stepID: id))
        scope.unregister(stepID: id)
        #expect(!scope.contains(stepID: id))
        #expect(scope.contentCenterY(forStepID: id) == nil)
    }
}
