/// Displays an image. Renders to `<img>`.
public struct Image: PrimitiveView, Sendable {
    public let source: ImageSource

    /// Create an image from a named asset.
    public init(_ name: String) {
        self.source = .asset(name)
    }

    /// Create an image from a URL.
    public init(url: String) {
        self.source = .url(url)
    }

    public enum ImageSource: Sendable {
        case asset(String)
        case url(String)
    }
}
