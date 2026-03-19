/// A tab-based navigation container.
/// On mobile: renders as bottom tab bar. On desktop: renders as top tab strip.
public struct TabView<Content: View>: View {
    public typealias Body = Never
    public let selection: String
    public let content: Content

    public init(
        selection: String,
        @ViewBuilder content: () -> Content
    ) {
        self.selection = selection
        self.content = content()
    }

    public var body: Never { fatalError("TabView should not have body called") }
}

extension TabView: Sendable where Content: Sendable {}

/// Protocol for type-erased access to Tab properties during rendering.
protocol TabProtocol {
    var label: String { get }
    var icon: String? { get }
    var tag: String { get }
    func renderContent(with renderer: HTMLRenderer) -> String
}

/// A single tab item within a TabView.
public struct Tab<Content: View>: View, TabProtocol {
    public typealias Body = Never
    public let label: String
    public let icon: String?
    public let tag: String
    public let content: Content

    public init(
        _ label: String,
        icon: String? = nil,
        tag: String,
        @ViewBuilder content: () -> Content
    ) {
        self.label = label
        self.icon = icon
        self.tag = tag
        self.content = content()
    }

    public var body: Never { fatalError("Tab should not have body called") }

    func renderContent(with renderer: HTMLRenderer) -> String {
        let children = flattenChildren(content)
        return renderer.renderChildren(children)
    }
}

extension Tab: Sendable where Content: Sendable {}
