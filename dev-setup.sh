#!/bin/bash
# Resolve and fetch dependencies for the dev app.
set -e

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_ROOT/dev"
swift package resolve
