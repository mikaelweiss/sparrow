/// A provider of SVG icon content, keyed by name.
///
/// Sparrow loads icons at runtime from the Iconify CDN based on your
/// App's ``IconSet`` configuration. Implement this protocol for custom icon sets.
public protocol IconRegistry: Sendable {
    /// Returns the inner SVG markup (paths, circles, etc.) for the given icon name,
    /// or `nil` if the icon is not found.
    func svg(for name: String) -> String?

    /// Returns the viewBox for the given icon (e.g. "0 0 24 24").
    /// Defaults to "0 0 24 24" if not implemented.
    func viewBox(for name: String) -> String?
}

extension IconRegistry {
    public func viewBox(for name: String) -> String? { "0 0 24 24" }
}

/// Global icon configuration. Set automatically at server startup based on the App's iconSet.
public enum IconConfiguration {
    nonisolated(unsafe) public static var registry: (any IconRegistry)?
}
