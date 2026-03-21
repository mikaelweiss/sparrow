import Foundation
import Sparrow

/// Path to the symbol graph directory, relative to the docs project root.
/// Set via SYMBOLGRAPH_DIR env var, or defaults to the SPM output location.
let symbolGraphDir: String = {
    if let envDir = ProcessInfo.processInfo.environment["SYMBOLGRAPH_DIR"] {
        return envDir
    }
    // Default: look in the parent Sparrow repo's build output
    return "../.build/arm64-apple-macosx/symbolgraph"
}()

/// Load and resolve all symbols at startup.
let resolvedSymbols: [DocSymbol] = {
    do {
        let graphs = try SymbolGraphLoader.loadAll(from: symbolGraphDir)
        let symbols = SymbolResolver.resolve(graphs: graphs)
        print("  Loaded \(symbols.count) top-level symbols from \(symbolGraphDir)")
        return symbols
    } catch {
        print("  Warning: Could not load symbol graphs from \(symbolGraphDir): \(error)")
        print("  Run `./generate-docs.sh` first to extract symbol graphs.")
        return []
    }
}()

/// Build a lookup from slug → symbol for detail pages.
let symbolsBySlug: [String: DocSymbol] = {
    var map: [String: DocSymbol] = [:]
    for sym in resolvedSymbols {
        map[sym.slug] = sym
    }
    return map
}()

@main
struct SparrowDocs: App {
    init() {}

    var routes: [Route] {
        // Home page
        Page("/", title: "Sparrow Documentation") {
            SidebarLayout {
                NavigationLink("Sparrow", destination: "/")
                    .font(.title3)
                Divider()
                SymbolListView(symbols: resolvedSymbols)
            } main: {
                VStack(alignment: .leading, spacing: 32) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sparrow")
                            .font(.largeTitle)
                        Text(
                            "A Swift web platform. SwiftUI-like code on the server, HTML/CSS in the browser."
                        )
                        .foreground(.textSecondary)
                    }

                    HStack(spacing: 16) {
                        NavigationLink("API Reference", destination: "/api")
                    }

                    Divider()

                    Markdown(
                        """
                        ## Getting Started

                        ```swift
                        import Sparrow

                        @main
                        struct MyApp: App {
                            init() {}

                            var routes: [Route] {
                                Page("/") {
                                    Text("Hello, world!")
                                        .font(.largeTitle)
                                }
                            }
                        }
                        ```

                        Run with `sparrow serve` and open your browser.
                        """)
                }
                .padding(32)

                Spacer()
                Footer {
                    Text("Built with Sparrow")
                }
            }
        }

        // API index
        Page("/api", title: "API Reference — Sparrow") {
            SidebarLayout {
                NavigationLink("Sparrow", destination: "/")
                    .font(.title3)
                Divider()
                SymbolListView(symbols: resolvedSymbols)
            } main: {
                APIIndexView(symbols: resolvedSymbols)

                Spacer()
                Footer {
                    Text("Built with Sparrow")
                }
            }
        }

        // Individual symbol detail pages
        for sym in resolvedSymbols {
            Page("/api/\(sym.slug)", title: "\(sym.name) — Sparrow") {
                SidebarLayout {
                    NavigationLink("Sparrow", destination: "/")
                        .font(.title3)
                    Divider()
                    SymbolListView(symbols: resolvedSymbols)
                } main: {
                    SymbolDetailView(symbol: sym)

                    Spacer()
                    Footer {
                        Text("Built with Sparrow")
                    }
                }
            }
        }

        // LLM-readable docs
        FileRoute("/llms.txt", file: "llms.txt")
    }
}
