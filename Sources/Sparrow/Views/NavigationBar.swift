/// A top navigation bar with title and optional leading/trailing items.
/// On mobile: compact with back button. On desktop: full width with actions.
public struct NavigationBar<Leading: View, Trailing: View>: View {
    public typealias Body = Never
    public let title: String
    public let leading: Leading
    public let trailing: Trailing

    public init(
        _ title: String,
        @ViewBuilder leading: () -> Leading = { EmptyView() as! Leading },
        @ViewBuilder trailing: () -> Trailing = { EmptyView() as! Trailing }
    ) {
        self.title = title
        self.leading = leading()
        self.trailing = trailing()
    }

    public var body: Never { fatalError("NavigationBar should not have body called") }
}

extension NavigationBar: Sendable where Leading: Sendable, Trailing: Sendable {}
