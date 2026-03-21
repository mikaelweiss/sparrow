import Foundation

/// Represents a single DOM patch to send to the client.
struct Patch: Sendable {
    let op: String
    let target: String
    let html: String?
    let value: String?
    let attr: String?
    let beforeId: String?

    init(op: String, target: String, html: String? = nil, value: String? = nil, attr: String? = nil, beforeId: String? = nil) {
        self.op = op
        self.target = target
        self.html = html
        self.value = value
        self.attr = attr
        self.beforeId = beforeId
    }

    func toJSON() -> String {
        var parts = ["\"op\":\"\(op)\"", "\"target\":\"\(target)\""]
        if let html { parts.append("\"html\":\(jsonEscape(html))") }
        if let value { parts.append("\"value\":\(jsonEscape(value))") }
        if let attr { parts.append("\"attr\":\(jsonEscape(attr))") }
        if let beforeId { parts.append("\"beforeId\":\(jsonEscape(beforeId))") }
        return "{\(parts.joined(separator: ","))}"
    }
}

/// Per-WebSocket-connection actor that holds view state, event handlers,
/// and manages the render → diff → patch cycle.
///
/// Safety: StateStorage is @unchecked Sendable with no internal locking.
/// All access is serialized through this actor's isolation — do not expose
/// the stateStore reference outside of this actor.
actor SessionActor {
    let sessionId: String
    let stateStore: StateStorage
    private var renderBody: @Sendable (HTMLRenderer) -> String
    private var lastVNode: VNode
    private var lastHTML: String
    private var eventHandlers: [String: @Sendable () -> Void]
    private var valueHandlers: [String: @Sendable (String) -> Void]

    init(sessionId: String, renderBody: @escaping @Sendable (HTMLRenderer) -> String) {
        self.sessionId = sessionId
        self.stateStore = StateStorage()
        self.renderBody = renderBody
        self.lastVNode = .fragment([])
        self.lastHTML = ""
        self.eventHandlers = [:]
        self.valueHandlers = [:]

        let result = Self.doRender(renderBody: renderBody, stateStore: stateStore)
        self.lastVNode = result.vnode
        self.lastHTML = result.html
        self.eventHandlers = result.eventHandlers
        self.valueHandlers = result.valueHandlers
    }

    func getHTML() -> String {
        lastHTML
    }

    /// Navigate within the same layout — swap the render closure, re-render,
    /// and return just the content HTML for the client to inject into #sparrow-content.
    func navigateContent(
        newRenderBody: @escaping @Sendable (HTMLRenderer) -> String
    ) -> String {
        self.renderBody = newRenderBody

        let result = Self.doRender(renderBody: renderBody, stateStore: stateStore)
        self.lastVNode = result.vnode
        self.lastHTML = result.html
        self.eventHandlers = result.eventHandlers
        self.valueHandlers = result.valueHandlers

        return result.contentHTML
    }

    /// Handle a client event. Invokes the registered handler, re-renders,
    /// diffs the old and new VNode trees, and returns targeted patches.
    func handleEvent(id: String, event: String, value: String?) -> [Patch]? {
        switch event {
        case "click":
            guard let handler = eventHandlers[id] else { return nil }
            StateStorage.$current.withValue(stateStore) {
                handler()
            }

        case "input", "change", "rive", "lottie":
            guard let value, let handler = valueHandlers[id] else { return nil }
            StateStorage.$current.withValue(stateStore) {
                handler(value)
            }

        default:
            return nil
        }

        let result = Self.doRender(renderBody: renderBody, stateStore: stateStore)
        self.eventHandlers = result.eventHandlers
        self.valueHandlers = result.valueHandlers

        let patches = diffVNode(old: lastVNode, new: result.vnode, parentId: "sparrow-root")

        if !patches.isEmpty {
            self.lastVNode = result.vnode
            self.lastHTML = result.html
            return patches
        }
        return nil
    }

    /// Renders the view tree via the string render path, which internally builds
    /// a VNode tree (stored on renderState.rootVNode). Returns both outputs.
    private static func doRender(
        renderBody: @Sendable (HTMLRenderer) -> String,
        stateStore: StateStorage
    ) -> RenderResult {
        let renderer = HTMLRenderer()
        let html = StateStorage.$current.withValue(stateStore) {
            renderBody(renderer)
        }
        // HTMLRenderer.render() now builds a VNode tree internally and stores it
        let vnode = renderer.renderState.rootVNode ?? .fragment([])
        return RenderResult(
            vnode: vnode,
            html: html,
            contentHTML: renderer.renderState.contentSlot ?? html,
            eventHandlers: renderer.renderState.eventHandlers,
            valueHandlers: renderer.renderState.valueHandlers
        )
    }
}

private struct RenderResult {
    let vnode: VNode
    let html: String
    let contentHTML: String
    let eventHandlers: [String: @Sendable () -> Void]
    let valueHandlers: [String: @Sendable (String) -> Void]
}

// MARK: - JSON helpers

func jsonEscape(_ string: String) -> String {
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
