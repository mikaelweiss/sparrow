#!/usr/bin/env python3
"""Generate a Swift icon registry from an Iconify JSON package.

Usage:
    python3 scripts/generate-icons.py <prefix>

Examples:
    python3 scripts/generate-icons.py lucide
    python3 scripts/generate-icons.py mdi
    python3 scripts/generate-icons.py ph

Downloads the Iconify JSON for the given icon set prefix from unpkg,
then generates a Swift file at Sources/Sparrow/Icons/<Name>Icons.swift.
"""

import json
import sys
import urllib.request

def camel_to_pascal(prefix: str) -> str:
    """Convert an icon set prefix to a PascalCase Swift type name."""
    parts = prefix.replace("-", " ").replace("_", " ").split()
    return "".join(p.capitalize() for p in parts)

def main():
    if len(sys.argv) != 2:
        print("Usage: python3 scripts/generate-icons.py <prefix>")
        print("Example: python3 scripts/generate-icons.py lucide")
        sys.exit(1)

    prefix = sys.argv[1]
    url = f"https://unpkg.com/@iconify-json/{prefix}/icons.json"

    print(f"Fetching {url}...")
    try:
        with urllib.request.urlopen(url) as resp:
            data = json.loads(resp.read())
    except Exception as e:
        print(f"Error fetching icon set '{prefix}': {e}")
        sys.exit(1)

    default_width = data.get("width", 24)
    default_height = data.get("height", 24)
    icons = data["icons"]
    type_name = f"{camel_to_pascal(prefix)}Icons"

    lines = []
    lines.append(f"// Generated from @iconify-json/{prefix} — do not edit by hand.")
    lines.append(f"// Run: python3 scripts/generate-icons.py {prefix}")
    lines.append("")
    lines.append(f"/// Icon registry for the {data.get('info', {}).get('name', prefix)} icon set.")
    lines.append(f"public struct {type_name}: IconRegistry, Sendable {{")
    lines.append(f"    public init() {{}}")
    lines.append("")
    lines.append(f"    public func svg(for name: String) -> String? {{")
    lines.append(f"        Self.icons[name]")
    lines.append(f"    }}")
    lines.append("")
    lines.append(f"    public func viewBox(for name: String) -> String? {{")
    lines.append(f"        guard let icon = Self.sizes[name] else {{")
    lines.append(f'            guard Self.icons[name] != nil else {{ return nil }}')
    lines.append(f'            return "0 0 {default_width} {default_height}"')
    lines.append(f"        }}")
    lines.append(f'        return "0 0 \\(icon.0) \\(icon.1)"')
    lines.append(f"    }}")
    lines.append("")
    lines.append(f"    // {len(icons)} icons")
    lines.append(f"    static let icons: [String: String] = [")
    for name in sorted(icons.keys()):
        body = icons[name]["body"]
        lines.append(f'        "{name}": #"{body}"#,')
    lines.append(f"    ]")

    # Only emit sizes dict if any icons override the default
    custom_sizes = {}
    for name, info in icons.items():
        w = info.get("width", default_width)
        h = info.get("height", default_height)
        if w != default_width or h != default_height:
            custom_sizes[name] = (w, h)

    if custom_sizes:
        lines.append("")
        lines.append(f"    static let sizes: [String: (Int, Int)] = [")
        for name in sorted(custom_sizes.keys()):
            w, h = custom_sizes[name]
            lines.append(f'        "{name}": ({w}, {h}),')
        lines.append(f"    ]")
    else:
        lines.append("")
        lines.append(f"    static let sizes: [String: (Int, Int)] = [:]")

    lines.append("}")
    lines.append("")

    output = "\n".join(lines)
    out_path = f"Sources/Sparrow/Icons/{type_name}.swift"
    with open(out_path, "w") as f:
        f.write(output)

    print(f"Generated {len(icons)} icons → {out_path} ({len(output)} bytes)")

if __name__ == "__main__":
    main()
