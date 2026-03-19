/// The entry point for a Sparrow application.
public protocol App {
    init()
    @RouteBuilder var routes: [Route] { get }
    var port: Int { get }
}

extension App {
    public var port: Int { 3000 }

    /// Entry point — starts the Sparrow server.
    public static func main() async throws {
        let app = Self.init()
        let server = SparrowServer(port: app.port)
        print("  Starting Sparrow...")
        try await server.run(routes: app.routes)
    }
}
