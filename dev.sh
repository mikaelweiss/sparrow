#!/bin/bash
# Build the Sparrow CLI, then serve the dev app.
# Library changes are picked up automatically via path dependency.
# Works in any worktree — all paths are relative.
set -e

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"

swift build
cd "$REPO_ROOT/dev"
"$REPO_ROOT/.build/debug/sparrow" serve "$@"
