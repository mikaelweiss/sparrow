#!/bin/bash
set -euo pipefail

# generate-docs.sh
# Extracts symbol graphs from the Sparrow framework and starts the docs site.
#
# Usage:
#   ./generate-docs.sh          # extract + serve
#   ./generate-docs.sh extract  # just extract symbol graphs
#   ./generate-docs.sh serve    # just start the docs server (assumes already extracted)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SPARROW_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SYMBOLGRAPH_DIR="$SPARROW_ROOT/.build/arm64-apple-macosx/symbolgraph"

step() { echo ""; echo "  → $1"; }

extract() {
    step "Building Sparrow framework..."
    cd "$SPARROW_ROOT"
    swift build 2>&1 | tail -3

    step "Extracting symbol graphs..."
    swift package dump-symbol-graph 2>&1 | grep -E "Emitting|Files written"

    echo "  Symbol graphs written to: $SYMBOLGRAPH_DIR"

    step "Generating llms.txt from specs..."
    "$SCRIPT_DIR/generate-llms-txt.sh"
}

serve() {
    step "Building docs site..."
    cd "$SCRIPT_DIR"
    export SYMBOLGRAPH_DIR="$SYMBOLGRAPH_DIR"
    swift run SparrowDocs
}

case "${1:-all}" in
    extract)
        extract
        ;;
    serve)
        serve
        ;;
    all|*)
        extract
        serve
        ;;
esac
