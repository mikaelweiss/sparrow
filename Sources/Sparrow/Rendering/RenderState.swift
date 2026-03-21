/// Mutable state accumulated during a single render pass.
/// A fresh instance is created per render (see HTMLRenderer.init). IDs are
/// sequential and deterministic — same view tree produces same IDs, which is
/// how the client maps DOM elements to server handlers.
///
/// ID prefixes: routes without a layout use "v" (v0, v1, ...). Routes with a
/// layout use "c" for content elements and "l" for layout elements. This keeps
/// layout IDs stable when navigating between pages in the same layout group.
final class RenderState: @unchecked Sendable {
    private var counters: [String: Int] = [:]
    private(set) var eventHandlers: [String: @Sendable () -> Void] = [:]
    private(set) var valueHandlers: [String: @Sendable (String) -> Void] = [:]
    /// Current ID prefix — "v" (no layout), "c" (content), or "l" (layout).
    var idPrefix: String = "v"
    /// Pre-rendered page HTML injected at `Content()` inside a Layout.
    var contentSlot: String? = nil

    func allocateId() -> String {
        let count = counters[idPrefix, default: 0]
        counters[idPrefix] = count + 1
        return "\(idPrefix)\(count)"
    }

    func registerHandler(id: String, handler: @escaping @Sendable () -> Void) {
        eventHandlers[id] = handler
    }

    func registerValueHandler(id: String, handler: @escaping @Sendable (String) -> Void) {
        valueHandlers[id] = handler
    }
}
