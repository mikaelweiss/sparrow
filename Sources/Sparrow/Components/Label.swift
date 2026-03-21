/// Label component matching ShadCN Label.
public struct Label: PrimitiveView, Sendable {
    public let text: String
    public let htmlFor: String?

    public init(_ text: String, for id: String? = nil) {
        self.text = text
        self.htmlFor = id
    }
}
