import Foundation

/// Key-value store for @State values within a session.
/// Each WebSocket connection gets its own instance. The `current` TaskLocal
/// is set during rendering so @State property wrappers can find their storage
/// without being passed a reference explicitly.
public final class StateStorage: @unchecked Sendable {
    private var values: [String: any Sendable] = [:]

    /// Set by `withAnimation()` before a state mutation. The renderer reads this
    /// during the next render cycle and clears it after producing patches.
    var pendingAnimation: SparrowAnimation?

    /// Set by SessionActor during render and event handling. @State reads/writes
    /// go through this to find the correct session's storage.
    @TaskLocal static var current: StateStorage?

    public init() {}

    func get<T: Sendable>(_ key: String, default defaultValue: T) -> T {
        (values[key] as? T) ?? defaultValue
    }

    func set<T: Sendable>(_ key: String, value: T) {
        values[key] = value
    }
}
