import Foundation

// MARK: - Symbol Graph JSON Models

/// Top-level structure of a `.symbols.json` file produced by
/// `swift package dump-symbol-graph`.
struct SymbolGraph: Codable, Sendable {
    let metadata: Metadata
    let module: Module
    let symbols: [Symbol]
    let relationships: [Relationship]

    struct Metadata: Codable, Sendable {
        let formatVersion: FormatVersion
        let generator: String?
    }

    struct FormatVersion: Codable, Sendable {
        let major: Int
        let minor: Int
        let patch: Int
    }

    struct Module: Codable, Sendable {
        let name: String
    }
}

// MARK: - Symbol

struct Symbol: Codable, Sendable {
    let kind: Kind
    let identifier: Identifier
    let pathComponents: [String]
    let names: Names
    let docComment: DocComment?
    let declarationFragments: [DeclarationFragment]?
    let accessLevel: String
    let location: Location?

    struct Kind: Codable, Sendable {
        let identifier: String
        let displayName: String
    }

    struct Identifier: Codable, Sendable {
        let precise: String
        let interfaceLanguage: String
    }

    struct Names: Codable, Sendable {
        let title: String
        let subHeading: [DeclarationFragment]?
    }

    struct DocComment: Codable, Sendable {
        let lines: [Line]

        struct Line: Codable, Sendable {
            let text: String
        }
    }

    struct DeclarationFragment: Codable, Sendable {
        let kind: String
        let spelling: String
        let preciseIdentifier: String?
    }

    struct Location: Codable, Sendable {
        let uri: String
        let position: Position

        struct Position: Codable, Sendable {
            let line: Int
            let character: Int
        }
    }
}

// MARK: - Relationship

struct Relationship: Codable, Sendable {
    let kind: String
    let source: String
    let target: String
}

// MARK: - Loader

enum SymbolGraphLoader {
    /// Loads a symbol graph from a JSON file at the given path.
    static func load(from path: String) throws -> SymbolGraph {
        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        return try JSONDecoder().decode(SymbolGraph.self, from: data)
    }

    /// Loads all `.symbols.json` files from a directory.
    static func loadAll(from directory: String) throws -> [SymbolGraph] {
        let fm = FileManager.default
        let files = try fm.contentsOfDirectory(atPath: directory)
            .filter { $0.hasSuffix(".symbols.json") }
            .sorted()
        return try files.map { try load(from: directory + "/" + $0) }
    }
}

// MARK: - Resolved Documentation Model

/// A resolved symbol ready for rendering, with children attached.
struct DocSymbol: Sendable {
    let name: String
    let kind: String
    let kindDisplayName: String
    let declaration: String
    let docComment: String
    let pathComponents: [String]
    let preciseIdentifier: String
    let sourceFile: String?
    var children: [DocSymbol]

    /// URL-safe slug for this symbol's page.
    var slug: String {
        pathComponents.joined(separator: "/")
    }

    /// Renders the declaration fragments into a single string.
    static func declarationString(from fragments: [Symbol.DeclarationFragment]?) -> String {
        (fragments ?? []).map(\.spelling).joined()
    }

    /// Extracts the doc comment text from the symbol graph lines.
    static func docCommentString(from comment: Symbol.DocComment?) -> String {
        (comment?.lines ?? []).map(\.text).joined(separator: "\n")
    }
}

/// Resolves a flat list of symbols + relationships into a tree of `DocSymbol`s.
enum SymbolResolver {
    static func resolve(graphs: [SymbolGraph]) -> [DocSymbol] {
        // Merge all symbols and relationships
        var allSymbols: [String: Symbol] = [:]
        var allRelationships: [Relationship] = []

        for graph in graphs {
            for symbol in graph.symbols {
                allSymbols[symbol.identifier.precise] = symbol
            }
            allRelationships.append(contentsOf: graph.relationships)
        }

        // Build parent→children map from relationships
        var childrenMap: [String: [String]] = [:]
        let memberKinds: Set<String> = ["memberOf", "requirementOf", "optionalRequirementOf"]
        for rel in allRelationships where memberKinds.contains(rel.kind) {
            childrenMap[rel.target, default: []].append(rel.source)
        }

        // Conformance map for protocol conformances
        var conformanceMap: [String: [String]] = [:]
        for rel in allRelationships where rel.kind == "conformsTo" {
            conformanceMap[rel.source, default: []].append(rel.target)
        }

        // Build DocSymbol tree
        let topLevelKinds: Set<String> = [
            "swift.struct", "swift.class", "swift.enum", "swift.protocol",
            "swift.func", "swift.type.method", "swift.typealias",
        ]

        // Find top-level symbols (not a child of anything)
        let allChildIDs = Set(childrenMap.values.flatMap { $0 })

        var topLevel: [DocSymbol] = []
        for symbol in allSymbols.values {
            guard topLevelKinds.contains(symbol.kind.identifier) else { continue }
            // Skip symbols that are members of another symbol
            guard !allChildIDs.contains(symbol.identifier.precise) else { continue }
            // Skip inherited/synthesized modifiers (e.g. View extension methods repeated on every type)
            guard symbol.pathComponents.count <= 2 else { continue }

            let doc = buildDocSymbol(symbol: symbol, allSymbols: allSymbols, childrenMap: childrenMap)
            topLevel.append(doc)
        }

        // Sort: protocols first, then structs, then enums, then funcs
        let kindOrder: [String: Int] = [
            "swift.protocol": 0, "swift.struct": 1, "swift.class": 2,
            "swift.enum": 3, "swift.func": 4, "swift.typealias": 5,
        ]
        topLevel.sort { a, b in
            let ao = kindOrder[a.kind] ?? 99
            let bo = kindOrder[b.kind] ?? 99
            if ao != bo { return ao < bo }
            return a.name < b.name
        }

        return topLevel
    }

    private static func buildDocSymbol(
        symbol: Symbol,
        allSymbols: [String: Symbol],
        childrenMap: [String: [String]]
    ) -> DocSymbol {
        let childIDs = childrenMap[symbol.identifier.precise] ?? []
        let children: [DocSymbol] = childIDs.compactMap { childID in
            guard let childSym = allSymbols[childID] else { return nil }
            // Skip synthesized/inherited modifier methods
            let skipKinds: Set<String> = ["swift.func.op"]
            guard !skipKinds.contains(childSym.kind.identifier) else { return nil }
            return buildDocSymbol(symbol: childSym, allSymbols: allSymbols, childrenMap: childrenMap)
        }.sorted { $0.name < $1.name }

        return DocSymbol(
            name: symbol.names.title,
            kind: symbol.kind.identifier,
            kindDisplayName: symbol.kind.displayName,
            declaration: DocSymbol.declarationString(from: symbol.declarationFragments),
            docComment: DocSymbol.docCommentString(from: symbol.docComment),
            pathComponents: symbol.pathComponents,
            preciseIdentifier: symbol.identifier.precise,
            sourceFile: symbol.location?.uri,
            children: children
        )
    }
}
