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

/// A route mapping a URL path to a rendered view.
public struct Route: Sendable {
    public let path: String
    public let title: String?
    public let contentType: RouteContentType
    /// Closure instead of a stored View because Route is not generic — it needs to
    /// hold any view type. The closure captures the concrete view at init time.
    let _renderBody: @Sendable (HTMLRenderer) -> String

    public init<V: View & Sendable>(path: String, title: String? = nil, view: V) {
        self.path = path
        self.title = title
        self.contentType = .html
        self._renderBody = { renderer in
            renderer.render(view)
        }
    }

    /// Create a file route that serves a file from disk (no HTML wrapping).
    /// The `file` parameter is a path relative to the project root.
    public init(path: String, contentType: RouteContentType = .plain, file: String) {
        self.path = path
        self.title = nil
        self.contentType = contentType
        self._renderBody = { _ in
            (try? String(contentsOfFile: file, encoding: .utf8)) ?? ""
        }
    }

    /// Render just the body HTML (used by SessionActor for re-renders).
    func renderBody(with renderer: HTMLRenderer) -> String {
        _renderBody(renderer)
    }

    /// Render the full HTML document for this route (SSR).
    public func renderDocument(with renderer: HTMLRenderer, themeCSS: String = "") -> String {
        let bodyHTML = _renderBody(renderer)
        let devScript = DevReload.scriptTag
        let runtimeScript = ClientRuntime.script
        return """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <title>\(escapeHTML(title ?? "Sparrow App"))</title>
            <style>\(CSSGenerator.defaultStylesheet)\(themeCSS)</style>
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
