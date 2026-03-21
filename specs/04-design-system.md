# Design System

## Overview

Sparrow ships a complete design system with professional defaults. Every component looks good out of the box. Theming is changing a few values in a config, not rebuilding components.

The design system is inspired by Apple's Human Interface Guidelines adapted for web: clean, legible, spacious, with clear visual hierarchy.

## How It Works Under the Hood

1. At build time, Sparrow generates a CSS stylesheet from the design system tokens
2. Tokens are CSS custom properties (`--color-primary`, `--spacing-4`, etc.)
3. Component modifiers map to utility CSS classes that reference these tokens
4. Theming swaps the custom property values — all components update automatically
5. The developer never sees CSS

## Color System

### Semantic Colors

Every color has a semantic name. Components use semantic colors, not hex values.

| Token | Light Default | Dark Default | Usage |
|---|---|---|---|
| `primary` | `#007AFF` | `#0A84FF` | Primary actions, links, active states |
| `secondary` | `#5856D6` | `#5E5CE6` | Secondary actions, accents |
| `accent` | `#FF9500` | `#FF9F0A` | Highlights, badges, attention |
| `background` | `#FFFFFF` | `#000000` | Page background |
| `surface` | `#F2F2F7` | `#1C1C1E` | Card backgrounds, elevated surfaces |
| `surfaceSecondary` | `#E5E5EA` | `#2C2C2E` | Secondary surfaces, borders |
| `text` | `#000000` | `#FFFFFF` | Primary text |
| `textSecondary` | `#3C3C43` (0.6 opacity) | `#EBEBF5` (0.6 opacity) | Secondary text, labels |
| `textTertiary` | `#3C3C43` (0.3 opacity) | `#EBEBF5` (0.3 opacity) | Placeholder text, disabled |
| `error` | `#FF3B30` | `#FF453A` | Error states, destructive actions |
| `success` | `#34C759` | `#30D158` | Success states, confirmations |
| `warning` | `#FF9500` | `#FF9F0A` | Warning states, caution |
| `info` | `#5AC8FA` | `#64D2FF` | Informational states |

### Using Colors

```swift
Text("Hello")
    .foreground(.primary)         // semantic color
    .background(.surface)         // semantic color

Text("Custom")
    .foreground(.hex("#FF0000"))  // escape hatch for explicit colors
```

### Color Opacity

```swift
.foreground(.primary.opacity(0.5))
.background(.surface.opacity(0.8))
```

## Typography

### Type Scale

Based on Apple's Dynamic Type sizes, adapted for web.

| Style | Size | Weight | Line Height | HTML Element |
|---|---|---|---|---|
| `.largeTitle` | 34px | Bold | 1.2 | `<h1>` |
| `.title` | 28px | Bold | 1.2 | `<h2>` |
| `.title2` | 22px | Bold | 1.3 | `<h3>` |
| `.title3` | 20px | Semibold | 1.3 | `<h4>` |
| `.headline` | 17px | Semibold | 1.4 | `<h5>` |
| `.body` | 17px | Regular | 1.5 | `<p>` |
| `.callout` | 16px | Regular | 1.5 | `<p>` |
| `.subheadline` | 15px | Regular | 1.4 | `<p>` |
| `.footnote` | 13px | Regular | 1.4 | `<small>` |
| `.caption` | 12px | Regular | 1.3 | `<small>` |

### Font Family

Default: system font stack (`ui-sans-serif, system-ui, sans-serif`). Separate CSS variables for body (`--font-body`), headings (`--font-heading`), and monospaced (`--font-mono`).

Customizable per-theme:

```swift
// Simple — just set family names
Theme.default.fonts(body: "Inter", heading: "Inter", mono: "JetBrains Mono")

// Full control — register font sources for @font-face generation
Theme.default.fonts(FontConfig(
    body: "Inter",
    heading: "Inter",
    mono: "JetBrains Mono",
    sources: [
        FontRegistration(
            family: "Inter",
            source: .local(path: "fonts/Inter-Variable.woff2"),
            weightRange: 100...900
        ),
        FontRegistration(
            family: "JetBrains Mono",
            source: .google(family: "JetBrains Mono")
        ),
    ]
))
```

Font files go in `Assets/fonts/` and are served at `/assets/fonts/`.

### Font Sources

| Source | Description |
|---|---|
| `.system` | Platform default. No download |
| `.local(path:)` | Self-hosted file in `Assets/`. WOFF2 recommended |
| `.google(family:)` | Google Fonts — fetched at build time, served locally |
| `.url(String)` | Remote URL to a font file |

Variable fonts are first-class: a single file with `weightRange: 100...900` covers all weights.

### Using Typography

```swift
// Type scale (size, weight, line-height from design tokens)
Text("Title")
    .font(.title)

// Arbitrary size with system font
Text("Custom")
    .font(.system(size: 18, weight: .medium))

// Custom font with explicit size (escape hatch)
Text("Logo")
    .font(.custom("Playfair Display", size: 48))

// Change font family WITHOUT changing size (web-native, unlike SwiftUI)
Text("Code snippet")
    .fontDesign(.monospaced)

Text("Branded text")
    .fontFamily("Inter")
```

### Text Modifiers

Independent modifiers for weight, style, spacing, and case:

```swift
Text("Bold").bold()
Text("Italic").italic()
Text("Light").fontWeight(.light)
Text("Spaced").tracking(0.05)
Text("UPPER").textCase(.uppercase)
Text("Underlined").underline()
Text("Deleted").strikethrough()
Text("Serif").fontDesign(.serif)
```

### Inline Text Styling

Text-level modifiers return `Text` (not `ModifiedView`), enabling concatenation:

```swift
Text("Error: ").bold() + Text("something went wrong").italic()
// Renders: <p><strong>Error: </strong><em>something went wrong</em></p>
```

Uses semantic HTML: `<strong>` for bold, `<em>` for italic, `<del>` for strikethrough.

### Dynamic Font Sizes

All type scale sizes use `rem` units, which scale with the user's browser font size preference — the web equivalent of iOS Dynamic Type. No developer action needed.

## Spacing Scale

A consistent spacing scale used by padding, margin, gaps, and layout spacing.

| Token | Value |
|---|---|
| `0` | 0px |
| `1` | 4px |
| `2` | 8px |
| `3` | 12px |
| `4` | 16px |
| `5` | 20px |
| `6` | 24px |
| `8` | 32px |
| `10` | 40px |
| `12` | 48px |
| `16` | 64px |

When you write `.padding(16)`, it maps to spacing token `4` (16px). The framework accepts both raw pixel values and token indices:

```swift
.padding(16)       // 16px
.padding(.s4)      // also 16px, using the token directly
```

## Border Radius

| Token | Value |
|---|---|
| `.none` | 0px |
| `.sm` | 4px |
| `.md` | 8px |
| `.lg` | 12px |
| `.xl` | 16px |
| `.2xl` | 24px |
| `.full` | 9999px (pill shape) |

```swift
.cornerRadius(.md)    // 8px
.cornerRadius(12)     // explicit 12px
```

## Shadows

| Token | Value |
|---|---|
| `.none` | none |
| `.sm` | `0 1px 2px rgba(0,0,0,0.05)` |
| `.md` | `0 4px 6px rgba(0,0,0,0.07), 0 2px 4px rgba(0,0,0,0.06)` |
| `.lg` | `0 10px 15px rgba(0,0,0,0.1), 0 4px 6px rgba(0,0,0,0.05)` |
| `.xl` | `0 20px 25px rgba(0,0,0,0.1), 0 8px 10px rgba(0,0,0,0.04)` |

Dark mode shadows use lighter, more subtle values to avoid looking harsh on dark backgrounds.

## Theming

### Default Theme

Sparrow ships with one default theme that looks professional and clean. It covers light and dark mode automatically.

### Custom Themes

Defined in Swift using the builder pattern:

```swift
extension Theme {
    static let app = Theme.default
        .primary("#6366F1")
        .secondary("#8B5CF6")
        .accent("#F59E0B")
        .fonts(body: "Inter", heading: "Inter", mono: "JetBrains Mono")
        .dark { dark in
            dark.background("#0F172A")
                .surface("#1E293B")
        }
}
```

Used in your App:

```swift
@main
struct MyApp: App {
    var theme: Theme { .app }
    var routes: [Route] { ... }
}
```

If `theme` is omitted, `Theme.default` is used (system fonts, built-in colors).

### Theme Propagation

Like SwiftUI's environment, theme values propagate down the view tree. Any component can override the theme for its subtree:

```swift
VStack {
    Text("Default theme")

    VStack {
        Text("This subtree uses a different primary color")
    }
    .environment(\.theme.primary, "#FF0000")
}
```

### Dark Mode

Dark mode works automatically. The CSS uses `@media (prefers-color-scheme: dark)` to swap custom properties. No developer action needed.

To force a specific mode:

```swift
MyView()
    .colorScheme(.dark)   // force dark
    .colorScheme(.light)  // force light
```

## Component Styles

Built-in components have style variants:

```swift
Button("Submit", style: .primary)      // filled, primary color
Button("Cancel", style: .secondary)    // outlined, secondary color
Button("Delete", style: .destructive)  // filled, error color
Button("More", style: .ghost)          // text only, no background
Button("Link", style: .link)           // underlined, like a link

Badge("New", style: .info)
Badge("Error", style: .error)
Badge("Pro", style: .accent)

TextField("Email", text: $email)
    .textFieldStyle(.outlined)         // border
    .textFieldStyle(.filled)           // background fill
```

## Icons

Sparrow ships the [Lucide](https://lucide.dev) icon set (MIT-licensed, 1500+ icons). Icons are SVG, tree-shaken at build time so only used icons are included in the output.

```swift
Icon(.plus)
Icon(.chevronRight)
Icon(.user)
Icon(.search)
Icon(.bell)
    .foreground(.secondary)
    .font(.title3)   // controls icon size
```

## CSS Output

The design system compiles to a single CSS file. Example of generated output:

```css
:root {
    --color-primary: #007AFF;
    --color-surface: #F2F2F7;
    --color-text: #000000;
    --spacing-4: 16px;
    --radius-md: 8px;
    --shadow-sm: 0 1px 2px rgba(0,0,0,0.05);
    --font-body: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
}

@media (prefers-color-scheme: dark) {
    :root {
        --color-primary: #0A84FF;
        --color-surface: #1C1C1E;
        --color-text: #FFFFFF;
    }
}

.font-title { font: 700 28px/1.2 var(--font-body); }
.font-body { font: 400 17px/1.5 var(--font-body); }
.fg-primary { color: var(--color-primary); }
.bg-surface { background: var(--color-surface); }
.p-4 { padding: var(--spacing-4); }
.rounded-md { border-radius: var(--radius-md); }
.shadow-sm { box-shadow: var(--shadow-sm); }
```

This file is generated once at build time and cached aggressively by the browser. It's typically 10-30KB gzipped depending on how many design tokens and utility classes are generated.
