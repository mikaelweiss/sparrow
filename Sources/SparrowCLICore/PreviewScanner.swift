import Foundation

/// A discovered `#Preview` invocation in the project source.
public struct PreviewEntry: Sendable {
    public let filePath: String      // relative path from project root
    public let absolutePath: String  // absolute path
    public let line: Int
    public let hashId: String        // 6-char hex from djb2
    public let name: String?         // extracted from string literal, if parseable
    public let layout: String        // "component" or "fullPage"
    public let closureBody: String   // extracted Swift code inside the trailing closure
}

/// Scans project source files for `#Preview` invocations.
public struct PreviewScanner {
    let projectRoot: String

    public init(projectRoot: String) {
        self.projectRoot = projectRoot
    }

    /// Scan all .swift files and return discovered preview entries.
    public func scan() -> [PreviewEntry] {
        let fm = FileManager.default
        var entries: [PreviewEntry] = []

        guard let enumerator = fm.enumerator(atPath: projectRoot) else { return [] }

        while let relativePath = enumerator.nextObject() as? String {
            guard relativePath.hasSuffix(".swift"),
                  !relativePath.contains(".build/"),
                  !relativePath.contains(".sparrow/"),
                  !relativePath.contains("Migrations/") else { continue }

            let absolutePath = projectRoot + "/" + relativePath
            guard let contents = try? String(contentsOfFile: absolutePath, encoding: .utf8) else { continue }

            let lines = contents.components(separatedBy: "\n")
            for (index, lineContent) in lines.enumerated() {
                // Look for #Preview at the start of a line (allowing whitespace)
                let trimmed = lineContent.trimmingCharacters(in: .whitespaces)
                guard trimmed.hasPrefix("#Preview") else { continue }

                let lineNumber = index + 1

                // Extract name (first string literal argument)
                let name = extractName(from: trimmed)

                // Extract layout
                let layout = trimmed.contains(".fullPage") ? "fullPage" : "component"

                // Extract the trailing closure body via brace matching
                let closureBody = extractClosureBody(lines: lines, startIndex: index)

                // Compute hash — uses absolute path to match macro's #filePath
                let hashId = previewHashId(filePath: absolutePath, line: lineNumber)

                entries.append(PreviewEntry(
                    filePath: relativePath,
                    absolutePath: absolutePath,
                    line: lineNumber,
                    hashId: hashId,
                    name: name,
                    layout: layout,
                    closureBody: closureBody
                ))
            }
        }

        return entries
    }

    /// Extract the body of the trailing closure starting from the line with `#Preview`.
    /// Uses brace matching to find the opening `{` and its corresponding `}`.
    private func extractClosureBody(lines: [String], startIndex: Int) -> String {
        // Find the opening brace of the trailing closure
        var braceDepth = 0
        var foundOpen = false
        var bodyLines: [String] = []

        for i in startIndex..<lines.count {
            let line = lines[i]
            for char in line {
                if char == "{" {
                    if foundOpen {
                        braceDepth += 1
                    } else {
                        foundOpen = true
                        braceDepth = 1
                    }
                } else if char == "}" && foundOpen {
                    braceDepth -= 1
                    if braceDepth == 0 {
                        // We've found the matching close brace
                        return bodyLines.joined(separator: "\n")
                    }
                }
            }
            // Collect lines inside the closure (after the opening brace line)
            if foundOpen && braceDepth > 0 && i > startIndex {
                bodyLines.append(line)
            } else if foundOpen && braceDepth > 0 && i == startIndex {
                // The opening brace is on the #Preview line — capture anything after it
                if let braceIndex = line.firstIndex(of: "{") {
                    let afterBrace = String(line[line.index(after: braceIndex)...]).trimmingCharacters(in: .whitespaces)
                    if !afterBrace.isEmpty {
                        bodyLines.append(afterBrace)
                    }
                }
            }
        }

        return bodyLines.joined(separator: "\n")
    }

    private func extractName(from line: String) -> String? {
        // Match #Preview("Name" or #Preview("Name",
        guard let openParen = line.firstIndex(of: "("),
              let firstQuote = line[openParen...].firstIndex(of: "\"") else { return nil }

        let afterQuote = line.index(after: firstQuote)
        guard let closingQuote = line[afterQuote...].firstIndex(of: "\"") else { return nil }

        return String(line[afterQuote..<closingQuote])
    }
}

/// Computes a stable 6-char hex hash using the djb2 algorithm.
/// MUST match the implementation in SparrowMacros/PreviewMacro.swift.
public func previewHashId(filePath: String, line: Int) -> String {
    let input = "\(filePath):\(line)"
    var hash: UInt64 = 5381
    for byte in input.utf8 {
        hash = ((hash &<< 5) &+ hash) &+ UInt64(byte)
    }
    return String(format: "%06x", hash & 0xFFFFFF)
}
