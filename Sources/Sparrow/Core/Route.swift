/// A route mapping a URL path to a rendered view.
public struct Route: Sendable {
    public let path: String
    public let title: String?
    private let _renderBody: @Sendable (HTMLRenderer) -> String

    public init<V: View & Sendable>(path: String, title: String? = nil, view: V) {
        self.path = path
        self.title = title
        self._renderBody = { renderer in
            renderer.render(view)
        }
    }

    /// Render the full HTML document for this route.
    public func renderDocument(with renderer: HTMLRenderer) -> String {
        let bodyHTML = _renderBody(renderer)
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
            </div>
        </body>
        </html>
        """
    }
}
