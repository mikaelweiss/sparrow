import CoreServices
import Foundation

/// Watches a directory tree for `.swift` file changes using macOS FSEvents.
public final class FileWatcher {
    private var stream: FSEventStreamRef?
    private let path: String
    private let callback: () -> Void
    private let debounceInterval: TimeInterval

    private var debounceWorkItem: DispatchWorkItem?
    private let debounceQueue = DispatchQueue(label: "sparrow.filewatcher.debounce")

    public init(path: String, debounceInterval: TimeInterval = 0.2, callback: @escaping () -> Void) {
        self.path = path
        self.debounceInterval = debounceInterval
        self.callback = callback
    }

    deinit {
        stop()
    }

    public func start() {
        let pathsToWatch = [path] as CFArray

        var context = FSEventStreamContext()
        context.info = Unmanaged.passUnretained(self).toOpaque()

        let flags = UInt32(
            kFSEventStreamCreateFlagUseCFTypes
            | kFSEventStreamCreateFlagFileEvents
            | kFSEventStreamCreateFlagNoDefer
        )

        guard let stream = FSEventStreamCreate(
            nil,
            fileWatcherCallback,
            &context,
            pathsToWatch,
            FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
            0.1, // latency in seconds
            flags
        ) else {
            print("  Failed to create FSEvent stream")
            return
        }

        self.stream = stream
        FSEventStreamSetDispatchQueue(stream, DispatchQueue.main)
        FSEventStreamStart(stream)
    }

    public func stop() {
        if let stream = stream {
            FSEventStreamStop(stream)
            FSEventStreamInvalidate(stream)
            FSEventStreamRelease(stream)
            self.stream = nil
        }
    }

    /// Filters FSEvents to only trigger on .swift files outside .build/ and Migrations/.
    /// Uses debouncing so rapid successive saves collapse into a single rebuild.
    fileprivate func handleEvents(paths: [String]) {
        let dominated = paths.contains { path in
            let dominated = path.hasSuffix(".swift")
                && !path.contains("/.build/")
                && !path.contains("/Migrations/")
                && !path.hasPrefix(".")
            return dominated
        }

        guard dominated else { return }

        // Debounce: cancel previous, schedule new
        debounceWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in
            self?.callback()
        }
        debounceWorkItem = work
        debounceQueue.asyncAfter(deadline: .now() + debounceInterval, execute: work)
    }
}

private func fileWatcherCallback(
    _ streamRef: ConstFSEventStreamRef,
    _ clientCallBackInfo: UnsafeMutableRawPointer?,
    _ numEvents: Int,
    _ eventPaths: UnsafeMutableRawPointer,
    _ eventFlags: UnsafePointer<FSEventStreamEventFlags>,
    _ eventIds: UnsafePointer<FSEventStreamEventId>
) {
    guard let info = clientCallBackInfo else { return }
    let watcher = Unmanaged<FileWatcher>.fromOpaque(info).takeUnretainedValue()

    guard let cfPaths = unsafeBitCast(eventPaths, to: NSArray.self) as? [String] else { return }
    watcher.handleEvents(paths: cfPaths)
}
