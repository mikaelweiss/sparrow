/// A layout wraps page content with shared chrome (nav, sidebar, footer).
///
/// When navigating between pages in the same layout group, the layout
/// stays and only the `Content()` area re-renders.
///
/// ```swift
/// struct DashboardLayout: Layout {
///     init() {}
///     var body: some View {
///         VStack {
///             NavBar()
///             HStack {
///                 Sidebar()
///                 Content()   // page content renders here
///             }
///         }
///     }
/// }
/// ```
public protocol Layout: View, Sendable {
    init()
}

/// Placeholder within a Layout body that marks where page content renders.
/// There should be exactly one `Content()` per layout.
public struct Content: PrimitiveView, Sendable {
    public init() {}
}
