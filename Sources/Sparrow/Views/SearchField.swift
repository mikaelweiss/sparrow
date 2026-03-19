/// A search input. Renders to `<input type="search">` with search icon styling.
public struct SearchField: PrimitiveView, Sendable {
    public let placeholder: String
    public let text: String

    public init(_ placeholder: String = "Search…", text: String = "") {
        self.placeholder = placeholder
        self.text = text
    }
}
