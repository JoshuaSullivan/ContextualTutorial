# ContextualTutorial

A lightweight SwiftUI library for overlaying guided hints on top of your app's UI. Tag any view with a short title and description, then activate a tour that dims the surrounding interface, cuts a rounded rectangle around the tagged view, and displays an info bubble next to it.

Built for iOS 26 with Swift 6.2 and modern SwiftUI (`@Observable`, `@Entry`, anchor preferences).

## Requirements

- iOS 26.0+
- Swift 6.2+
- Xcode 26+

## Installation

Add the package to your project via Swift Package Manager:

```swift
.package(url: "https://github.com/JoshuaSullivan/ContextualTutorial.git", from: "0.1.0")
```

Then add `ContextualTutorial` as a dependency of the target that uses it.

## Usage

### 1. Tag views with hints

```swift
import ContextualTutorial
import SwiftUI

struct ProfileScreen: View {
    var body: some View {
        Form {
            Section("Profile") {
                Text("Ada Lovelace")
                    .tutorialHint(
                        order: 1,
                        title: "Your name",
                        description: "Tap here to change your display name."
                    )
                Text("Online")
                    .tutorialHint(
                        title: "Status",
                        description: "Shows whether you're available to chat."
                    )
            }
        }
    }
}
```

### 2. Activate a tour with a binding

```swift
struct RootView: View {
    @State private var showTutorial = false

    var body: some View {
        NavigationStack {
            ProfileScreen()
                .toolbar {
                    Button("Tour", systemImage: "questionmark.circle") {
                        showTutorial = true
                    }
                }
        }
        .contextualTutorial(isActive: $showTutorial)
    }
}
```

Tap anywhere on the overlay to advance to the next step. The final tap dismisses the tour. A persistent close button in the corner lets users quit at any time.

### 3. Customize the look

Attach `.tutorialStyle(_:)` anywhere above the `.contextualTutorial` modifier:

```swift
.contextualTutorial(isActive: $showTutorial)
.tutorialStyle(
    TutorialStyle(
        cutoutCornerRadius: 16,
        cutoutPadding: 12,
        dimColor: .black.opacity(0.65),
        bubbleMaxWidth: 320
    )
)
```

See ``TutorialStyle`` for the full list of customization points.

## How steps are ordered

Each call to `.tutorialHint` accepts an optional `order: Int?`. The engine snapshots every tagged view at the moment the tour starts and orders them as follows:

1. Steps with a non-nil `order` are presented **before** any step with a nil `order`.
2. Within the non-nil group, steps are sorted by `order` ascending. Ties break by ascending y (top-to-bottom).
3. Within the nil group, steps are sorted by ascending y (top-to-bottom).
4. The sort is stable — equal-key steps retain their registration order.

Mid-tour changes to the tagged views (e.g. conditional content appearing) are ignored until the next session.

## Architecture

- `.tutorialHint` is a `ViewModifier` that publishes a step via an anchor preference key. Each registration site stores a stable `UUID` via `@State`, so identity is preserved across view re-evaluations.
- `.contextualTutorial` collects the full step list at a common ancestor via `overlayPreferenceValue`, then hands it to a `@MainActor @Observable TutorialController` that manages session state.
- A custom `Shape` uses the even-odd fill rule to punch a rounded rectangle out of a full-screen dim layer. `AnimatableData` on the shape drives smooth cutout transitions between steps.
- The hint bubble self-measures via `onGeometryChange` and chooses a side (below → above → trailing → leading) using the most available space inside the safe area.

## Testing

The package ships with unit tests (Swift Testing) covering:

- Step ordering rules and sort stability
- Bubble-placement side selection and safe-area clamping
- Controller state transitions (start, advance, stop, restart)
- Cutout shape path generation and animatable-data round-trip

Run with:

```bash
xcodebuild -scheme ContextualTutorial -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

## License

MIT. See [LICENSE](LICENSE).
