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

    init(sessionId: String, renderBody: @escaping @Sendable (HTMLRenderer) -> String) {
        self.sessionId = sessionId
        self.stateStore = StateStorage()
        self.renderBody = renderBody
        self.lastHTML = ""
        self.eventHandlers = [:]

        // Initial render to populate lastHTML and event handlers
        let (html, handlers) = Self.doRender(renderBody: renderBody, stateStore: stateStore)
        self.lastHTML = html
        self.eventHandlers = handlers
    }

    /// Returns the current rendered HTML (for initial page sync).
    func getHTML() -> String {
        lastHTML
    }

    /// Handle a client event. Returns patches if the DOM changed, nil otherwise.
    func handleEvent(id: String, event: String) -> [Patch]? {
        guard let handler = eventHandlers[id] else { return nil }

        // Execute the handler within the session's state context.
        // The handler may mutate @State values via the nonmutating setter.
        StateStorage.$current.withValue(stateStore) {
            handler()
        }

        // Re-render with updated state
        let (newHTML, newHandlers) = Self.doRender(renderBody: renderBody, stateStore: stateStore)
        self.eventHandlers = newHandlers

        if newHTML != lastHTML {
            self.lastHTML = newHTML
            return [Patch(op: "replace", target: "#sparrow-root", html: newHTML, value: nil)]
        }
        return nil
    }

    /// Pure render function: creates a renderer, renders within the state context,
    /// and returns the HTML + collected event handlers.
    private static func doRender(
        renderBody: @Sendable (HTMLRenderer) -> String,
        stateStore: StateStorage
    ) -> (String, [String: @Sendable () -> Void]) {
        let renderer = HTMLRenderer()
        let html = StateStorage.$current.withValue(stateStore) {
            renderBody(renderer)
        }
        return (html, renderer.renderState.eventHandlers)
    }
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
