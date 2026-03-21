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

/// The `#Preview` macro expands to nothing in regular builds.
///
/// Preview structs are generated externally by `sparrow preview` (via PreviewRegistryGenerator)
/// because Swift doesn't allow freestanding declaration macros to introduce new named types
/// at file scope. The macro exists so `#Preview` is valid syntax and the compiler parses
/// the trailing closure (catching basic errors), but the real work happens in the CLI pipeline.
public struct PreviewMacro: DeclarationMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // No-op: the CLI generates preview structs externally.
        // The trailing closure is parsed by the compiler but not expanded here.
        return []
    }
}
