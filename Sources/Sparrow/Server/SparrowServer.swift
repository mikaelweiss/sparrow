import Foundation
import Hummingbird
import HummingbirdWebSocket

/// The Sparrow HTTP server. Serves rendered HTML pages and manages WebSocket connections.
public struct SparrowServer: Sendable {
    let port: Int
    let themeCSS: String

    public init(port: Int = 5456, theme: Theme = .default) {
        self.port = port
        self.themeCSS = CSSGenerator.stylesheet(for: theme)
    }

    /// Start the server with a set of routes.
    public func run(routes: [Route]) async throws {
        let httpRouter = Router()
        let themeCSS = self.themeCSS

        for route in routes {
            let route = route
            httpRouter.get(RouterPath(route.path)) { _, _ -> Response in
                switch route.contentType {
                case .plain, .markdown:
                    let text = route.renderBody(with: HTMLRenderer())
                    return Response(
                        status: .ok,
                        headers: [.contentType: route.contentType.header],
                        body: .init(byteBuffer: .init(string: text))
                    )
                case .html:
                    let renderer = HTMLRenderer()
                    let html = route.renderDocument(with: renderer, themeCSS: themeCSS)
                    return Response(
                        status: .ok,
                        headers: [.contentType: route.contentType.header],
                        body: .init(byteBuffer: .init(string: html))
                    )
                }
            }
        }

        // Static assets (fonts, images, etc.) served from Assets/ directory
        let assetsDir = FileManager.default.currentDirectoryPath + "/Assets"
        httpRouter.get("assets/{path+}") { request, _ -> Response in
            let reqPath = request.uri.path
            guard reqPath.hasPrefix("/assets/") else {
                return Response(status: .notFound)
            }
            let relativePath = String(reqPath.dropFirst("/assets/".count))

            // Prevent directory traversal
            guard !relativePath.contains("..") else {
                return Response(status: .forbidden)
            }

            let filePath = assetsDir + "/" + relativePath
            guard FileManager.default.fileExists(atPath: filePath),
                  let data = FileManager.default.contents(atPath: filePath) else {
                return Response(status: .notFound)
            }

            return Response(
                status: .ok,
                headers: [
                    .contentType: mimeType(for: relativePath),
                    .cacheControl: "public, max-age=31536000, immutable",
                ],
                body: .init(byteBuffer: .init(data: data))
            )
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

private func mimeType(for path: String) -> String {
    if path.hasSuffix(".woff2") { return "font/woff2" }
    if path.hasSuffix(".woff") { return "font/woff" }
    if path.hasSuffix(".ttf") { return "font/ttf" }
    if path.hasSuffix(".otf") { return "font/otf" }
    if path.hasSuffix(".png") { return "image/png" }
    if path.hasSuffix(".jpg") || path.hasSuffix(".jpeg") { return "image/jpeg" }
    if path.hasSuffix(".gif") { return "image/gif" }
    if path.hasSuffix(".svg") { return "image/svg+xml" }
    if path.hasSuffix(".webp") { return "image/webp" }
    if path.hasSuffix(".ico") { return "image/x-icon" }
    if path.hasSuffix(".css") { return "text/css" }
    if path.hasSuffix(".js") { return "application/javascript" }
    if path.hasSuffix(".json") { return "application/json" }
    return "application/octet-stream"
}

// MARK: - WebSocket handler

/// Handles a single WebSocket connection lifecycle. Messages are JSON objects
/// with a "type" field: "init" (page load), "event" (user interaction),
/// "navigate" (client-side navigation), or "ping" (keepalive).
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

            // Extract value — may be a string, bool, or number from JSON
            let value: String?
            if let s = json["value"] as? String { value = s }
            else if let b = json["value"] as? Bool { value = String(b) }
            else if let n = json["value"] as? NSNumber { value = n.stringValue }
            else { value = nil }

            if let patches = await session.handleEvent(id: id, event: event, value: value) {
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
