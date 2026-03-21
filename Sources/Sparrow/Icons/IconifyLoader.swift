import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Downloads and caches Iconify icon set data at runtime.
/// Used for non-bundled icon sets (anything other than Lucide).
public struct IconifyLoader {

    /// Load an icon registry for the given Iconify prefix.
    /// Checks disk cache first, then downloads from the Iconify CDN.
    public static func load(prefix: String) async throws -> any IconRegistry {
        // Check disk cache
        let cacheDir = cacheDirectory()
        let cachePath = cacheDir.appendingPathComponent("\(prefix).json")

        if let cached = try? Data(contentsOf: cachePath),
           let registry = parse(json: cached, prefix: prefix) {
            return registry
        }

        // Download from unpkg (Iconify JSON format)
        let url = URL(string: "https://unpkg.com/@iconify-json/\(prefix)/icons.json")!
        print("  Downloading \(prefix) icons...")
        let (data, response) = try await URLSession.shared.data(from: url)

        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            throw IconifyError.downloadFailed(prefix: prefix, status: http.statusCode)
        }

        guard let registry = parse(json: data, prefix: prefix) else {
            throw IconifyError.parseFailed(prefix: prefix)
        }

        // Cache to disk
        try? FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
        try? data.write(to: cachePath)

        return registry
    }

    private static func parse(json data: Data, prefix: String) -> DynamicIconRegistry? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let icons = json["icons"] as? [String: [String: Any]] else {
            return nil
        }

        let defaultWidth = json["width"] as? Int ?? 24
        let defaultHeight = json["height"] as? Int ?? 24

        var svgMap: [String: String] = [:]
        var sizeMap: [String: (Int, Int)] = [:]

        for (name, info) in icons {
            guard let body = info["body"] as? String else { continue }
            svgMap[name] = body

            let w = info["width"] as? Int ?? defaultWidth
            let h = info["height"] as? Int ?? defaultHeight
            if w != defaultWidth || h != defaultHeight {
                sizeMap[name] = (w, h)
            }
        }

        return DynamicIconRegistry(
            icons: svgMap,
            sizes: sizeMap,
            defaultWidth: defaultWidth,
            defaultHeight: defaultHeight
        )
    }

    private static func cacheDirectory() -> URL {
        URL(fileURLWithPath: ".sparrow/cache/icons")
    }
}

/// A runtime-loaded icon registry parsed from Iconify JSON.
struct DynamicIconRegistry: IconRegistry, Sendable {
    let icons: [String: String]
    let sizes: [String: (Int, Int)]
    let defaultWidth: Int
    let defaultHeight: Int

    func svg(for name: String) -> String? {
        icons[name]
    }

    func viewBox(for name: String) -> String? {
        guard icons[name] != nil else { return nil }
        if let (w, h) = sizes[name] {
            return "0 0 \(w) \(h)"
        }
        return "0 0 \(defaultWidth) \(defaultHeight)"
    }
}

enum IconifyError: Error, CustomStringConvertible {
    case downloadFailed(prefix: String, status: Int)
    case parseFailed(prefix: String)

    var description: String {
        switch self {
        case .downloadFailed(let prefix, let status):
            return "Failed to download icon set '\(prefix)' (HTTP \(status)). Check your internet connection."
        case .parseFailed(let prefix):
            return "Failed to parse icon set '\(prefix)'. The downloaded data may be corrupted."
        }
    }
}
