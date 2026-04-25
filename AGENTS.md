# Integrating ContextualTutorial — Agent Guide

You are implementing an onboarding / feature-discovery tour in an existing iOS app using the [`ContextualTutorial`](https://github.com/JoshuaSullivan/ContextualTutorial) Swift package. Follow these steps.

## Prerequisites — verify before starting

- Target is **iOS 18.0+**. If the app deploys to anything lower, stop and tell the user.
- Project uses **SwiftUI**. UIKit-only screens cannot host tutorial hints.
- Swift 6 strict concurrency — the package assumes it.

## Step 1: Add the package dependency

Add via SPM. The package URL is `https://github.com/JoshuaSullivan/ContextualTutorial.git`.

- **Xcode project** → File → Add Package Dependencies → paste URL → `Up to Next Major`, `0.1.0`. Add `ContextualTutorial` to the app target.
- **Package.swift** → add `.package(url: "https://github.com/JoshuaSullivan/ContextualTutorial.git", from: "0.1.0")` to `dependencies`, and `"ContextualTutorial"` to the relevant target's `dependencies`.

Then `import ContextualTutorial` in each file that uses it.

## Step 2: Identify the views to tag

Work with the user to pick controls worth explaining. Good candidates are non-obvious affordances: custom gesture targets, icon-only buttons, indirect interactions. Don't tag every button — five to ten hints per tour is plenty.

For each, note:
- Title (short — 2-4 words, e.g. "Pan").
- Description (one sentence — what it does or how to use it).
- Desired order, if any. Use explicit `order:` when natural top-to-bottom reading wouldn't match the instructional flow.

## Step 3: Tag the views

Attach `.tutorialHint(order:title:description:)` directly on the view to highlight — not on a container above it. The cutout will match the exact frame of the view you attach to.

```swift
Button("Pan", systemImage: "hand.draw") { /* … */ }
    .tutorialHint(
        order: 1,
        title: "Pan",
        description: "Drag anywhere on the map to move the view."
    )
```

- `title` and `description` accept `LocalizedStringKey`. If the app uses a String Catalog, the literals become keys automatically. If the user has a catalog with `extractionState: manual` symbol keys, mirror that convention.
- `order:` is optional. Rules: non-nil orders come first (ascending); nil orders come next (top-to-bottom). See README for the full sort.
- Avoid tagging views inside conditional branches that might not be present when the tour starts — the step list is frozen at session start.

## Step 4: Add the root-level trigger

The `.contextualTutorial(isActive:)` modifier must be attached to an **ancestor** of every tagged view. Typically that's the top-level view in your scene or main screen. Attach it **outside** `NavigationStack` if possible — the overlay should sit above the whole navigation chrome.

```swift
@State private var showTutorial = false

var body: some View {
    MainScreen()
        .contextualTutorial(isActive: $showTutorial)
}
```

Drive `showTutorial` from wherever makes sense — a "?" button in the toolbar, a first-launch `onAppear`, a menu item, etc.

```swift
.toolbar {
    Button("Help", systemImage: "questionmark.circle") {
        showTutorial = true
    }
}
```

## Step 5: Handle scroll views (only if tagged views are inside one)

If any tagged view lives inside a `ScrollView`, `List`, or `Form`, add `.tutorialScrollContainer()` on that scroll view. Without it, steps below the fold won't be reachable during the tour.

```swift
ScrollView {
    VStack {
        ControlRow().tutorialHint(title: "Zoom", description: "…")
        // more rows, possibly off-screen
    }
}
.tutorialScrollContainer()
```

How it works: the container injects a `TutorialScrollScope` into the environment. Every descendant `.tutorialHint` registers its frame with that scope via a named coordinate space. When the engine activates a step the scope knows about, the container computes a scroll-y offset that centers the step in the visible area and animates the scroll programmatically. There's no `.id()` involvement, so anchor capture for the cutout is unaffected.

Safe to apply to multiple scroll views — each owns its own scope, and a hint registers with the **innermost** enclosing scope only.

## Step 6: Styling (optional)

Skip unless the user asks for customization or the defaults clash with the app's look. Apply `.tutorialStyle(_:)` **above** `.contextualTutorial(isActive:)`:

```swift
MainScreen()
    .contextualTutorial(isActive: $showTutorial)
    .tutorialStyle(
        TutorialStyle(
            cutoutCornerRadius: 16,
            dimColor: .black.opacity(0.7),
            bubbleBackground: AnyShapeStyle(.thickMaterial)
        )
    )
```

See `TutorialStyle` for all fields (cutout padding, bubble spacing/max width/corner radius, transition, animation).

## Verification checklist — run these before reporting done

1. `xcodebuild -scheme <AppScheme> -destination 'platform=iOS Simulator,name=<some iPhone>' build` must succeed.
2. Launch the app. Trigger the tour. Confirm:
   - The first hint's cutout aligns with the tagged view (no offset).
   - The bubble appears on a sensible side (below preferred; above/leading/trailing as needed).
   - Tapping the dim area advances through each step.
   - The persistent X in the corner dismisses at any time.
   - If any step is inside a scroll view, the scroll view scrolls to it before the cutout appears.
   - Ordering matches intent — explicit `order:` steps appear first, rest top-to-bottom.
3. Rotate the device mid-tour. The cutout should animate to the new position, not flicker or snap.
4. If you can't visually verify (headless environment), say so explicitly rather than claiming success.

## Common pitfalls

- **`.contextualTutorial` attached too deep in the hierarchy.** Overlay needs to cover the full screen. Put it on the outermost scene-root view.
- **Tagged view is a `Spacer` or `EmptyView`.** Cutout will be zero-sized and the overlay will fall back to dim-only. Tag a concrete view.
- **Tagged views inside `LazyVStack` / `List`.** Off-screen rows aren't rendered, so they don't publish anchor preferences and don't register with the scroll scope. The engine never sees them as steps. If you need a deterministic tour over many items, prefer a non-lazy `VStack` inside the `ScrollView`. Lazy containers work for items that have already been scrolled into view at least once during the session.
- **Dynamic Type truncation in bubble.** The bubble caps at `bubbleMaxWidth` (default 280). If description is long, the bubble grows vertically — fine unless the screen is very short. Adjust via `TutorialStyle.bubbleMaxWidth` if needed.
- **Multiple tours in the same hierarchy.** Nested `.contextualTutorial` is technically allowed (inner sees its subtree's preferences only) but not recommended. Use a single tour and sequence the steps.
- **Tagging controls that modify state (e.g. TextField).** The overlay blocks hit-testing, so users cannot interact with the underlying control during the tour. Tutorial hints describe — they don't drive interaction.
- **Forgetting `.tutorialScrollContainer()` on a `ScrollView`.** Steps below the initial fold won't scroll into view, and you'll see a "Step is off-screen; falling back to dim-only" debug log when those steps activate.
- **Secrets in titles/descriptions.** Don't include user-specific PII in hint strings — they're static per build.

## When to push back

- User asks for onboarding on a screen with heavy lazy rendering (long feed, infinite scroll). Lazy off-screen rows don't register with the scroll scope, so the engine can't reach them. Steer the tour toward fixed-count controls or non-lazy stacks.
- User wants a step to advance *only* when the user taps the highlighted control itself. This library advances on any overlay tap. Don't try to hack around it — file a feature request instead.
- User wants deeply custom bubble UI (connector line, arrow, per-step buttons). The current bubble is a fixed layout. Flag the limitation; connector lines are on the roadmap but not shipping.
