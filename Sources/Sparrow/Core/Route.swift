import Foundation

/// Content type for a route response.
public enum RouteContentType: Sendable {
    case html
    case plain
    case markdown

    var header: String {
        switch self {
        case .html: return "text/html; charset=utf-8"
        case .plain: return "text/plain; charset=utf-8"
        case .markdown: return "text/markdown; charset=utf-8"
        }
    }
}

/// A route mapping a URL pattern to a rendered view.
public struct Route: Sendable {
    public let path: String
    public let pattern: RoutePattern
    public let title: String?
    public let contentType: RouteContentType
    public let layoutId: String?
    public let redirect: String?
    let _renderBody: @Sendable (HTMLRenderer, RouteParams) -> String
    let _renderLayout: (@Sendable (HTMLRenderer, String) -> String)?

    // MARK: - Static view route (backward compatible)

    public init<V: View & Sendable>(path: String, title: String? = nil, view: V) {
        self.path = path
        self.pattern = RoutePattern(path)
        self.title = title
        self.contentType = .html
        self.layoutId = nil
        self.redirect = nil
        self._renderBody = { renderer, _ in
            renderer.render(view)
        }
        self._renderLayout = nil
    }

    // MARK: - Parameterized view route

    public init<V: View & Sendable>(
        path: String,
        title: String? = nil,
        viewBuilder: @escaping @Sendable (RouteParams) -> V
    ) {
        self.path = path
        self.pattern = RoutePattern(path)
        self.title = title
        self.contentType = .html
        self.layoutId = nil
        self.redirect = nil
        self._renderBody = { renderer, params in
            renderer.render(viewBuilder(params))
        }
        self._renderLayout = nil
    }

    // MARK: - File route

    public init(path: String, contentType: RouteContentType = .plain, file: String) {
        self.path = path
        self.pattern = RoutePattern(path)
        self.title = nil
        self.contentType = contentType
        self.layoutId = nil
        self.redirect = nil
        self._renderBody = { _, _ in
            (try? String(contentsOfFile: file, encoding: .utf8)) ?? ""
        }
        self._renderLayout = nil
    }

    // MARK: - 404 / Not Found route

    public init<V: View & Sendable>(notFound view: V) {
        self.path = ""
        self.pattern = RoutePattern(notFound: true)
        self.title = "Not Found"
        self.contentType = .html
        self.layoutId = nil
        self.redirect = nil
        self._renderBody = { renderer, _ in
            renderer.render(view)
        }
        self._renderLayout = nil
    }

    // MARK: - Internal: full initializer (used by RouteGroup, Redirect)

    init(
        path: String,
        title: String?,
        contentType: RouteContentType,
        layoutId: String?,
        redirect: String?,
        renderBody: @escaping @Sendable (HTMLRenderer, RouteParams) -> String,
        renderLayout: (@Sendable (HTMLRenderer, String) -> String)?
    ) {
        self.path = path
        self.pattern = RoutePattern(path)
        self.title = title
        self.contentType = contentType
        self.layoutId = layoutId
        self.redirect = redirect
        self._renderBody = renderBody
        self._renderLayout = renderLayout
    }

    /// Resolve a redirect destination, interpolating captured params.
    public func resolveRedirect(params: RouteParams) -> String? {
        guard var dest = redirect else { return nil }
        for (key, value) in params.segments {
            dest = dest.replacingOccurrences(of: ":\(key)", with: value)
        }
        return dest
    }

    /// Render just the body HTML (no layout, used by SessionActor for re-renders).
    func renderBody(with renderer: HTMLRenderer, params: RouteParams = .empty) -> String {
        _renderBody(renderer, params)
    }

    /// Render the full body HTML including layout if present.
    func renderFullBody(with renderer: HTMLRenderer, params: RouteParams = .empty) -> String {
        if let renderLayout = _renderLayout {
            let contentHTML = _renderBody(renderer, params)
            return renderLayout(renderer, contentHTML)
        }
        return _renderBody(renderer, params)
    }

    /// Render the full HTML document for this route (SSR).
    public func renderDocument(with renderer: HTMLRenderer, params: RouteParams = .empty) -> String {
        let bodyHTML = renderFullBody(with: renderer, params: params)
        let devScript = DevReload.scriptTag
        let runtimeScript = ClientRuntime.script
        return """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <title>\(escapeHTML(title ?? "Sparrow App"))</title>
            <style>\(CSSGenerator.defaultStylesheet)</style>
        </head>
        <body>
            <div id="sparrow-root">
        \(bodyHTML)
            </div>\(devScript)
            \(runtimeScript)
        </body>
        </html>
        """
    }
}
