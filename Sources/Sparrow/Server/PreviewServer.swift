import Foundation
import Hummingbird
import HummingbirdWebSocket

/// Metadata for a single preview, derived from a SparrowPreview conformance.
public struct PreviewInfo: Sendable {
    public let id: String
    public let name: String
    public let sourceFile: String
    public let line: Int
    public let layout: PreviewLayout
    public let variantCount: Int
    let renderVariant: @Sendable (Int, HTMLRenderer) -> String
    let renderAll: @Sendable (HTMLRenderer) -> String
}

/// Serves live previews for Sparrow components. Started by `sparrow preview`.
public struct PreviewServer: Sendable {
    let port: Int

    public init(port: Int = 5457) {
        self.port = port
    }

    public func run(previews: [any SparrowPreview.Type]) async throws {
        let infos = previews.map { buildPreviewInfo($0) }
        let state = PreviewState(previews: infos)

        let httpRouter = Router()

        // Preview chrome SPA
        httpRouter.get("/_preview/") { _, _ -> Response in
            let html = PreviewChrome.html(stylesheet: CSSGenerator.defaultStylesheet)
            return Response(
                status: .ok,
                headers: [.contentType: "text/html; charset=utf-8"],
                body: .init(byteBuffer: .init(string: html))
            )
        }

        // Also handle without trailing slash
        httpRouter.get("/_preview") { _, _ -> Response in
            Response(status: .movedPermanently, headers: [.location: "/_preview/"])
        }

        // List all files with previews
        let filesJSON = buildFilesJSON(infos)
        httpRouter.get("/_preview/files") { _, _ -> Response in
            Response(
                status: .ok,
                headers: [.contentType: "application/json"],
                body: .init(byteBuffer: .init(string: filesJSON))
            )
        }

        // Build-id for reconnect detection
        let pid = "\(ProcessInfo.processInfo.processIdentifier)"
        httpRouter.get("/_preview/build-id") { _, _ -> Response in
            Response(
                status: .ok,
                headers: [
                    .contentType: "text/plain",
                    .cacheControl: "no-cache, no-store",
                ],
                body: .init(byteBuffer: .init(string: pid))
            )
        }

        // Health check
        httpRouter.get("/health") { _, _ -> Response in
            Response(
                status: .ok,
                headers: [.contentType: "application/json"],
                body: .init(byteBuffer: .init(string: "{\"status\":\"ok\"}"))
            )
        }

        // WebSocket for preview interactivity
        let wsState = state
        let wsRouter = Router(context: BasicWebSocketRequestContext.self)
        wsRouter.ws("/_preview/ws") { _, _ in
            .upgrade([:])
        } onUpgrade: { inbound, outbound, _ in
            try await handlePreviewWebSocket(
                inbound: inbound,
                outbound: outbound,
                state: wsState
            )
        }

        let app = Application(
            router: httpRouter,
            server: .http1WebSocketUpgrade(webSocketRouter: wsRouter),
            configuration: .init(address: .hostname("127.0.0.1", port: port))
        )

        print("  Sparrow preview server running at http://127.0.0.1:\(port)/_preview/")
        try await app.runService()
    }
}

// MARK: - Preview info extraction

/// Opens the SparrowPreview existential to access its associated type.
private func buildPreviewInfo<P: SparrowPreview>(_ type: P.Type) -> PreviewInfo {
    let variants = flattenChildren(P.content)
    let variantCount = max(variants.count, 1)

    return PreviewInfo(
        id: previewId(filePath: P.sourceFile, line: P.line),
        name: P.name,
        sourceFile: P.sourceFile,
        line: P.line,
        layout: P.layout,
        variantCount: variantCount,
        renderVariant: { index, renderer in
            let views = flattenChildren(P.content)
            guard index < views.count else { return "" }
            return renderer.renderAnyErasedVNode(views[index], modifierContext: ModifierContext()).toHTML()
        },
        renderAll: { renderer in
            renderer.render(P.content)
        }
    )
}

/// Compute the preview ID hash (must match the macro's algorithm).
private func previewId(filePath: String, line: Int) -> String {
    let input = "\(filePath):\(line)"
    var hash: UInt64 = 5381
    for byte in input.utf8 {
        hash = ((hash &<< 5) &+ hash) &+ UInt64(byte)
    }
    return String(format: "%06x", hash & 0xFFFFFF)
}

// MARK: - JSON helpers

private func buildFilesJSON(_ infos: [PreviewInfo]) -> String {
    // Group by source file
    var fileMap: [(String, [PreviewInfo])] = []
    var seen: [String: Int] = [:]

    for info in infos {
        if let idx = seen[info.sourceFile] {
            fileMap[idx].1.append(info)
        } else {
            seen[info.sourceFile] = fileMap.count
            fileMap.append((info.sourceFile, [info]))
        }
    }

    var filesArray: [String] = []
    for (path, previews) in fileMap {
        let previewsJSON = previews.map { info in
            """
            {"id":"\(info.id)","name":"\(jsonEscapeSimple(info.name))","layout":"\(info.layout.rawValue)","line":\(info.line),"variants":\(info.variantCount)}
            """
        }.joined(separator: ",")
        filesArray.append("""
        {"path":"\(jsonEscapeSimple(path))","previews":[\(previewsJSON)]}
        """)
    }

    let activeFile = fileMap.first?.0 ?? ""
    return """
    {"files":[\(filesArray.joined(separator: ","))],"activeFile":"\(jsonEscapeSimple(activeFile))"}
    """
}

private func jsonEscapeSimple(_ s: String) -> String {
    s.replacingOccurrences(of: "\\", with: "\\\\")
        .replacingOccurrences(of: "\"", with: "\\\"")
        .replacingOccurrences(of: "\n", with: "\\n")
}

// MARK: - Preview session state

/// Tracks the active preview and per-variant SessionActors for a WebSocket connection.
private final class PreviewState: @unchecked Sendable {
    let previews: [PreviewInfo]
    var activePreviewIndex: Int = 0
    var variantSessions: [Int: SessionActor] = [:]

    init(previews: [PreviewInfo]) {
        self.previews = previews
    }

    var activePreview: PreviewInfo? {
        guard activePreviewIndex < previews.count else { return nil }
        return previews[activePreviewIndex]
    }

    func findPreviewIndex(byId id: String) -> Int? {
        previews.firstIndex(where: { $0.id == id })
    }

    func findPreviewIndex(byFile path: String) -> Int? {
        previews.firstIndex(where: { $0.sourceFile.hasSuffix(path) || path.hasSuffix($0.sourceFile) })
    }

    func createVariantSessions() {
        variantSessions.removeAll()
        guard let preview = activePreview else { return }
        for i in 0..<preview.variantCount {
            let variantIndex = i
            let renderVariant = preview.renderVariant
            variantSessions[i] = SessionActor(
                sessionId: "\(preview.id)-variant-\(i)",
                renderBody: { renderer in
                    renderVariant(variantIndex, renderer)
                }
            )
        }
    }
}

// MARK: - WebSocket handler

private func handlePreviewWebSocket(
    inbound: WebSocketInboundStream,
    outbound: WebSocketOutboundWriter,
    state: PreviewState
) async throws {
    // Initialize with first preview
    if !state.previews.isEmpty {
        state.createVariantSessions()
        let renderMsg = await buildRenderMessage(state: state)
        try await outbound.write(.text(renderMsg))
    }

    for try await message in inbound.messages(maxSize: 1 << 16) {
        guard case .text(let text) = message else { continue }
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let type = json["type"] as? String else { continue }

        switch type {
        case "preview:setFile":
            if let path = json["path"] as? String,
               let idx = state.findPreviewIndex(byFile: path) {
                state.activePreviewIndex = idx
                state.createVariantSessions()
                let renderMsg = await buildRenderMessage(state: state)
                try await outbound.write(.text(renderMsg))
            }

        case "preview:setPreview":
            if let id = json["id"] as? String,
               let idx = state.findPreviewIndex(byId: id) {
                state.activePreviewIndex = idx
                state.createVariantSessions()
                let renderMsg = await buildRenderMessage(state: state)
                try await outbound.write(.text(renderMsg))
            }

        case "event":
            guard let id = json["id"] as? String,
                  let event = json["event"] as? String else { continue }

            let variantIndex = (json["variant"] as? Int) ?? 0

            let value: String?
            if let s = json["value"] as? String { value = s }
            else if let b = json["value"] as? Bool { value = String(b) }
            else if let n = json["value"] as? NSNumber { value = n.stringValue }
            else { value = nil }

            if let session = state.variantSessions[variantIndex],
               let patches = await session.handleEvent(id: id, event: event, value: value) {
                let patchJSON = patches.map { $0.toJSON() }.joined(separator: ",")
                let response = "{\"type\":\"patch\",\"variant\":\(variantIndex),\"patches\":[\(patchJSON)]}"
                try await outbound.write(.text(response))
            }

        case "ping":
            try await outbound.write(.text("{\"type\":\"pong\"}"))

        default:
            break
        }
    }
}

private func buildRenderMessage(state: PreviewState) async -> String {
    guard let preview = state.activePreview else {
        return "{\"type\":\"preview:render\",\"preview\":null}"
    }

    var variantsJSON: [String] = []
    for i in 0..<preview.variantCount {
        let html: String
        if let session = state.variantSessions[i] {
            html = await session.getHTML()
        } else {
            html = ""
        }
        let escaped = jsonEscapeSimple(html)
        variantsJSON.append("{\"index\":\(i),\"html\":\"\(escaped)\"}")
    }

    let previewJSON = """
    {"id":"\(preview.id)","name":"\(jsonEscapeSimple(preview.name))","layout":"\(preview.layout.rawValue)","variants":[\(variantsJSON.joined(separator: ","))]}
    """

    return "{\"type\":\"preview:render\",\"file\":\"\(jsonEscapeSimple(preview.sourceFile))\",\"preview\":\(previewJSON)}"
}
