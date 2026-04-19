import SwiftUI

/// Shape that combines a full outer rectangle with an inner rounded
/// rectangle, drawn with the even-odd fill rule so the inner rect is
/// punched out of the outer fill.
///
/// `animatableData` exposes both the cutout rect and its corner radius, so
/// transitioning between steps within `withAnimation` moves the cutout
/// smoothly rather than snapping.
struct TutorialCutoutShape: Shape {

    /// Rectangle to punch out (in the shape's local coordinate space).
    var cutout: CGRect

    /// Corner radius of the punched-out rectangle.
    var cornerRadius: CGFloat

    var animatableData: AnimatablePair<CGRect.AnimatableData, CGFloat> {
        get { AnimatablePair(cutout.animatableData, cornerRadius) }
        set {
            cutout.animatableData = newValue.first
            cornerRadius = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRect(rect)
        path.addRoundedRect(
            in: cutout,
            cornerSize: CGSize(width: cornerRadius, height: cornerRadius)
        )
        return path
    }
}
