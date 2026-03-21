# Animations & Transitions

## Overview

Animations in Sparrow are declarative and CSS-based. The server sends the target state, and the browser handles the animation. No JavaScript animation logic required (except for the thin presence/scroll observers in the client runtime). Respects `prefers-reduced-motion` automatically.

## Animation Curves

All animation APIs accept a `SparrowAnimation` curve that controls timing.

### Standard Curves

```swift
.animation(.default)             // fast ease-out (0.35s)
.animation(.linear)              // constant speed
.animation(.easeIn)              // slow start
.animation(.easeOut)             // slow end
.animation(.easeInOut)           // slow start and end
```

### Spring Animations

Springs use `linear()` CSS timing function with analytically-computed sample points. No JavaScript runtime — pure CSS.

```swift
.animation(.spring())                        // default spring (0.5s, no bounce)
.animation(.spring(duration: 0.5, bounce: 0.3)) // custom spring
.animation(.bouncy)                          // preset: 0.5s, bounce 0.3
.animation(.snappy)                          // preset: 0.3s, bounce 0.15
.animation(.smooth)                          // preset: 0.5s, no bounce
```

- `duration` — perceptual duration in seconds (how long the animation feels)
- `bounce` — 0.0 = critically damped (no overshoot), 0.3 = moderate bounce, 0.5 = very bouncy

### Modifiers on Curves

```swift
.animation(.spring().speed(2.0))             // 2x playback speed
.animation(.easeInOut.delay(0.2))            // 200ms delay before starting
.animation(.linear.repeatForever())          // loop forever
.animation(.easeInOut.repeatCount(3, autoreverses: true))
```

## Implicit Animations — `.animation(_:)`

Animate any property change on a view:

```swift
Text("Count: \(count)")
    .font(count > 10 ? .title : .body)
    .animation(.spring)

VStack { content }
    .background(isError ? .error : .surface)
    .animation(.easeInOut)
```

When a state change causes the server to re-render with different classes/styles, the element already has `transition` CSS applied, so the browser animates automatically.

```swift
// Track a specific value — identical behavior in Sparrow since
// CSS transitions fire on any property change, but communicates intent.
.animation(.spring, value: count)
```

## `withAnimation()` — Global Animated State Changes

Wraps a state mutation so ALL resulting DOM changes animate:

```swift
Button("Toggle") {
    withAnimation(.spring) {
        isExpanded.toggle()
    }
}
```

The server includes the animation curve in the WebSocket patch message. The client temporarily adds `transition` CSS to the root, applies the patch, and the browser animates all changes.

## Transitions — `.transition(_:)`

Animate views entering or leaving the view tree:

```swift
if showCard {
    ProfileCard(user: user)
        .transition(.opacity)
}
```

### Built-In Transitions

| Transition | Effect |
|---|---|
| `.opacity` | Fade in/out |
| `.scale` | Scale from 0 to 1 / 1 to 0 |
| `.slide(.leading)` | Slide in from left / out to left |
| `.slide(.trailing)` | Slide in from right / out to right |
| `.slide(.top)` | Slide in from top / out to top |
| `.slide(.bottom)` | Slide in from bottom / out to bottom |
| `.move(.leading)` | Alias for slide |
| `.push(.leading)` | Slide + fade combined |
| `.identity` | No transition (instant appear/disappear) |

### Combining Transitions

```swift
.transition(.opacity.combined(with: .scale))
.transition(.opacity.combined(with: .slide(.bottom)))
```

### Asymmetric Transitions

Different animation for entering vs. leaving:

```swift
.transition(.asymmetric(
    insertion: .push(edge: .trailing),
    removal: .push(edge: .leading)
))
```

### Custom Animation on Transition

```swift
.transition(.opacity, animation: .spring(duration: 0.5, bounce: 0.2))
```

### How It Works

1. Server renders the view wrapped in a div with "from" classes and data attributes
2. Client runtime's presence system detects `data-sparrow-enter` on the new element
3. On the next animation frame, swaps from-classes → to-classes
4. CSS transition handles the animation
5. On removal, swaps to exit classes, waits for `transitionend`, then removes the element

```html
<!-- Server renders: -->
<div id="v3" class="sp-opacity-0" style="transition-property: opacity; ..."
     data-sparrow-enter="sp-opacity-1" data-sparrow-enter-from="sp-opacity-0"
     data-sparrow-exit="sp-opacity-0" data-sparrow-exit-from="sp-opacity-1">
  <div>Profile Card content</div>
</div>

<!-- Client swaps on enter: removes sp-opacity-0, adds sp-opacity-1 -->
<!-- Browser transitions opacity from 0 → 1 -->
```

## Content Transitions — `.contentTransition(_:)`

Animate content changes within a view (not the view itself entering/leaving):

```swift
Text("Score: \(score)")
    .contentTransition(.numericText())

Image(icon)
    .contentTransition(.opacity)
```

| Type | Effect |
|---|---|
| `.opacity` | Crossfade between old and new content |
| `.numericText()` | Roll counter effect (slide up/down) |
| `.numericText(countsDown: true)` | Roll counter going down |
| `.interpolate` | Best-effort morph between content |

## Scroll Transitions — `.scrollTransition(_:)`

Animate views as they scroll into the viewport:

```swift
ForEach(items) { item in
    ItemCard(item)
        .scrollTransition(transition: .opacity)
}

// Combine transitions:
HeroImage(url)
    .scrollTransition(
        transition: .opacity.combined(with: .scale),
        animation: .spring
    )
```

Uses `IntersectionObserver` — no scroll event listeners, no jank. Elements start in the "from" state and transition to the "to" state when they enter the viewport.

## Matched Geometry — `.matchedGeometryEffect(id:in:)`

Shared element transitions between views using the View Transition API:

```swift
// List view
ForEach(items) { item in
    ItemThumbnail(item)
        .matchedGeometryEffect(id: item.id, in: "items")
}

// Detail view
ItemHero(item)
    .matchedGeometryEffect(id: item.id, in: "items")
```

When navigating between views, elements with the same `id` and namespace morph between their old and new positions/sizes. Maps to CSS `view-transition-name`.

## Phase Animator

Cycle through a sequence of phases automatically, generating CSS @keyframes:

```swift
PhaseAnimator([false, true]) { phase in
    Circle()
        .opacity(phase ? 1.0 : 0.3)
        .scaleEffect(phase ? 1.0 : 0.8)
} animation: { _ in .easeInOut }
```

The renderer evaluates the content at each phase, diffs the CSS, and generates a `@keyframes` rule that loops continuously. No JavaScript animation runtime.

## Keyframe Animator

Drive a view with explicit keyframe tracks:

```swift
KeyframeAnimator(
    initialValue: AnimState(y: 0, scale: 1),
    repeating: true
) { value in
    Circle()
        .offset(y: value.y)
        .scaleEffect(value.scale)
} keyframes: {
    KeyframeTrack(cssProperty: "transform") {
        SpringKeyframe(-50, duration: 0.3)
        SpringKeyframe(0, duration: 0.5)
    }
}
```

Each track maps to a CSS property. The renderer computes the combined timeline and generates a single `@keyframes` rule with per-keyframe timing functions.

## Symbol Effects — `.symbolEffect(_:)`

Repeating animation effects for icons and views:

```swift
Icon(.activity)
    .symbolEffect(.pulse)

Image("loading")
    .symbolEffect(.rotate)
```

| Effect | Animation |
|---|---|
| `.bounce` | Bouncing up and down |
| `.pulse` | Pulsing opacity |
| `.wiggle` | Side-to-side wiggle |
| `.breathe` | Slow scale + opacity pulse |
| `.rotate` | Continuous rotation |

## Navigation Transitions — `.navigationTransition(_:)`

Control the animation when navigating between pages:

```swift
struct ContentView: View {
    var body: some View {
        VStack { ... }
            .navigationTransition(.slide)
    }
}
```

| Style | Effect |
|---|---|
| `.automatic` | Default crossfade |
| `.slide` | Slide from leading edge |
| `.zoom` | Zoom from matched geometry source |

Uses the View Transition API. Page and content replacements are wrapped in `document.startViewTransition()` when the browser supports it, enabling smooth animated transitions between pages.

## Rive Animations

First-class support for [Rive](https://rive.app) interactive animations. The Rive WASM runtime is lazy-loaded from CDN only when a `RiveAnimation` view is present — zero cost when unused.

### Basic Playback

```swift
RiveAnimation("onboarding-hero")
    .frame(width: 400, height: 300)
```

Place `.riv` files in your assets directory. Use `.init(url:)` for remote files.

### State Machines

Rive state machines let you drive animation states from server-side Swift:

```swift
RiveAnimation("like-button", stateMachine: "Toggle")
    .riveInput("isLiked", value: isLiked)
    .onRiveEvent("liked") { isLiked = true }
    .riveFit(.cover)
```

When `isLiked` changes on the server, the client runtime updates the state machine input and the animation transitions automatically.

Supported input types:
- **Boolean**: `.riveInput("isActive", value: true)`
- **Number**: `.riveInput("score", value: 42.0)`
- **Trigger**: `.riveTrigger("explode")`

### Configuration

```swift
RiveAnimation("hero", stateMachine: "Main")
    .artboard("Mobile")          // select artboard
    .riveFit(.contain)           // contain, cover, fill, fitWidth, fitHeight, none, scaleDown
    .autoplay(false)             // don't play until triggered
```

### How It Works

1. Server renders `<canvas data-sparrow-rive="/assets/hero.riv" ...>`
2. Client runtime detects the element and lazy-loads `@rive-app/canvas` from CDN (~150KB, cached)
3. Rive instance initializes on the canvas with the specified state machine
4. State machine inputs are read from `data-sparrow-rive-inputs` (JSON)
5. On state change, server patches the inputs attribute → client applies new values
6. Rive Events (authored in the Rive editor) forward to the server via WebSocket

## Lottie Animations

First-class support for [Lottie](https://airbnb.io/lottie/) animations (After Effects → JSON). The lottie-web library is lazy-loaded from CDN only when a `LottieAnimation` view is present.

### Basic Playback

```swift
LottieAnimation("loading-spinner")
    .looping()
    .frame(width: 200, height: 200)
```

Place Lottie JSON files in your assets directory. Use `.init(url:)` for remote files.

### Configuration

```swift
LottieAnimation("celebration")
    .looping()                   // loop continuously
    .speed(1.5)                  // playback speed
    .direction(.reverse)         // play backwards
    .lottieRenderer(.canvas)     // svg (default) or canvas
    .onComplete { showNext() }   // called when non-looping animation ends
    .onLoopComplete { count += 1 } // called after each loop cycle
```

### How It Works

1. Server renders `<div data-sparrow-lottie="/assets/spinner.json" ...>`
2. Client runtime detects the element and lazy-loads `lottie-web` from CDN (~250KB, cached)
3. Lottie instance renders the animation (SVG or Canvas) inside the container
4. Complete/loopComplete events forward to the server via WebSocket

## Reduced Motion

All animations respect `prefers-reduced-motion` automatically. The stylesheet includes:

```css
@media (prefers-reduced-motion: reduce) {
    *, *::before, *::after {
        animation-duration: 0.01ms !important;
        animation-iteration-count: 1 !important;
        transition-duration: 0.01ms !important;
        scroll-behavior: auto !important;
    }
}
```

When reduced motion is enabled:
- CSS transitions complete instantly (near-zero duration)
- CSS animations play once and stop
- Content still appears/disappears, but without motion
- Rive/Lottie animations are unaffected (they run in their own runtime)
- No developer action needed
