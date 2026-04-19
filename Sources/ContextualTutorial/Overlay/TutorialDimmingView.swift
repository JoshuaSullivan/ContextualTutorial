import SwiftUI

/// Applies the dim color over the full overlay, with the current step's
/// rounded-rectangle area punched out via ``TutorialCutoutShape``.
struct TutorialDimmingView: View {

    /// Frame to punch out, already inflated by the style's cutout padding.
    let cutout: CGRect

    let style: TutorialStyle

    var body: some View {
        TutorialCutoutShape(
            cutout: cutout,
            cornerRadius: style.cutoutCornerRadius
        )
        .fill(style.dimColor, style: FillStyle(eoFill: true))
    }
}
