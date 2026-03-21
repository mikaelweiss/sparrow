# Contributing to Sparrow

Thanks for your interest in contributing to Sparrow! This guide covers everything you need to get started.

## Setup

**Requirements:** Swift 6.2+, macOS 15+

1. Clone the repo and add the SPM bin directory to your PATH:
   ```bash
   export PATH="$HOME/.swiftpm/bin:$PATH"
   ```

2. Install the CLI locally:
   ```bash
   swift package experimental-install
   ln -sf ~/.swiftpm/bin/sparrow ~/.swiftpm/bin/kln
   ```

3. Create a test project to exercise library changes:
   ```bash
   sparrow new --local
   ```

See [`DEVELOPMENT.md`](DEVELOPMENT.md) for full dev workflow details.

## Development Workflow

### Library changes (Sparrow framework)

Projects created with `--local` use a local path dependency, so `sparrow run` picks up changes automatically:

```
edit → sparrow run (from test project)
```

### CLI changes (SparrowCLI, SparrowCLICore)

The CLI is a compiled binary, so changes require a reinstall:

```
edit → ./package-dev.sh → test
```

## Testing

Run all tests:

```bash
swift test
```

Tests use Swift Testing (`import Testing` / `@Test` / `#expect`). No XCTest.

## Submitting Changes

1. Fork the repo and create a branch from `main`
2. Make your changes
3. Add tests for new functionality
4. Run `swift test` and make sure everything passes
5. Open a pull request against `main`

### Pull Request Guidelines

- Keep PRs focused — one feature or fix per PR
- Write a clear description of what changed and why
- Include test coverage for new code

## Project Structure

| Directory | Purpose |
|---|---|
| `Sources/Sparrow/` | Framework library (views, modifiers, renderer, server) |
| `Sources/SparrowCLICore/` | Shared CLI logic (new, run, build commands) |
| `Sources/SparrowCLI/` | CLI executable entry point |
| `Tests/SparrowTests/` | Framework tests |
| `Tests/SparrowCLICoreTests/` | CLI tests |
| `specs/` | Design specs for all features |

## Specs

Before implementing a feature, read the relevant spec in [`specs/`](specs/). The specs are the source of truth for how things should work.

## License

By contributing, you agree that your contributions will be licensed under the [Apache 2.0 License](LICENSE).
