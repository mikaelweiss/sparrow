# Sparrow Preview — Zed Extension

Live preview panel for Sparrow web framework components, similar to SwiftUI previews in Xcode.

## How It Works

The extension registers a language server that automatically starts `sparrow preview --lsp` when you open a Sparrow project. The preview server runs in the background on port 5457 and stops when you close the workspace.

1. Open a Sparrow project in Zed (any project with `Package.swift` depending on Sparrow)
2. The preview server starts automatically
3. Open `http://localhost:5457/_preview/` in a browser (or Zed's built-in browser when available)
4. Edit your views — previews update on save
5. Close the workspace — preview server stops

When you switch files in Zed, the extension notifies the preview server to show that file's `#Preview` blocks.

## Prerequisites

- `sparrow` CLI in your PATH
- A Sparrow project with `#Preview` blocks

## Development

Install as a dev extension directly in Zed (preferred — Zed handles the build):

1. Open Zed's extensions panel (`zed: extensions` in command palette)
2. Click **Install Dev Extension**
3. Select the `zed-extension/` directory

To build manually:

```bash
rustup target add wasm32-wasip2
cd zed-extension
cargo build --target wasm32-wasip2
```
