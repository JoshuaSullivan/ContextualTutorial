import Testing
import SwiftUI
@testable import ContextualTutorial

@MainActor
@Suite("TutorialController")
struct TutorialControllerTests {

    private func makeStep(_ name: String, order: Int? = nil) -> TutorialStep {
        TutorialStep(
            id: UUID(),
            order: order,
            title: LocalizedStringKey(name),
            description: "",
            anchor: nil
        )
    }

    private func yZero(_ step: TutorialStep) -> CGFloat { 0 }

    @Test("Starting with empty steps leaves controller idle")
    func emptyStartIsNoOp() {
        let controller = TutorialController()
        controller.start(with: [], yProvider: yZero)
        #expect(controller.isRunning == false)
        #expect(controller.sortedSteps.isEmpty)
        #expect(controller.currentStep == nil)
    }

    @Test("Starting with steps activates the controller at index 0")
    func startActivates() {
        let controller = TutorialController()
        let steps = [makeStep("a"), makeStep("b"), makeStep("c")]
        controller.start(with: steps, yProvider: yZero)
        #expect(controller.isRunning)
        #expect(controller.currentIndex == 0)
        #expect(controller.sortedSteps.count == 3)
        #expect(controller.currentStep != nil)
    }

    @Test("Advance walks through each step and returns false at the end")
    func advanceWalksAndFinishes() {
        let controller = TutorialController()
        let steps = [makeStep("a"), makeStep("b"), makeStep("c")]
        controller.start(with: steps, yProvider: yZero)

        #expect(controller.advance() == true)
        #expect(controller.currentIndex == 1)

        #expect(controller.advance() == true)
        #expect(controller.currentIndex == 2)

        #expect(controller.advance() == false)
        #expect(controller.isRunning == false)
    }

    @Test("Stop resets state regardless of current progress")
    func stopResets() {
        let controller = TutorialController()
        controller.start(with: [makeStep("a"), makeStep("b")], yProvider: yZero)
        _ = controller.advance()
        controller.stop()
        #expect(controller.isRunning == false)
        #expect(controller.sortedSteps.isEmpty)
        #expect(controller.currentIndex == 0)
        #expect(controller.currentStep == nil)
    }

    @Test("Starting a new session replaces the previous one cleanly")
    func restartReplacesSnapshot() {
        let controller = TutorialController()
        controller.start(with: [makeStep("a"), makeStep("b")], yProvider: yZero)
        _ = controller.advance()
        #expect(controller.currentIndex == 1)

        let fresh = [makeStep("x"), makeStep("y"), makeStep("z")]
        controller.start(with: fresh, yProvider: yZero)
        #expect(controller.currentIndex == 0)
        #expect(controller.sortedSteps.count == 3)
        #expect(controller.isRunning)
    }

    @Test("Advance before start is a safe no-op")
    func advanceBeforeStartNoOp() {
        let controller = TutorialController()
        #expect(controller.advance() == false)
        #expect(controller.isRunning == false)
    }
}
