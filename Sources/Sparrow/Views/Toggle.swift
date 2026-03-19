/// A boolean toggle. Renders to a styled `<input type="checkbox">`.
public struct Toggle: PrimitiveView, Sendable {
    public let label: String
    public let isOn: Bool

    public init(_ label: String, isOn: Bool = false) {
        self.label = label
        self.isOn = isOn
    }
}
