import SwiftUI

/// Hint bubble for the active tutorial step. Sizes itself based on its
/// content and the style's `bubbleMaxWidth`, then positions itself via
/// ``TutorialBubblePlacementModifier``.
struct TutorialBubble: View {
    let step: TutorialStep
    let cutout: CGRect
    let containerSize: CGSize
    let safeArea: EdgeInsets
    let style: TutorialStyle

    var body: some View {
        TutorialBubbleContent(title: step.title, description: step.description)
            .padding()
            .frame(maxWidth: style.bubbleMaxWidth, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .background(
                style.bubbleBackground,
                in: .rect(cornerRadius: style.bubbleCornerRadius)
            )
            .shadow(radius: 8, y: 2)
            .modifier(
                TutorialBubblePlacementModifier(
                    cutout: cutout,
                    containerSize: containerSize,
                    safeArea: safeArea,
                    spacing: style.bubbleSpacing
                )
            )
            .accessibilityElement(children: .contain)
    }
}
