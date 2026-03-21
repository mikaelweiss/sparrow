# 21 — Live Previews

SwiftUI-like live preview system for Sparrow. Developers define previews alongside their views using a `#Preview` macro, run `sparrow preview` to start a preview server, and see interactive, hot-reloading previews in a Zed editor panel or browser.

---

## 1. Preview API

### `#Preview` Macro

Freestanding declaration macro. Defines one or more view variants to preview.

```swift
// Component preview — all variants visible simultaneously at natural size
#Preview("Button States") {
    MyButton(label: "Default")
    MyButton(label: "Disabled").disabled(true)
    MyButton(label: "Loading").loading(true)
}

// Full page preview — one variant at a time, tabs to switch
#Preview("Home Page", layout: .fullPage) {
    HomePage()
        .colorScheme(.light)
    HomePage()
        .colorScheme(.dark)
}

// Minimal — no label, defaults to file name + line number
#Preview {
    ProfileCard(user: .sample)
}
```

**Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `name` | `String?` | File name + line | Human-readable label shown in preview chrome |
| `layout` | `PreviewLayout` | `.component` | How variants are displayed |
| body | `@ViewBuilder () -> some View` | required | One or more view variants |

### `PreviewLayout`

```swift
public enum PreviewLayout {
    /// Each variant renders at its natural size. All variants visible simultaneously,
    /// stacked vertically with labels.
    case component

    /// Each variant fills the viewport. One visible at a time, tabs to switch.
    case fullPage
}
```

### Macro Expansion

```swift
// Input:
#Preview("Button States") {
    MyButton(label: "Default")
    MyButton(label: "Disabled").disabled(true)
}

// Expands to:
struct _SparrowPreview_a1b2c3: SparrowPreview {
    static let name = "Button States"
    static let sourceFile = #filePath
    static let line: Int = #line
    static let layout: PreviewLayout = .component

    @ViewBuilder
    static var content: some View {
        MyButton(label: "Default")
        MyButton(label: "Disabled").disabled(true)
    }
}
```

The generated type name uses a stable hash derived from `(filePath, line)` to avoid collisions.

### `SparrowPreview` Protocol

```swift
public protocol SparrowPreview {
    associatedtype Content: View

    static var name: String { get }
    static var sourceFile: String { get }
    static var line: Int { get }
    static var layout: PreviewLayout { get }

    @ViewBuilder
    static var content: Content { get }
}
```

### Preview-Specific Modifiers

Previews use standard Sparrow modifiers. No preview-specific modifiers needed for v1. Environment overrides (color scheme, etc.) are applied via the existing modifier system:

```swift
#Preview("Dark Mode", layout: .fullPage) {
    SettingsPage()
        .colorScheme(.dark)
}
```

---

## 2. Preview Discovery & Build

### How `sparrow preview` Finds Previews

The `sparrow preview` command needs to discover all `#Preview` blocks at build time and compile them into a single preview binary.

**Step 1 — Source scan.** Scan all `.swift` files in the project (excluding `.build/`, `.sparrow/`) for `#Preview` invocations using a simple regex pattern (`#Preview\s*[\({]`). This produces a list of files that contain previews.

**Step 2 — Build.** Compile the project normally. The `#Preview` macro expands into `SparrowPreview`-conforming types during compilation.

**Step 3 — Generated registry.** Generate a `_PreviewRegistry.swift` file that explicitly references all discovered preview types. The CLI knows the generated type names because it uses the same `(filePath, line) → hash` convention as the macro.

```swift
// Auto-generated: .sparrow/preview/_PreviewRegistry.swift
import Sparrow
import UserApp // the user's target

enum _PreviewRegistry {
    static func all() -> [(any SparrowPreview.Type)] {
        [
            _SparrowPreview_a1b2c3.self,
            _SparrowPreview_d4e5f6.self,
            _SparrowPreview_789abc.self,
        ]
    }
}
```

**Step 4 — Preview binary.** Compile the generated registry + a preview entry point into a separate executable. This binary links against the user's app code and Sparrow, but has its own `@main` that starts the preview server instead of the app server.

### Preview Binary Location

The preview binary and all generated files live in `.sparrow/preview/`:

```
.sparrow/
└── preview/
    ├── _PreviewRegistry.swift    # generated registry
    ├── _PreviewMain.swift        # generated entry point
    └── .build/                   # preview binary build artifacts
```

The `.sparrow/` directory should be added to `.gitignore` by `sparrow new`.

### Incremental Rebuilds

When a `.swift` file changes:

1. **If the file contains `#Preview`**: re-scan to update the registry (new/removed/changed previews), then rebuild.
2. **If the file doesn't contain `#Preview`**: rebuild without re-scanning (the registry hasn't changed, but the view code has).
3. Swift's incremental compilation handles the rest — single-file changes rebuild in <1 second typically.

After rebuild, the preview binary restarts. The preview chrome auto-reconnects via WebSocket and re-renders.

---

## 3. Preview Server

### CLI Command: `sparrow preview`

```bash
sparrow preview                    # start preview server (default port 5457)
sparrow preview --port 8080        # custom port
sparrow preview --no-browser       # don't auto-open browser
sparrow preview --json             # structured output for tool integration
```

The command:
1. Scans for previews, generates registry
2. Builds the preview binary (stored in `.sparrow/preview/`)
3. Starts the preview server
4. Opens the preview URL in the default browser (unless `--no-browser`)
5. Watches for file changes, rebuilds incrementally, restarts binary
6. The preview chrome auto-reconnects — no manual refresh needed

**JSON output mode** (for Zed extension integration):
```json
{"status": "starting", "message": "Scanning for previews..."}
{"status": "building", "message": "Found 12 previews in 5 files"}
{"status": "running", "url": "http://localhost:5457/_preview/", "pid": 12345}
{"status": "rebuilding", "file": "Sources/App/Views/HomeView.swift"}
{"status": "running", "url": "http://localhost:5457/_preview/", "pid": 12346}
{"status": "error", "message": "Build failed", "details": "...compiler output..."}
```

### Server Endpoints

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/_preview/` | Preview chrome — single-page HTML app with toolbar, viewport frame |
| `GET` | `/_preview/files` | JSON list of all files with previews and their preview metadata |
| `GET` | `/_preview/render/{previewId}` | Render a single preview variant to HTML |
| `WS` | `/_preview/ws` | WebSocket for live updates and interactivity |
| `GET` | `/_preview/build-id` | Current PID for reconnection detection |

#### `GET /_preview/files` Response

```json
{
  "files": [
    {
      "path": "Sources/App/Views/HomeView.swift",
      "previews": [
        {
          "id": "a1b2c3",
          "name": "Home Page",
          "layout": "fullPage",
          "line": 42,
          "variants": 2
        }
      ]
    },
    {
      "path": "Sources/App/Components/Button.swift",
      "previews": [
        {
          "id": "d4e5f6",
          "name": "Button States",
          "layout": "component",
          "line": 88,
          "variants": 3
        }
      ]
    }
  ],
  "activeFile": "Sources/App/Views/HomeView.swift"
}
```

### Active File Tracking

The preview server tracks which file the user is working on. Two mechanisms:

1. **Query parameter**: `/_preview/?file=Sources/App/Views/HomeView.swift` — the Zed extension navigates the webview to this URL when the user switches files.
2. **File modification**: When a file is saved, the server automatically makes it the active file. This means even without the Zed extension, the preview follows your edits.

Switching files does **not** rebuild or restart the server. All previews are already compiled into the binary. The switch is instant — just a different preview rendered.

### Preview Chrome

The preview server serves a self-contained HTML page at `/_preview/` that provides the full preview UI. All complexity lives here, keeping the Zed extension thin.

#### Layout: Component Mode

```
┌──────────────────────────────────────────────────────────┐
│  Button.swift ▾  │  "Button States"  │ 📱 💻 🖥 │ 375px │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────────────┐                                │
│  │    Click Me          │  "Default"                     │
│  └──────────────────────┘                                │
│                                                          │
│  ┌──────────────────────┐                                │
│  │    Click Me          │  "Disabled"                    │
│  └──────────────────────┘                                │
│                                                          │
│  ┌──────────────────────┐                                │
│  │    ●●● Loading       │  "Loading"                     │
│  └──────────────────────┘                                │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

All variants visible simultaneously. Each variant renders at its natural size inside a bordered frame with a label. Variants are stacked vertically with spacing between them. Variants are individually interactive (each has its own `SessionActor` and state).

#### Layout: Full Page Mode

```
┌──────────────────────────────────────────────────────────┐
│  HomeView.swift ▾ │ [Light] [Dark] │ 📱 💻 🖥 │  375px │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────────────────────────────────────────┐    │
│  │                                                  │    │
│  │  Full page render at selected viewport width     │    │
│  │                                                  │    │
│  │                                                  │    │
│  │                                                  │    │
│  │                                                  │    │
│  └──────────────────────────────────────────────────┘    │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

One variant visible at a time. Tabs at the top to switch between variants. Each tab is labeled with the variant's index or a label derived from distinguishing modifiers (e.g., "Light", "Dark" if `.colorScheme` differs).

#### Toolbar Controls

**File selector**: Dropdown listing all files with previews. Selecting a file switches to that file's previews.

**Preview selector**: If a file has multiple `#Preview` blocks, a second dropdown to pick which one to show.

**Viewport presets**: Three buttons for common widths:
- Mobile: 375px
- Tablet: 768px
- Desktop: 1280px

**Custom width**: The viewport frame has a drag handle on the right edge for manual resizing. The current width is displayed numerically and can be edited directly.

**Variant tabs** (full page only): Tab bar showing each variant. Active tab is highlighted.

### WebSocket Protocol

The preview WebSocket (`/_preview/ws`) extends the existing Sparrow WebSocket protocol with preview-specific messages:

#### Client → Server

```json
// Switch active file
{"type": "preview:setFile", "path": "Sources/App/Views/HomeView.swift"}

// Switch active preview within a file
{"type": "preview:setPreview", "id": "a1b2c3"}

// Switch variant (full page mode)
{"type": "preview:setVariant", "index": 0}

// Set viewport width
{"type": "preview:setViewport", "width": 375}

// Standard Sparrow events (clicks, input, etc.) — same as existing protocol
{"type": "event", "id": "v2", "event": "click"}
```

#### Server → Client

```json
// Full render of current preview (sent on file switch, rebuild, variant switch)
{
  "type": "preview:render",
  "file": "Sources/App/Views/HomeView.swift",
  "preview": {
    "id": "a1b2c3",
    "name": "Button States",
    "layout": "component",
    "variants": [
      {"index": 0, "label": "Default", "html": "<button id=\"v0\">Click Me</button>"},
      {"index": 1, "label": "Disabled", "html": "<button id=\"v0\" disabled>Click Me</button>"},
      {"index": 2, "label": "Loading", "html": "<button id=\"v0\">●●● Loading</button>"}
    ]
  }
}

// Incremental patch (on state change from interaction) — same as existing protocol
{"type": "patch", "variant": 0, "patches": [{"op": "replace", "target": "#sparrow-root", "html": "..."}]}

// File list update (after rebuild discovers new/removed previews)
{"type": "preview:filesUpdated", "files": [...]}

// Build status
{"type": "preview:building"}
{"type": "preview:ready"}
{"type": "preview:error", "message": "Build failed", "details": "..."}
```

### Interactivity

Each preview variant gets its own `SessionActor` with independent state. Clicking a button in variant 0 does not affect variant 1. This reuses the existing `SessionActor`, `StateStorage`, `RenderState`, and event handler infrastructure — no new rendering code needed.

When a rebuild happens:
1. All `SessionActor` instances are destroyed (state is reset)
2. New actors are created for the new preview binary's variants
3. The chrome re-renders all variants

State does not persist across rebuilds. This matches SwiftUI preview behavior.

---

## 4. Zed Extension

### Architecture

The Zed extension is intentionally thin. All preview UI (toolbar, viewport controls, variant tabs) lives in the preview server's HTML chrome. The extension's only responsibilities:

1. Detect Sparrow projects
2. Start/stop `sparrow preview` in the background
3. Show the preview in a panel
4. Notify the server when the user switches files

### Project Detection

The extension activates when it finds a `Package.swift` that depends on `Sparrow`, or a `Sparrow.toml` file in the workspace root.

### Server Lifecycle

When the extension activates:
1. Start `sparrow preview --json --no-browser` as a background process
2. Parse JSON output to get the preview URL
3. Open the preview panel once status is `"running"`

When the workspace closes:
1. Send SIGTERM to the preview process
2. The preview server shuts down gracefully

If the preview server crashes, the extension shows an error in the panel with a "Restart" button.

### Panel Integration

The extension opens the preview URL in a panel on the right side of the editor. The approach depends on Zed's available extension APIs:

**Preferred: Webview panel** — If Zed supports webview panels in extensions, embed the preview directly. This gives the tightest integration (side-by-side with code, no window switching).

**Fallback: External browser** — If webview panels aren't available, open the preview URL in the system browser. The preview chrome works identically in a standalone browser. The user arranges Zed and the browser side-by-side.

Either way, the preview chrome is self-contained — it doesn't depend on being inside Zed.

### Active File Communication

When the user switches to a different file in Zed:

1. The extension checks if the new file has previews (it can cache the list from `/_preview/files`)
2. If yes, navigates the webview/sends a request: `/_preview/?file={relativePath}`
3. The preview chrome loads that file's previews instantly (no rebuild)

If the new file has no previews, the panel stays on the last previewed file.

### Extension Manifest

```toml
# extension.toml
id = "sparrow-preview"
name = "Sparrow Preview"
description = "Live preview panel for Sparrow web framework components"
version = "0.1.0"
schema_version = 1

[languages.sparrow]
path = "languages/sparrow"
```

---

## 5. Macro Infrastructure

The `#Preview` macro is Sparrow's first Swift macro. This adds infrastructure that future macros (`@Model`, `@Query`, etc.) will reuse.

### Package.swift Changes

```swift
dependencies: [
    // ... existing deps ...
    .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0"),
],
targets: [
    // Macro implementation (compiler plugin)
    .macro(
        name: "SparrowMacros",
        dependencies: [
            .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
        ]
    ),

    // Main Sparrow library depends on the macro
    .target(
        name: "Sparrow",
        dependencies: ["SparrowMacros"],
        // ...
    ),

    // Macro tests
    .testTarget(
        name: "SparrowMacrosTests",
        dependencies: [
            "SparrowMacros",
            .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
        ]
    ),
]
```

### Macro Declaration (in Sparrow module)

```swift
/// Defines a live preview for a Sparrow view or component.
@freestanding(declaration, names: arbitrary)
public macro Preview(
    _ name: String? = nil,
    layout: PreviewLayout = .component,
    body: @escaping @ViewBuilder () -> some View
) = #externalMacro(module: "SparrowMacros", type: "PreviewMacro")
```

### Macro Implementation (in SparrowMacros module)

The `PreviewMacro` is a `FreestandingDeclarationMacro` that:

1. Extracts the name parameter (or defaults to `nil`)
2. Extracts the layout parameter (or defaults to `.component`)
3. Computes a stable hash from `(filePath, line)` for the type name
4. Generates a struct conforming to `SparrowPreview`

The hash algorithm must be identical between the macro and the CLI's source scanner so the generated registry references the correct type names.

---

## 6. Out of Scope (v1)

- **Preview-specific modifiers** (e.g., `.previewDisplayName()`, `.previewDevice()`). Use standard Sparrow modifiers.
- **Snapshot testing of previews.** Could be added later — render each preview to HTML and compare.
- **Multi-window previews.** One preview panel at a time.
- **Preview assets** (mock images, sample data providers). Developers create their own sample data.
- **Non-Zed editor extensions.** VS Code, Cursor, etc. could be added later — the preview server is editor-agnostic, only the extension layer differs.
- **Remote preview server.** The server runs locally only.
- **Preview-specific state injection.** Use `Binding.constant()` and sample data.

---

## 7. Implementation Order

### Phase A: Macro Infrastructure
1. Add `swift-syntax` dependency to `Package.swift`
2. Create `SparrowMacros` target with `PreviewMacro` implementation
3. Add `SparrowPreview` protocol and `PreviewLayout` enum to Sparrow core
4. Add `#Preview` macro declaration to Sparrow module
5. Write macro expansion tests

### Phase B: Preview Server
1. Add `sparrow preview` command to CLI (`Sources/SparrowCLICore/`)
2. Implement source scanner (find files with `#Preview`)
3. Implement registry generator (`_PreviewRegistry.swift`, `_PreviewMain.swift`)
4. Build preview binary compilation pipeline (compile to `.sparrow/preview/`)
5. Implement preview server (endpoints, WebSocket, preview chrome HTML)
6. Wire up file watching + incremental rebuild + auto-restart
7. Implement preview chrome UI (toolbar, viewport controls, variant tabs/stacking)
8. Implement per-variant `SessionActor` for interactive previews

### Phase C: Zed Extension
1. Scaffold Zed extension (`extension.toml`, Rust/WASM project)
2. Implement project detection (find `Package.swift` with Sparrow dep or `Sparrow.toml`)
3. Implement server lifecycle (start/stop `sparrow preview`)
4. Implement panel integration (webview or external browser fallback)
5. Implement active file tracking (detect file switches, notify server)
