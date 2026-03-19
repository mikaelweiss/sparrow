import Foundation

/// Represents a single DOM patch to send to the client.
struct Patch: Sendable {
    let op: String
    let target: String
    let html: String?
    let value: String?

    func toJSON() -> String {
        var parts = ["\"op\":\"\(op)\"", "\"target\":\"\(target)\""]
        if let html {
            parts.append("\"html\":\(jsonEscape(html))")
        }
        if let value {
            parts.append("\"value\":\(jsonEscape(value))")
        }
        return "{\(parts.joined(separator: ","))}"
    }
}

/// Per-WebSocket-connection actor that holds view state, event handlers,
/// and manages the render → diff → patch cycle.
actor SessionActor {
    let sessionId: String
    let stateStore: StateStorage
    private let renderBody: @Sendable (HTMLRenderer) -> String
    private var lastHTML: String
    private var eventHandlers: [String: @Sendable () -> Void]
    private var valueHandlers: [String: @Sendable (String) -> Void]

    init(sessionId: String, renderBody: @escaping @Sendable (HTMLRenderer) -> String) {
        self.sessionId = sessionId
        self.stateStore = StateStorage()
        self.renderBody = renderBody
        self.lastHTML = ""
        self.eventHandlers = [:]
        self.valueHandlers = [:]

        // Initial render to populate lastHTML and handlers
        let result = Self.doRender(renderBody: renderBody, stateStore: stateStore)
        self.lastHTML = result.html
        self.eventHandlers = result.eventHandlers
        self.valueHandlers = result.valueHandlers
    }

    /// Returns the current rendered HTML (for initial page sync).
    func getHTML() -> String {
        lastHTML
    }

    /// Handle a client event. Invokes the registered handler, re-renders, and
    /// returns a full-root replace patch if the HTML changed, nil otherwise.
    /// Currently always diffs at the root level — no fine-grained patching yet.
    func handleEvent(id: String, event: String, value: String?) -> [Patch]? {
        switch event {
        case "click":
            guard let handler = eventHandlers[id] else { return nil }
            StateStorage.$current.withValue(stateStore) {
                handler()
            }

        case "input", "change":
            guard let value, let handler = valueHandlers[id] else { return nil }
            StateStorage.$current.withValue(stateStore) {
                handler(value)
            }

        default:
            return nil
        }

        // Re-render with updated state
        let result = Self.doRender(renderBody: renderBody, stateStore: stateStore)
        self.eventHandlers = result.eventHandlers
        self.valueHandlers = result.valueHandlers

        if result.html != lastHTML {
            self.lastHTML = result.html
            return [Patch(op: "replace", target: "#sparrow-root", html: result.html, value: nil)]
        }
        return nil
    }

    /// Static so it can be called from `init` before `self` is fully initialized.
    /// Runs the render closure inside a `StateStorage.$current.withValue` scope
    /// so that @State property wrappers resolve against this session's storage.
    private static func doRender(
        renderBody: @Sendable (HTMLRenderer) -> String,
        stateStore: StateStorage
    ) -> RenderResult {
        let renderer = HTMLRenderer()
        let html = StateStorage.$current.withValue(stateStore) {
            renderBody(renderer)
        }
        return RenderResult(
            html: html,
            eventHandlers: renderer.renderState.eventHandlers,
            valueHandlers: renderer.renderState.valueHandlers
        )
    }
}

private struct RenderResult {
    let html: String
    let eventHandlers: [String: @Sendable () -> Void]
    let valueHandlers: [String: @Sendable (String) -> Void]
}

// MARK: - JSON helpers

private func jsonEscape(_ string: String) -> String {
    var result = "\""
    for char in string {
        switch char {
        case "\"": result += "\\\""
        case "\\": result += "\\\\"
        case "\n": result += "\\n"
        case "\r": result += "\\r"
        case "\t": result += "\\t"
        default: result.append(char)
        }
    }
    result += "\""
    return result
}
