import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import Testing
@testable import SparrowMacros

let testMacros: [String: any Macro.Type] = [
    "Preview": PreviewMacro.self,
]

@Suite("Preview Macro")
struct PreviewMacroTests {
    @Test("Expands with name and default layout")
    func basicExpansion() {
        assertMacroExpansion(
            """
            #Preview("Button States") {
                Text("Hello")
            }
            """,
            expandedSource: """
            struct _SparrowPreview_\(expectedHash("unknown:2")): SparrowPreview {
                static let name = "Button States"
                static let sourceFile = #filePath
                static let line: Int = 2
                static let layout: PreviewLayout = .component
                @ViewBuilder
                static var content: some View {
                    Text("Hello")
                }
            }
            """,
            macros: testMacros
        )
    }

    @Test("Expands with fullPage layout")
    func fullPageLayout() {
        assertMacroExpansion(
            """
            #Preview("Page", layout: .fullPage) {
                Text("Page")
            }
            """,
            expandedSource: """
            struct _SparrowPreview_\(expectedHash("unknown:2")): SparrowPreview {
                static let name = "Page"
                static let sourceFile = #filePath
                static let line: Int = 2
                static let layout: PreviewLayout = .fullPage
                @ViewBuilder
                static var content: some View {
                    Text("Page")
                }
            }
            """,
            macros: testMacros
        )
    }

    @Test("Expands without name")
    func noName() {
        assertMacroExpansion(
            """
            #Preview {
                Text("Hi")
            }
            """,
            expandedSource: """
            struct _SparrowPreview_\(expectedHash("unknown:1")): SparrowPreview {
                static let name = "Preview (unknown:1)"
                static let sourceFile = #filePath
                static let line: Int = 1
                static let layout: PreviewLayout = .component
                @ViewBuilder
                static var content: some View {
                    Text("Hi")
                }
            }
            """,
            macros: testMacros
        )
    }

    @Test("Expands with multiple views in body")
    func multipleViews() {
        assertMacroExpansion(
            """
            #Preview("Multi") {
                Text("A")
                Text("B")
            }
            """,
            expandedSource: """
            struct _SparrowPreview_\(expectedHash("unknown:2")): SparrowPreview {
                static let name = "Multi"
                static let sourceFile = #filePath
                static let line: Int = 2
                static let layout: PreviewLayout = .component
                @ViewBuilder
                static var content: some View {
                    Text("A")
                    Text("B")
                }
            }
            """,
            macros: testMacros
        )
    }

    @Test("Hash is stable for same input")
    func hashStability() {
        let hash1 = previewHashId("foo/bar.swift:42")
        let hash2 = previewHashId("foo/bar.swift:42")
        #expect(hash1 == hash2)
        #expect(hash1.count == 6)

        let hash3 = previewHashId("foo/bar.swift:43")
        #expect(hash1 != hash3)
    }
}

/// Compute expected hash in tests — mirrors the macro's algorithm.
private func expectedHash(_ input: String) -> String {
    previewHashId(input)
}
