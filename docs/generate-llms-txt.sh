#!/bin/bash
set -euo pipefail

# generate-llms-txt.sh
# Builds llms.txt from the spec files in specs/.
#
# Usage:
#   ./generate-llms-txt.sh              # writes to ../llms.txt
#   ./generate-llms-txt.sh output.txt   # writes to custom path

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SPARROW_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SPECS_DIR="$SPARROW_ROOT/specs"
OUTPUT="${1:-$SCRIPT_DIR/llms.txt}"

{
    cat <<'EOF'
# Sparrow

> A batteries-included Swift web framework. SwiftUI-like code on the server → HTML/CSS in the browser.

Sparrow uses a SwiftUI-like DSL to define views that render to semantic HTML and CSS. State lives on the server in Swift actors. A WebSocket connection pushes DOM patches to the browser. Developers write zero JavaScript and zero CSS.

## Docs

EOF

    for spec in "$SPECS_DIR"/[0-9]*.md; do
        title=$(head -1 "$spec" | sed 's/^# //')
        echo "- $title"
    done

    echo ""
    echo "## Full Documentation"
    echo ""

    for spec in "$SPECS_DIR"/[0-9]*.md; do
        echo "---"
        echo ""
        cat "$spec"
        echo ""
    done
} > "$OUTPUT"

echo "  Generated llms.txt ($(wc -l < "$OUTPUT" | tr -d ' ') lines) → $OUTPUT"
