import Testing
import CoreGraphics
@testable import ContextualTutorial

@Suite("TutorialOrdering")
struct TutorialOrderingTests {

    /// Lightweight stand-in for `TutorialStep` that lets tests pass plain
    /// values. The production call site binds `orderProvider` and
    /// `yProvider` to `TutorialStep.order` and resolved anchor y.
    private struct Stub: Equatable {
        let name: String
        let order: Int?
        let y: CGFloat
    }

    private func sort(_ input: [Stub]) -> [Stub] {
        TutorialOrdering.sort(
            steps: input,
            orderProvider: { $0.order },
            yProvider: { $0.y }
        )
    }

    @Test("Empty input yields empty output")
    func emptyInput() {
        #expect(sort([]) == [])
    }

    @Test("All nil orders sort by ascending y")
    func nilOnlyByY() {
        let input = [
            Stub(name: "c", order: nil, y: 300),
            Stub(name: "a", order: nil, y: 100),
            Stub(name: "b", order: nil, y: 200)
        ]
        let output = sort(input).map(\.name)
        #expect(output == ["a", "b", "c"])
    }

    @Test("Non-nil orders sort by ascending order")
    func nonNilByOrder() {
        let input = [
            Stub(name: "third", order: 3, y: 0),
            Stub(name: "first", order: 1, y: 999),
            Stub(name: "second", order: 2, y: 500)
        ]
        let output = sort(input).map(\.name)
        #expect(output == ["first", "second", "third"])
    }

    @Test("Ties in non-nil order break by ascending y")
    func nonNilTieByY() {
        let input = [
            Stub(name: "bottom", order: 1, y: 400),
            Stub(name: "top", order: 1, y: 100),
            Stub(name: "middle", order: 1, y: 250)
        ]
        let output = sort(input).map(\.name)
        #expect(output == ["top", "middle", "bottom"])
    }

    @Test("Non-nil orders always come before nil orders, regardless of y")
    func nonNilBeforeNil() {
        let input = [
            Stub(name: "nilTop", order: nil, y: 0),
            Stub(name: "ordered", order: 99, y: 9999),
            Stub(name: "nilBottom", order: nil, y: 500)
        ]
        let output = sort(input).map(\.name)
        #expect(output == ["ordered", "nilTop", "nilBottom"])
    }

    @Test("Sort is stable when all keys match")
    func stableOnEqualKeys() {
        let input = [
            Stub(name: "a", order: 5, y: 100),
            Stub(name: "b", order: 5, y: 100),
            Stub(name: "c", order: 5, y: 100)
        ]
        let output = sort(input).map(\.name)
        #expect(output == ["a", "b", "c"])
    }

    @Test("Mixed scenario — a full ordering example")
    func mixedScenario() {
        let input = [
            Stub(name: "nilMid", order: nil, y: 200),
            Stub(name: "nilTop", order: nil, y: 50),
            Stub(name: "order2Top", order: 2, y: 10),
            Stub(name: "order1", order: 1, y: 999),
            Stub(name: "order2Bottom", order: 2, y: 500),
            Stub(name: "nilBottom", order: nil, y: 900)
        ]
        let output = sort(input).map(\.name)
        #expect(output == [
            "order1",
            "order2Top",
            "order2Bottom",
            "nilTop",
            "nilMid",
            "nilBottom"
        ])
    }
}
