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
        let allRoutes = routes
        let themeCSS = self.themeCSS

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

        // Catch-all route handler — matches all GET requests against our routes
        httpRouter.get("**") { request, _ -> Response in
            Self.handleHTTPRequest(path: request.uri.path, routes: allRoutes, themeCSS: themeCSS)
        }

        // WebSocket router for live interactivity
        let wsRouter = Router(context: BasicWebSocketRequestContext.self)
        wsRouter.ws("/sparrow/ws") { _, _ in
            .upgrade([:])
        } onUpgrade: { inbound, outbound, _ in
            try await handleWebSocket(
                inbound: inbound,
                outbound: outbound,
                routes: allRoutes
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

    /// Match a request path against routes and render the response.
    private static func handleHTTPRequest(path: String, routes: [Route], themeCSS: String = "") -> Response {
        let (cleanPath, query) = parseURL(path)

        // Try matching each route
        for route in routes where !route.pattern.isNotFound && route.redirect == nil {
            if var params = route.pattern.match(cleanPath) {
                params = RouteParams(segments: params.segments, query: query, wildcard: params.wildcard)

                switch route.contentType {
                case .plain, .markdown:
                    let renderer = HTMLRenderer()
                    renderer.renderState.currentPath = cleanPath
                    let text = route.renderBody(with: renderer, params: params)
                    return Response(
                        status: .ok,
                        headers: [.contentType: route.contentType.header],
                        body: .init(byteBuffer: .init(string: text))
                    )
                case .html:
                    let renderer = HTMLRenderer()
                    renderer.renderState.currentPath = cleanPath
                    let html = route.renderDocument(with: renderer, params: params, themeCSS: themeCSS)
                    return Response(
                        status: .ok,
                        headers: [.contentType: route.contentType.header],
                        body: .init(byteBuffer: .init(string: html))
                    )
                }
            }
        }

        // Check for redirects
        for route in routes where route.redirect != nil {
            if let params = route.pattern.match(cleanPath),
               let dest = route.resolveRedirect(params: params)
            {
                return Response(
                    status: .movedPermanently,
                    headers: [.location: dest]
                )
            }
        }

        // 404 — use custom not-found page if defined
        if let notFoundRoute = routes.first(where: { $0.pattern.isNotFound }) {
            let renderer = HTMLRenderer()
            let html = notFoundRoute.renderDocument(with: renderer)
            return Response(
                status: .notFound,
                headers: [.contentType: "text/html; charset=utf-8"],
                body: .init(byteBuffer: .init(string: html))
            )
        }

        // Default 404
        return Response(
            status: .notFound,
            headers: [.contentType: "text/plain"],
            body: .init(byteBuffer: .init(string: "Not Found"))
        )
    }
}

// MARK: - URL parsing

/// Strip query string and fragment from a URL path, parse query params.
func parseURL(_ url: String) -> (path: String, query: [String: String]) {
    // Strip fragment
    let withoutFragment: String
    if let hashIndex = url.firstIndex(of: "#") {
        withoutFragment = String(url[..<hashIndex])
    } else {
        withoutFragment = url
    }

    // Strip query string
    let path: String
    let queryString: String?
    if let qIndex = withoutFragment.firstIndex(of: "?") {
        path = String(withoutFragment[..<qIndex])
        queryString = String(withoutFragment[withoutFragment.index(after: qIndex)...])
    } else {
        path = withoutFragment
        queryString = nil
    }

    // Parse query params
    var query: [String: String] = [:]
    if let qs = queryString {
        for param in qs.split(separator: "&") {
            let kv = param.split(separator: "=", maxSplits: 1)
            let key = String(kv[0])
            let value = kv.count > 1 ? String(kv[1]) : ""
            query[key] = value
        }
    }

    return (path, query)
}

/// Find the first route matching a path, returning the route and extracted params.
func matchRoute(_ path: String, query: [String: String] = [:], routes: [Route]) -> (Route, RouteParams)? {
    for route in routes where !route.pattern.isNotFound && route.redirect == nil {
        if var params = route.pattern.match(path) {
            params = RouteParams(segments: params.segments, query: query, wildcard: params.wildcard)
            return (route, params)
        }
    }
    return nil
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
    var currentLayoutId: String?

    for try await message in inbound.messages(maxSize: 1 << 16) {
        guard case .text(let text) = message else { continue }
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let type = json["type"] as? String else { continue }

        switch type {
        case "init":
            let url = json["url"] as? String ?? "/"
            let (path, query) = parseURL(url)
            if let (route, params) = matchRoute(path, query: query, routes: routes) {
                currentLayoutId = route.layoutId
                let renderBody: @Sendable (HTMLRenderer) -> String = { renderer in
                    renderer.renderState.currentPath = path
                    return route.renderFullBody(with: renderer, params: params)
                }
                session = SessionActor(
                    sessionId: UUID().uuidString,
                    renderBody: renderBody
                )
            }

        case "event":
            guard let id = json["id"] as? String,
                  let event = json["event"] as? String,
                  let session else { continue }

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
            let (path, query) = parseURL(url)

            // Check for redirect
            var redirected = false
            for route in routes where route.redirect != nil {
                if let params = route.pattern.match(path),
                   let dest = route.resolveRedirect(params: params)
                {
                    let response = "{\"type\":\"redirect\",\"url\":\(jsonEscape(dest))}"
                    try await outbound.write(.text(response))
                    redirected = true
                    break
                }
            }

            if !redirected, let (route, params) = matchRoute(path, query: query, routes: routes) {
                let newLayoutId = route.layoutId
                let renderBody: @Sendable (HTMLRenderer) -> String = { renderer in
                    renderer.renderState.currentPath = path
                    return route.renderFullBody(with: renderer, params: params)
                }
                let title = route.title ?? "Sparrow App"

                // Same layout — swap content only, preserve layout DOM
                if let existingSession = session,
                   let oldLayout = currentLayoutId,
                   let newLayout = newLayoutId,
                   oldLayout == newLayout
                {
                    let contentHTML = await existingSession.navigateContent(
                        newRenderBody: renderBody
                    )
                    let response = "{\"type\":\"content\",\"html\":\(jsonEscape(contentHTML)),\"url\":\(jsonEscape(url)),\"title\":\(jsonEscape(title))}"
                    try await outbound.write(.text(response))
                } else {
                    // Different layout or no layout — full page replace
                    session = SessionActor(
                        sessionId: UUID().uuidString,
                        renderBody: renderBody
                    )
                    let html = await session!.getHTML()
                    let response = "{\"type\":\"page\",\"html\":\(jsonEscape(html)),\"url\":\(jsonEscape(url)),\"title\":\(jsonEscape(title))}"
                    try await outbound.write(.text(response))
                }
                currentLayoutId = newLayoutId
            }

        case "ping":
            try await outbound.write(.text("{\"type\":\"pong\"}"))

        default:
            break
        }
    }
}
