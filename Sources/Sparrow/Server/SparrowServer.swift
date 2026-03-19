import Foundation
import Hummingbird
import HummingbirdWebSocket

/// The Sparrow HTTP server. Serves rendered HTML pages and manages WebSocket connections.
public struct SparrowServer: Sendable {
    let port: Int

    public init(port: Int = 5456) {
        self.port = port
    }

    /// Start the server with a set of routes.
    public func run(routes: [Route]) async throws {
        let httpRouter = Router()

        for route in routes {
            let route = route
            httpRouter.get(RouterPath(route.path)) { _, _ -> Response in
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
        httpRouter.get("/health") { _, _ -> Response in
            Response(
                status: .ok,
                headers: [.contentType: "application/json"],
                body: .init(byteBuffer: .init(string: "{\"status\": \"ok\"}"))
            )
        }

        // Dev reload: returns the server PID so the client can detect restarts
        if DevReload.isDevMode {
            let pid = "\(ProcessInfo.processInfo.processIdentifier)"
            httpRouter.get("/_sparrow/build-id") { _, _ -> Response in
                Response(
                    status: .ok,
                    headers: [
                        .contentType: "text/plain",
                        .cacheControl: "no-cache, no-store",
                    ],
                    body: .init(byteBuffer: .init(string: pid))
                )
            }
        }

        // WebSocket router for live interactivity
        let routes = routes
        let wsRouter = Router(context: BasicWebSocketRequestContext.self)
        wsRouter.ws("/sparrow/ws") { _, _ in
            .upgrade([:])
        } onUpgrade: { inbound, outbound, _ in
            try await handleWebSocket(
                inbound: inbound,
                outbound: outbound,
                routes: routes
            )
        }

        let app = Application(
            router: httpRouter,
            server: .http1WebSocketUpgrade(webSocketRouter: wsRouter),
            configuration: .init(address: .hostname("127.0.0.1", port: port))
        )

        print("  Sparrow server running at http://127.0.0.1:\(port)")
        try await app.runService()
    }
}

// MARK: - WebSocket handler

/// Handles a single WebSocket connection lifecycle.
private func handleWebSocket(
    inbound: WebSocketInboundStream,
    outbound: WebSocketOutboundWriter,
    routes: [Route]
) async throws {
    var session: SessionActor?

    for try await message in inbound.messages(maxSize: 1 << 16) {
        guard case .text(let text) = message else { continue }
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let type = json["type"] as? String else { continue }

        switch type {
        case "init":
            // Client connected and is telling us which page it's on
            let url = json["url"] as? String ?? "/"
            if let route = routes.first(where: { $0.path == url }) {
                let renderBody = route._renderBody
                session = SessionActor(
                    sessionId: UUID().uuidString,
                    renderBody: renderBody
                )
            }

        case "event":
            guard let id = json["id"] as? String,
                  let event = json["event"] as? String,
                  let session else { continue }

            if let patches = await session.handleEvent(id: id, event: event) {
                let patchJSON = patches.map { $0.toJSON() }.joined(separator: ",")
                let response = "{\"type\":\"patch\",\"patches\":[\(patchJSON)]}"
                try await outbound.write(.text(response))
            }

        case "navigate":
            let url = json["url"] as? String ?? "/"
            if let route = routes.first(where: { $0.path == url }) {
                let renderBody = route._renderBody
                session = SessionActor(
                    sessionId: UUID().uuidString,
                    renderBody: renderBody
                )
                let html = await session!.getHTML()
                let escaped = html
                    .replacingOccurrences(of: "\\", with: "\\\\")
                    .replacingOccurrences(of: "\"", with: "\\\"")
                    .replacingOccurrences(of: "\n", with: "\\n")
                let title = route.title ?? "Sparrow App"
                let response = "{\"type\":\"page\",\"html\":\"\(escaped)\",\"url\":\"\(url)\",\"title\":\"\(title)\"}"
                try await outbound.write(.text(response))
            }

        case "ping":
            try await outbound.write(.text("{\"type\":\"pong\"}"))

        default:
            break
        }
    }
}
