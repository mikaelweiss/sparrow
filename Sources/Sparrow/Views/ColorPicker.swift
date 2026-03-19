/// A color selection control. Renders to `<input type="color">`.
public struct ColorPicker: PrimitiveView, Sendable {
    public let label: String
    public let selection: String

    public init(_ label: String, selection: String = "#000000") {
        self.label = label
        self.selection = selection
    }
}
