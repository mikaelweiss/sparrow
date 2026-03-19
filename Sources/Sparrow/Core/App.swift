/// The entry point for a Sparrow application.
public protocol App {
    init()
    @RouteBuilder var routes: [Route] { get }
    var port: Int { get }
}

extension App {
    /// Default port: 5456 — "KILN" on a phone keypad.
    public var port: Int { 5456 }

    /// Entry point — starts the Sparrow server.
    public static func main() async throws {
        let app = Self.init()
        let server = SparrowServer(port: app.port)
        print("  Starting Sparrow...")
        try await server.run(routes: app.routes)
    }
}
