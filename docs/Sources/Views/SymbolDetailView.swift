import Sparrow
import SparrowMarkdown

/// Detail page for a single API symbol — shows declaration, doc comment, and members.
struct SymbolDetailView: View {
    let symbol: DocSymbol

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Badge(symbol.kindDisplayName, style: badgeStyle)
                    Text(symbol.name)
                        .font(.largeTitle)
                }
                // Declaration
                Markdown("```swift\n\(symbol.declaration)\n```")
            }

            Divider()

            // Doc comment rendered as Markdown
            if !symbol.docComment.isEmpty {
                Markdown(symbol.docComment)
            }

            // Members
            if !initializers.isEmpty {
                MemberSection(title: "Initializers", members: initializers)
            }
            if !properties.isEmpty {
                MemberSection(title: "Properties", members: properties)
            }
            if !methods.isEmpty {
                MemberSection(title: "Methods", members: methods)
            }
            if !cases.isEmpty {
                MemberSection(title: "Cases", members: cases)
            }
            if !typeAliases.isEmpty {
                MemberSection(title: "Type Aliases", members: typeAliases)
            }
            if !typeProperties.isEmpty {
                MemberSection(title: "Type Properties", members: typeProperties)
            }
            if !typeMethods.isEmpty {
                MemberSection(title: "Type Methods", members: typeMethods)
            }
        }
        .padding(32)
    }

    // MARK: - Filtered children

    private var initializers: [DocSymbol] {
        symbol.children.filter { $0.kind == "swift.init" }
    }

    private var properties: [DocSymbol] {
        symbol.children.filter { $0.kind == "swift.property" }
    }

    private var methods: [DocSymbol] {
        symbol.children.filter { $0.kind == "swift.method" }
    }

    private var cases: [DocSymbol] {
        symbol.children.filter { $0.kind == "swift.enum.case" }
    }

    private var typeAliases: [DocSymbol] {
        symbol.children.filter { $0.kind == "swift.typealias" }
    }

    private var typeProperties: [DocSymbol] {
        symbol.children.filter { $0.kind == "swift.type.property" }
    }

    private var typeMethods: [DocSymbol] {
        symbol.children.filter { $0.kind == "swift.type.method" }
    }

    private var badgeStyle: BadgeStyle {
        switch symbol.kind {
        case "swift.protocol": return .info
        case "swift.struct": return .success
        case "swift.class": return .warning
        case "swift.enum": return .default
        default: return .default
        }
    }
}

/// A section listing members (properties, methods, etc.) of a symbol.
struct MemberSection: View {
    let title: String
    let members: [DocSymbol]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2)

            ForEach(members) { member in
                VStack(alignment: .leading, spacing: 4) {
                    Markdown("```swift\n\(member.declaration)\n```")
                    if !member.docComment.isEmpty {
                        Markdown(member.docComment)
                    }
                }
            }
        }
    }
}
