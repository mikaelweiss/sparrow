/// A labeled checkbox. Renders to `<label>` with `<input type="checkbox">`.
public struct Checkbox: PrimitiveView, Sendable {
    public let label: String
    public let isChecked: Bool

    public init(_ label: String, isChecked: Bool = false) {
        self.label = label
        self.isChecked = isChecked
    }
}
