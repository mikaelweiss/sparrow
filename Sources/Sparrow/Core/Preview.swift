/// How preview variants are displayed in the preview chrome.
public enum PreviewLayout: String, Sendable {
    /// Each variant renders at its natural size. All variants visible simultaneously,
    /// stacked vertically with labels.
    case component

    /// Each variant fills the viewport. One visible at a time, tabs to switch.
    case fullPage
}

/// Conforming types represent a single `#Preview` block. The macro generates these.
public protocol SparrowPreview {
    associatedtype Content: View

    /// Human-readable name shown in the preview chrome.
    static var name: String { get }
    /// Absolute path to the source file containing this preview.
    static var sourceFile: String { get }
    /// Line number in the source file.
    static var line: Int { get }
    /// Display mode for variants.
    static var layout: PreviewLayout { get }

    @ViewBuilder
    static var content: Content { get }
}
