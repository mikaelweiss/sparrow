/// Create a redirect route. When matched, the server sends a redirect
/// response instead of rendering a page.
///
/// ```swift
/// Routes {
///     Redirect("/old-path", to: "/new-path")
///     Redirect("/legacy/:id", to: "/modern/:id")  // preserves params
/// }
/// ```
public func Redirect(_ from: String, to destination: String) -> Route {
    Route(
        path: from,
        title: nil,
        contentType: .html,
        layoutId: nil,
        redirect: destination,
        renderBody: { _, _ in "" },
        renderLayout: nil
    )
}
