/// A date selection control. Renders to `<input type="date">`.
public struct DatePicker: PrimitiveView, Sendable {
    public let label: String
    public let selection: String

    public init(_ label: String, selection: String = "") {
        self.label = label
        self.selection = selection
    }
}
