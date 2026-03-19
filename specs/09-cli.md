# CLI

## Overview

The Sparrow CLI is the single entry point for creating, running, building, and managing Sparrow projects. It has two modes: human (interactive prompts) and LLM (JSON input/output).

## Commands

### sparrow new

Creates a new Sparrow project.

**Human mode (interactive):**
```
$ sparrow new MyApp

  Creating new Sparrow project: MyApp

  Theme: (default)
  ○ Default (clean, professional)
  ○ Minimal (stripped back, content-focused)

  Database: (default)
  ○ Postgres (local)
  ○ None 
  Auth: (default)
  ○ Built-in (email/password)
  ○ None 
  ✓ Created MyApp/
  ✓ Created MyApp/Sparrow.toml
  ✓ Created MyApp/App.swift

  Next steps:
    cd MyApp
    sparrow run
```

**LLM mode:**
```
$ sparrow new --json '{"name": "MyApp", "theme": "default", "database": "postgres", "auth": true}'

{"status": "ok", "path": "MyApp/", "files": ["Sparrow.toml", "App.swift"]}
```

### Generated Files

```
MyApp/
  Sparrow.toml        # project config
  App.swift            # entry point, routes, first view
```

**Sparrow.toml:**
```toml
name = "MyApp"
swift-tools-version = "6.2"

[theme]
preset = "default"

[database]
url = "postgres://localhost:5432/myapp"

[auth]
enabled = true
```

**App.swift:**
```swift
import Sparrow

@main
struct MyApp: App {
    var body: some Scene {
        Routes {
            Page("/") {
                VStack(spacing: 16) {
                    Text("Welcome to MyApp")
                        .font(.largeTitle)
                    Text("Edit App.swift to get started.")
                        .foreground(.textSecondary)
                }
                .padding(32)
            }
        }
    }
}
```

That's it. Two files. `sparrow run` starts the server.

### sparrow run

Starts the development server with hot reload.

```
$ sparrow run

  ✓ Compiled MyApp (1.2s)
  ✓ Connected to Postgres
  ✓ Migrations up to date
  ✓ Server running at http://localhost:5456

  Watching for changes...
```

What `sparrow run` does:
1. Generates `Package.swift` from `Sparrow.toml` (if needed)
2. Runs `swift build` with incremental compilation
3. Starts the Hummingbird server
4. Connects to Postgres and runs pending migrations
5. Starts file watcher (FSEvents on macOS)
6. Opens the browser (configurable, default: yes)
7. On file change: incremental rebuild → hot-swap → push refresh over WebSocket

**Flags:**
```
sparrow run                    # default: localhost:5456
sparrow run --port 8080        # custom port
sparrow run --no-browser       # don't open browser
sparrow run --verbose          # detailed build output
```

### sparrow build

Compiles for production deployment.

```
$ sparrow build

  ✓ Compiled MyApp (release mode, 4.8s)
  ✓ Generated CSS (12KB gzipped)
  ✓ Copied static assets
  ✓ Build complete: .build/release/MyApp

  Output:
    .build/release/MyApp           # server binary
    .build/release/public/         # CSS, JS runtime, static assets
```

The output is a single binary + a `public/` directory. Deploy anywhere you can run a binary.

**Flags:**
```
sparrow build                     # release build
sparrow build --docker            # generate Dockerfile
sparrow build --docker --run      # build and run Docker container
```

### sparrow migrate

Manages database migrations.

```
$ sparrow migrate

  Detected changes:
    + Create table 'users' (id, name, email, password_hash, ...)
    + Create table 'posts' (id, title, body, author_id, ...)

  Apply? [y/n] y

  ✓ Applied 2 migrations
```

```
sparrow migrate                 # interactive: detect and apply
sparrow migrate --apply         # non-interactive: auto-apply (for CI/CD)
sparrow migrate --rollback      # undo last migration
sparrow migrate --status        # show migration status
```

### sparrow db

Database utilities.

```
sparrow db reset                # drop and recreate (dev only)
sparrow db console              # open psql connected to project database
```

## LLM Mode

Every command accepts `--json` for structured input and returns JSON output.

```
$ sparrow new --json '{"name": "MyApp"}'
{"status": "ok", "path": "MyApp/"}

$ sparrow run --json
{"status": "running", "url": "http://localhost:5456", "pid": 12345}

$ sparrow build --json
{"status": "ok", "binary": ".build/release/MyApp", "assets": ".build/release/public/"}

$ sparrow migrate --json
{"pending": [{"name": "001_create_users", "changes": ["create table users"]}]}

$ sparrow migrate --apply --json
{"status": "ok", "applied": ["001_create_users"]}
```

LLM mode:
- Never prompts for input (uses defaults or errors if required params missing)
- Always returns structured JSON
- Includes error details in JSON on failure: `{"status": "error", "message": "...", "code": "..."}`
- Progress events can be streamed as newline-delimited JSON if `--stream` is added

## Project Discovery

Sparrow finds the project root by looking for `Sparrow.toml` in the current directory or parent directories (like how `git` finds `.git/`). All commands work from any subdirectory of the project.

## Package Management

Sparrow uses Swift Package Manager under the hood but abstracts it away. The developer adds dependencies in `Sparrow.toml`:

```toml
[dependencies]
sparrow-charts = { version = "1.0", source = "https://github.com/sparrow-packages/charts" }
```

Sparrow generates the `Package.swift` from `Sparrow.toml`. The developer never edits `Package.swift` directly.

```
sparrow add sparrow-charts      # add a dependency
sparrow remove sparrow-charts   # remove a dependency
sparrow update                  # update all dependencies
```

## Error Output

Errors are designed to be helpful for both humans and LLMs:

```
$ sparrow run

  ✗ Build failed

  App.swift:15:9: error: type 'Users' has no member 'qury'
    let users = try await User.qury().all()
                                ~~~~
  Did you mean 'query'?
```

In JSON mode:
```json
{
    "status": "error",
    "errors": [
        {
            "file": "App.swift",
            "line": 15,
            "column": 9,
            "message": "type 'Users' has no member 'qury'",
            "suggestion": "Did you mean 'query'?"
        }
    ]
}
```
