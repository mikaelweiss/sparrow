import Sparrow

/// The main API reference index page — lists all top-level symbols.
struct APIIndexView: View {
    let symbols: [DocSymbol]

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 8) {
                Text("API Reference")
                    .font(.largeTitle)
                Text("Complete reference for all public Sparrow types, protocols, and functions.")
                    .foreground(.textSecondary)
            }

            Divider()

            ForEach(groups) { group in
                VStack(alignment: .leading, spacing: 12) {
                    Text(group.kind)
                        .font(.title2)

                    Grid(columns: 2, spacing: 12) {
                        ForEach(group.symbols) { sym in
                            Card {
                                VStack(alignment: .leading, spacing: 4) {
                                    NavigationLink(sym.name, destination: "/api/\(sym.slug)")
                                        .font(.headline)
                                    if !sym.docComment.isEmpty {
                                        Text(firstLine(of: sym.docComment))
                                            .font(.footnote)
                                            .foreground(.textSecondary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(32)
    }

    private var groups: [SymbolGroup] {
        let order: [String] = [
            "Protocol", "Structure", "Class", "Enumeration", "Function", "Type Alias",
        ]
        var grouped: [String: [DocSymbol]] = [:]
        for sym in symbols {
            grouped[sym.kindDisplayName, default: []].append(sym)
        }
        return order.compactMap { kind in
            guard let syms = grouped[kind], !syms.isEmpty else { return nil }
            return SymbolGroup(kind: kind, symbols: syms)
        }
    }
}

private func firstLine(of text: String) -> String {
    let line = text.prefix(while: { $0 != "\n" })
    if line.count > 120 {
        return String(line.prefix(117)) + "..."
    }
    return String(line)
}
