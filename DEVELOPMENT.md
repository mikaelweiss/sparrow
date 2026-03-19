# Development

## One-Time Setup

1. Add the SPM bin directory to your PATH (in `~/.zshrc`):
   ```bash
   export PATH="$HOME/.swiftpm/bin:$PATH"
   ```

2. Install the CLI locally:
   ```bash
   swift package experimental-install
   ln -sf ~/.swiftpm/bin/sparrow ~/.swiftpm/bin/kln
   ```

3. Create a test project:
   ```bash
   sparrow new --local
   ```

## Development Loops

### CLI changes (SparrowCLI, KilnCLI, SparrowCLICore)

```
edit → ./package-dev.sh → test
```

The CLI is a compiled binary installed to `~/.swiftpm/bin`. `package-dev.sh` handles uninstalling, reinstalling, and symlinking `kln`.

### Library changes (Sparrow framework)

```
edit → sparrow run (from test project)
```

Projects created with `--local` use a local path dependency, so `sparrow run` picks up library changes automatically — no reinstall needed.

## Testing

Run all tests:

```bash
swift test
```

Tests use Swift Testing (`import Testing` / `@Test` / `#expect`). No XCTest.

### Test Structure

| Test file | What it covers |
|---|---|
| `Tests/SparrowTests/CoreTypeTests.swift` | View protocol, EmptyView, TupleView, ConditionalView, Text, VStack, HStack, alignment enums |
| `Tests/SparrowTests/ViewBuilderTests.swift` | ViewBuilder result builder — empty, single, multiple, optional, if/else |
| `Tests/SparrowTests/HTMLRendererTests.swift` | Rendering primitives (Text, Spacer, Divider, EmptyView), stacks, nesting, ConditionalView, custom views |
| `Tests/SparrowTests/ModifierTests.swift` | Font, foreground, background, padding, corner radius, shadow, frame modifiers — CSS classes, inline styles, chaining, rendering |
| `Tests/SparrowTests/RouteTests.swift` | Route properties, document rendering, title escaping, Page convenience, RouteBuilder |
| `Tests/SparrowTests/HelperTests.swift` | escapeHTML, formatStyles, spacingToken, flattenTuple, ModifierContext |
| `Tests/SparrowTests/CSSGeneratorTests.swift` | Default stylesheet content — tokens, utilities, dark mode, all class categories |
| `Tests/SparrowCLICoreTests/CLIHelperTests.swift` | discoverExecutable — finds targets, handles missing/invalid Package.swift |

## Project Structure

| Directory | What it is |
|---|---|
| `Sources/Sparrow/` | The framework library (views, modifiers, renderer, server) |
| `Sources/SparrowCLICore/` | Shared CLI logic (commands: new, run, build) |
| `Sources/SparrowCLI/` | `sparrow` executable entry point |
| `Tests/SparrowTests/` | Framework unit tests |
| `Tests/SparrowCLICoreTests/` | CLI unit tests |
| `specs/` | Design specs for all features |

## Commands

| Command | What it does |
|---|---|
| `sparrow new` | Scaffold a new project (prompts for name) |
| `sparrow new --local` | Same, but uses local Sparrow checkout as dependency |
| `sparrow run` | Build and run the dev server |
| `sparrow build` | Production build |
| `kln` | Alias for `sparrow` (symlink created during setup) |
