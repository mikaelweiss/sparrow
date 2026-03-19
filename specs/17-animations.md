# Animations & Transitions

## Overview

Animations in Sparrow are declarative and CSS-based. The server sends the target state, and the browser handles the animation. No JavaScript animation logic. Respects `prefers-reduced-motion` automatically.

## Transitions

Transitions animate views entering or leaving the view tree.

```swift
if showCard {
    ProfileCard(user: user)
        .transition(.opacity)           // fade in/out
}
```

When `showCard` changes from `false` to `true`, the card fades in. When it changes to `false`, it fades out.

### Built-In Transitions

| Transition | Effect |
|---|---|
| `.opacity` | Fade in/out |
| `.scale` | Scale from 0 to 1 / 1 to 0 |
| `.slide(.leading)` | Slide in from left / out to left |
| `.slide(.trailing)` | Slide in from right / out to right |
| `.slide(.top)` | Slide in from top / out to top |
| `.slide(.bottom)` | Slide in from bottom / out to bottom |
| `.move(.leading)` | Move in from left (no clip) |
| `.push(.leading)` | Push existing content to the right |

### Combining Transitions

```swift
.transition(.opacity.combined(with: .scale))
.transition(.opacity.combined(with: .slide(.bottom)))
```

### Asymmetric Transitions

Different animation for entering vs. leaving:

```swift
.transition(.asymmetric(
    insertion: .slide(.trailing).combined(with: .opacity),
    removal: .slide(.leading).combined(with: .opacity)
))
```

## Animation Curves

```swift
.animation(.easeInOut)                          // default
.animation(.easeIn)
.animation(.easeOut)
.animation(.linear)
.animation(.spring)                              // spring with default parameters
.animation(.spring(damping: 0.7, stiffness: 300))
.animation(.easeInOut(duration: 0.5))           // custom duration
```

Default duration is 0.3 seconds. Spring animations use CSS `spring()` if supported, falling back to a cubic-bezier approximation.

## Implicit Animations

Animate any modifier change:

```swift
Text("Count: \(count)")
    .font(count > 10 ? .title : .body)
    .animation(.spring)         // font change animates smoothly

VStack {
    content
}
.background(isError ? .error : .surface)
.animation(.easeInOut)          // background color change animates
```

When the modifier value changes due to a state update, the CSS transition handles the animation. The server sends the new class/style, and the browser transitions between old and new values.

## How It Works Under the Hood

### For transitions (enter/exit):

1. When a view enters the tree, the server sends it with both a "from" class and a "to" class
2. The client runtime adds the element to the DOM with the "from" state
3. On the next animation frame, the client swaps to the "to" class
4. CSS transition handles the animation

```html
<!-- Server sends: -->
<div id="v_0" class="card transition-opacity opacity-0" data-sparrow-enter="opacity-100">

<!-- Client immediately applies: -->
<div id="v_0" class="card transition-opacity opacity-100">
```

For removal, the process reverses — the client applies exit classes, waits for the CSS transition to complete, then removes the element.

### For implicit animations:

1. The server sends new CSS classes
2. The element already has `transition` properties from the `.animation()` modifier
3. The browser handles the transition automatically

```html
<!-- Before: -->
<div class="bg-surface transition-all duration-300">

<!-- After state change, server patches the class: -->
<div class="bg-error transition-all duration-300">

<!-- Browser animates between surface and error colors -->
```

## Page Transitions

Navigation between pages can be animated:

```swift
@main
struct MyApp: App {
    var body: some Scene {
        Routes {
            Page("/") { HomeView() }
            Page("/about") { AboutView() }
        }
        .pageTransition(.slide(.leading))
    }
}
```

Page transitions work by:
1. Server sends the new page content
2. Client holds both old and new content briefly
3. Old content animates out, new content animates in
4. Old content is removed from DOM

## Gesture-Driven Animations

```swift
Card()
    .gesture(
        Drag { offset in
            position += offset
        }
    )
    .gesture(
        Pinch { scale in
            zoom *= scale
        }
    )
```

Gesture-driven animations require client-side JavaScript for touch/mouse event tracking, which extends the client runtime.

## Reduced Motion

All animations respect `prefers-reduced-motion` automatically (see 16-accessibility.md). When reduced motion is enabled:
- Transitions complete instantly (duration set to ~0)
- Content still appears/disappears, but without motion
- No developer action needed
