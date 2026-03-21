/// Displays an image. Renders to `<img>`.
public struct Image: PrimitiveView, Sendable {
    public let source: ImageSource
    public let alt: String

    /// Create an image from a named asset. Uses the asset name as default alt text.
    public init(_ name: String, alt: String? = nil) {
        self.source = .asset(name)
        self.alt = alt ?? name
    }

    /// Create an image from a URL.
    public init(url: String, alt: String = "") {
        self.source = .url(url)
        self.alt = alt
    }

    public enum ImageSource: Sendable {
        case asset(String)
        case url(String)
    }
}
