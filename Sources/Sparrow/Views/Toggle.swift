/// A boolean toggle. Renders to a styled `<input type="checkbox">`.
/// Accepts a `Binding<Bool>` to round-trip the checked state from the browser.
public struct Toggle: PrimitiveView, Sendable {
    public let label: String
    public let isOn: Binding<Bool>

    public init(_ label: String, isOn: Binding<Bool>) {
        self.label = label
        self.isOn = isOn
    }
}
