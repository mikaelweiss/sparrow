/// Mutable state accumulated during a single render pass.
/// Allocates stable element IDs and collects event handlers for interactive elements.
final class RenderState: @unchecked Sendable {
    private(set) var nextId: Int = 0
    private(set) var eventHandlers: [String: @Sendable () -> Void] = [:]

    func allocateId() -> String {
        defer { nextId += 1 }
        return "v\(nextId)"
    }

    func registerHandler(id: String, handler: @escaping @Sendable () -> Void) {
        eventHandlers[id] = handler
    }
}
