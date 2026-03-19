/// Mutable state accumulated during a single render pass.
/// A fresh instance is created per render (see HTMLRenderer.init). IDs are
/// sequential ("v0", "v1", ...) and deterministic — same view tree produces
/// same IDs, which is how the client maps DOM elements to server handlers.
final class RenderState: @unchecked Sendable {
    private(set) var nextId: Int = 0
    private(set) var eventHandlers: [String: @Sendable () -> Void] = [:]
    private(set) var valueHandlers: [String: @Sendable (String) -> Void] = [:]

    func allocateId() -> String {
        defer { nextId += 1 }
        return "v\(nextId)"
    }

    func registerHandler(id: String, handler: @escaping @Sendable () -> Void) {
        eventHandlers[id] = handler
    }

    func registerValueHandler(id: String, handler: @escaping @Sendable (String) -> Void) {
        valueHandlers[id] = handler
    }
}
