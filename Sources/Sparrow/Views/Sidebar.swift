/// A persistent navigation sidebar.
/// On mobile: hidden by default, slides in as overlay (hamburger trigger).
/// On desktop: persistent, always visible.
public struct Sidebar<Content: View>: View {
    public typealias Body = Never
    public let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Never { fatalError("Sidebar should not have body called") }
}

extension Sidebar: Sendable where Content: Sendable {}

/// A two-pane layout with sidebar and main content.
/// On mobile: sidebar collapses to hamburger overlay.
/// On desktop: sidebar is persistent alongside content.
public struct SidebarLayout<SidebarContent: View, MainContent: View>: View {
    public typealias Body = Never
    public let sidebar: SidebarContent
    public let main: MainContent

    public init(
        @ViewBuilder sidebar: () -> SidebarContent,
        @ViewBuilder main: () -> MainContent
    ) {
        self.sidebar = sidebar()
        self.main = main()
    }

    public var body: Never { fatalError("SidebarLayout should not have body called") }
}

extension SidebarLayout: Sendable where SidebarContent: Sendable, MainContent: Sendable {}
