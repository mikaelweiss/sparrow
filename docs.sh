#!/bin/bash
# Build the Sparrow framework, extract symbol graphs, then serve the docs site.
# Works in any worktree — all paths are relative.
set -e

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"

swift build
cd "$REPO_ROOT/docs"
"$REPO_ROOT/docs/generate-docs.sh" "$@"
