import Foundation

/// Thread-safe storage for @State values within a session.
/// Each WebSocket connection gets its own StateStorage instance.
public final class StateStorage: @unchecked Sendable {
    private var values: [String: any Sendable] = [:]

    @TaskLocal static var current: StateStorage?

    public init() {}

    func get<T: Sendable>(_ key: String, default defaultValue: T) -> T {
        (values[key] as? T) ?? defaultValue
    }

    func set<T: Sendable>(_ key: String, value: T) {
        values[key] = value
    }
}
