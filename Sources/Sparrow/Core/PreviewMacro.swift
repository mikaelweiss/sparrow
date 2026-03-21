/// Defines a live preview for a Sparrow view or component.
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
@freestanding(declaration, names: arbitrary)
public macro Preview(
    _ name: String? = nil,
    layout: PreviewLayout = .component
) = #externalMacro(module: "SparrowMacros", type: "PreviewMacro")
