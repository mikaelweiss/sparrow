import SwiftSyntax
import SwiftSyntaxMacros

/// Computes a stable 6-char hex hash from a string using the djb2 algorithm.
/// This function is replicated in PreviewScanner.swift — both MUST produce identical output.
public func previewHashId(_ input: String) -> String {
    var hash: UInt64 = 5381
    for byte in input.utf8 {
        hash = ((hash &<< 5) &+ hash) &+ UInt64(byte)
    }
    let truncated = hash & 0xFFFFFF
    let hexChars = Array("0123456789abcdef")
    var result = ""
    for i in stride(from: 20, through: 0, by: -4) {
        result.append(hexChars[Int((truncated >> i) & 0xF)])
    }
    return result
}

public struct PreviewMacro: DeclarationMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Extract source location for stable hash
        let location = context.location(of: node)
        let filePath = location.map { "\($0.file)" } ?? "unknown"
        let line = location.map { "\($0.line)" } ?? "0"
        let hashInput = "\(filePath):\(line)"
        let hashId = previewHashId(hashInput)

        // Parse arguments
        var name: String?
        var layout: String = ".component"

        for argument in node.arguments {
            if argument.label == nil, let stringLiteral = argument.expression.as(StringLiteralExprSyntax.self) {
                // First positional argument is the name
                name = stringLiteral.segments.description
            } else if argument.label?.text == "layout" {
                layout = argument.expression.trimmedDescription
            }
        }

        // Build the name expression
        let nameExpr: String
        if let name {
            nameExpr = "\"\(name)\""
        } else {
            // Default: "Preview (FileName.swift:42)"
            let cleaned = filePath.filter { $0 != "\"" }
            let fileNameComponent = cleaned.split(separator: "/").last.map(String.init) ?? "unknown"
            nameExpr = "\"Preview (\(fileNameComponent):\(line))\""
        }

        // Extract trailing closure body
        guard let trailingClosure = node.trailingClosure else {
            throw MacroExpansionError.missingTrailingClosure
        }
        let bodyStatements = trailingClosure.statements

        let structDecl: DeclSyntax = """
        struct _SparrowPreview_\(raw: hashId): SparrowPreview {
            static let name = \(raw: nameExpr)
            static let sourceFile = #filePath
            static let line: Int = \(raw: line)
            static let layout: PreviewLayout = \(raw: layout)
            @ViewBuilder
            static var content: some View {
                \(bodyStatements)
            }
        }
        """

        return [structDecl]
    }
}

enum MacroExpansionError: Error, CustomStringConvertible {
    case missingTrailingClosure

    var description: String {
        switch self {
        case .missingTrailingClosure:
            return "#Preview requires a trailing closure containing view content"
        }
    }
}
