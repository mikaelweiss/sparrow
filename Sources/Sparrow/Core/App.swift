/// The entry point for a Sparrow application.
public protocol App {
    init()
    @RouteBuilder var routes: [Route] { get }
    var port: Int { get }
    var theme: Theme { get }
}

extension App {
    /// Default port: 5456 — "KILN" on a phone keypad.
    public var port: Int { 5456 }

    /// Default theme uses system fonts and the built-in color palette.
    public var theme: Theme { .default }

    /// Entry point — starts the Sparrow server.
    public static func main() async throws {
        let app = Self.init()
        let server = SparrowServer(port: app.port, theme: app.theme)
        print("  Starting Sparrow...")
        try await server.run(routes: app.routes)
    }
}
