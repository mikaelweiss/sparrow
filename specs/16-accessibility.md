# Accessibility

## Overview

Sparrow produces accessible HTML by default. Semantic elements, ARIA attributes, keyboard navigation, focus management, and screen reader support are built into every component. The developer gets accessibility for free.

## Semantic HTML

The rendering pipeline outputs semantic HTML elements (see 10-rendering-pipeline.md). This means:
- Screen readers announce elements correctly (buttons as buttons, links as links, headings as headings)
- Keyboard navigation works natively (Tab moves between focusable elements, Enter activates buttons/links)
- Browser features work (password managers detect login forms, autofill works, find-on-page finds text)

## Built-In Component Accessibility

Every built-in component includes appropriate ARIA attributes:

| Component | HTML | ARIA |
|---|---|---|
| `Button("Save")` | `<button>Save</button>` | — (native semantics) |
| `Button(action:) { Icon(.plus) }` | `<button aria-label="Add">...</button>` | Label from context |
| `Toggle("Notifications", isOn: $on)` | `<input type="checkbox" role="switch">` | `aria-checked` |
| `Modal(isPresented: $show)` | `<dialog>` | `aria-modal="true"`, focus trap |
| `Alert(title: "Error")` | `<div role="alert">` | `aria-live="assertive"` |
| `Toast(message: "Saved")` | `<div role="status">` | `aria-live="polite"` |
| `Spinner()` | `<div role="status">` | `aria-label="Loading"` |
| `ProgressView(value:)` | `<progress>` | `aria-valuenow`, `aria-valuemin`, `aria-valuemax` |
| `NavigationLink` | `<a href="...">` | — (native semantics) |
| `TextField("Email", text:)` | `<input aria-label="Email">` | Label from placeholder |
| `Picker("Color", selection:)` | `<select aria-label="Color">` | — |

## Compiler Warnings

Sparrow produces compile-time warnings for common accessibility mistakes:

```swift
// ⚠️ Warning: Button with only an icon has no accessibility label.
//    Add .accessibilityLabel("description") to provide a label for screen readers.
Button(action: { delete() }) {
    Icon(.trash)
}

// ✓ No warning
Button(action: { delete() }) {
    Icon(.trash)
}
.accessibilityLabel("Delete item")
```

Warnings are produced for:
- Buttons/links with only icon children and no accessibility label
- Images without alt text (`.accessibilityLabel()` or `accessibilityHidden(true)`)
- Form inputs without labels
- Heading levels that skip (h1 → h3 without h2)

These are warnings, not errors — they don't block compilation.

## Focus Management

### After DOM Patches

The client runtime preserves focus after DOM patches (see 11-client-runtime.md). If the focused element is replaced, focus moves to the replacement element. If the focused element is removed, focus moves to the nearest focusable ancestor.

### Modal Focus Trap

When a `Modal` or `Sheet` is presented:
1. Focus moves to the first focusable element inside the modal
2. Tab cycling is trapped within the modal (Tab from last element goes to first)
3. Escape key dismisses the modal
4. On dismiss, focus returns to the element that triggered the modal

### Skip Navigation

Sparrow automatically includes a "Skip to content" link as the first focusable element on every page. It's visually hidden but appears on focus (for keyboard users). It jumps to the main content area, skipping the navigation.

## Keyboard Navigation

All interactive components support keyboard interaction:

| Component | Keyboard |
|---|---|
| Button | Enter/Space to activate |
| NavigationLink | Enter to navigate |
| Toggle | Space to toggle |
| Modal | Escape to dismiss |
| Menu | Arrow keys to navigate, Enter to select, Escape to close |
| Picker | Arrow keys to navigate options |
| TextField | Standard text input |
| Tabs | Arrow keys to switch tabs |

## Color Contrast

The default design system colors meet WCAG AA contrast ratios:
- Text on background: minimum 4.5:1
- Large text on background: minimum 3:1
- Interactive elements: minimum 3:1

When the developer overrides theme colors, Sparrow does not check contrast ratios (this would require runtime checks that add complexity). Documentation encourages maintaining AA contrast.

## Reduced Motion

The design system respects `prefers-reduced-motion`:

```css
@media (prefers-reduced-motion: reduce) {
    *, *::before, *::after {
        animation-duration: 0.01ms !important;
        transition-duration: 0.01ms !important;
    }
}
```

Animations are automatically disabled for users who have enabled reduced motion in their OS settings. No developer action needed.

## Accessibility Modifiers

```swift
// Custom label for screen readers
.accessibilityLabel("Close dialog")

// Additional hint
.accessibilityHint("Double-tap to dismiss")

// Override the role
.accessibilityRole(.button)

// Hide decorative elements from screen readers
.accessibilityHidden(true)

// Mark as a heading (for custom heading-like components)
.accessibilityHeading(.h2)

// Live region for dynamic content
.accessibilityLive(.polite)      // announced when convenient
.accessibilityLive(.assertive)   // announced immediately
```

## Form Accessibility

Forms automatically associate labels with inputs:

```swift
Form {
    TextField("Email", text: $email)
    // → <label for="email_input">Email</label><input id="email_input" ...>

    SecureField("Password", text: $password)
    // → <label for="password_input">Password</label><input id="password_input" type="password" ...>
}
```

Validation errors are associated with their inputs via `aria-describedby`:

```swift
TextField("Email", text: $email)
    .validation(error: emailError)
// → <input aria-invalid="true" aria-describedby="email_error">
//   <p id="email_error" role="alert">Invalid email address</p>
```
