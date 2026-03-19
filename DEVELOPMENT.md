# Development

## One-Time Setup

1. Add the SPM bin directory to your PATH (in `~/.zshrc`):
   ```bash
   export PATH="$HOME/.swiftpm/bin:$PATH"
   ```

2. Install the CLI locally:
   ```bash
   swift package experimental-install
   ```

3. Create a test project:
   ```bash
   sparrow new --local
   ```

## Development Loops

### CLI changes (SparrowCLI, KilnCLI, SparrowCLICore)

```
edit → swift package experimental-install → test
```

The CLI is a compiled binary installed to `~/.swiftpm/bin`. You must reinstall after changes.

### Library changes (Sparrow framework)

```
edit → sparrow run (from test project)
```

Projects created with `--local` use a local path dependency, so `sparrow run` picks up library changes automatically — no reinstall needed.

## Project Structure

| Directory | What it is |
|---|---|
| `Sources/Sparrow/` | The framework library (views, modifiers, renderer, server) |
| `Sources/SparrowCLICore/` | Shared CLI logic (commands: new, run, build) |
| `Sources/SparrowCLI/` | `sparrow` executable entry point |
| `Sources/KilnCLI/` | `kln` executable entry point (alias for sparrow) |
| `specs/` | Design specs for all features |

## Commands

| Command | What it does |
|---|---|
| `sparrow new` | Scaffold a new project (prompts for name) |
| `sparrow new --local` | Same, but uses local Sparrow checkout as dependency |
| `sparrow run` | Build and run the dev server |
| `sparrow build` | Production build |
| `kln` | Alias for `sparrow` |
