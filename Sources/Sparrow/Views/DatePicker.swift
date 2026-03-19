/// A date selection control. Renders to `<input type="date">`.
/// Accepts a `Binding<String>` to round-trip the date value from the browser.
public struct DatePicker: PrimitiveView, Sendable {
    public let label: String
    public let selection: Binding<String>

    public init(_ label: String, selection: Binding<String>) {
        self.label = label
        self.selection = selection
    }
}
