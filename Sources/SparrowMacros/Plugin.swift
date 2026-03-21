import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct SparrowMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        PreviewMacro.self,
    ]
}
