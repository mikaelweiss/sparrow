import Hummingbird

/// The Sparrow HTTP server. Serves rendered HTML pages.
public struct SparrowServer: Sendable {
    let port: Int

    public init(port: Int = 3000) {
        self.port = port
    }

    /// Start the server with a set of routes.
    public func run(routes: [Route]) async throws {
        let router = Router()

        for route in routes {
            let route = route
            router.get(RouterPath(route.path)) { _, _ -> Response in
                let renderer = HTMLRenderer()
                let html = route.renderDocument(with: renderer)
                return Response(
                    status: .ok,
                    headers: [.contentType: "text/html; charset=utf-8"],
                    body: .init(byteBuffer: .init(string: html))
                )
            }
        }

        // Health check
        router.get("/health") { _, _ -> Response in
            Response(
                status: .ok,
                headers: [.contentType: "application/json"],
                body: .init(byteBuffer: .init(string: "{\"status\": \"ok\"}"))
            )
        }

        let app = Application(
            router: router,
            configuration: .init(address: .hostname("127.0.0.1", port: port))
        )

        print("  Sparrow server running at http://127.0.0.1:\(port)")
        try await app.runService()
    }
}
