/// A route mapping a URL path to a rendered view.
public struct Route: Sendable {
    public let path: String
    public let title: String?
    let _renderBody: @Sendable (HTMLRenderer) -> String

    public init<V: View & Sendable>(path: String, title: String? = nil, view: V) {
        self.path = path
        self.title = title
        self._renderBody = { renderer in
            renderer.render(view)
        }
    }

    /// Render just the body HTML (used by SessionActor for re-renders).
    func renderBody(with renderer: HTMLRenderer) -> String {
        _renderBody(renderer)
    }

    /// Render the full HTML document for this route (SSR).
    public func renderDocument(with renderer: HTMLRenderer) -> String {
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
