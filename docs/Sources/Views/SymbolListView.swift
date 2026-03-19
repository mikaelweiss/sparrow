import Sparrow

/// Sidebar-style list of all top-level symbols grouped by kind.
struct SymbolListView: View {
    let symbols: [DocSymbol]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(groupedSymbols) { group in
                Section(header: group.kind) {
                    ForEach(group.symbols) { sym in
                        NavigationLink(sym.name, destination: "/api/\(sym.slug)")
                    }
                }
            }
        }
    }

    private var groupedSymbols: [SymbolGroup] {
        let order: [String] = [
            "Protocol", "Structure", "Class", "Enumeration", "Function", "Type Alias",
        ]
        var groups: [String: [DocSymbol]] = [:]
        for sym in symbols {
            groups[sym.kindDisplayName, default: []].append(sym)
        }
        return order.compactMap { kind in
            guard let syms = groups[kind], !syms.isEmpty else { return nil }
            return SymbolGroup(kind: kind, symbols: syms)
        }
    }
}

struct SymbolGroup: Identifiable, Sendable {
    let kind: String
    let symbols: [DocSymbol]
    var id: String { kind }
}

extension DocSymbol: Identifiable {
    var id: String { preciseIdentifier }
}
