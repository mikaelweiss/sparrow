/// Defines a live preview for a Sparrow view or component.
///
/// The macro itself is a no-op marker — `sparrow preview` scans for `#Preview` blocks,
/// extracts the body, and generates preview structs in `.sparrow/preview/`.
///
/// Swift doesn't allow freestanding declaration macros to introduce new names at file scope,
/// so the actual preview infrastructure lives in the CLI build pipeline, not in macro expansion.
///
/// ```swift
/// #Preview("Button States") {
///     MyButton(label: "Default")
///     MyButton(label: "Disabled").disabled(true)
/// }
///
/// #Preview("Home Page", layout: .fullPage) {
///     HomePage().colorScheme(.light)
///     HomePage().colorScheme(.dark)
/// }
/// ```
@freestanding(declaration)
public macro Preview(
    _ name: String? = nil,
    layout: PreviewLayout = .component,
    body: () -> Any
) = #externalMacro(module: "SparrowMacros", type: "PreviewMacro")
