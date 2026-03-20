/// Server-side Swift syntax highlighter. Tokenizes Swift source code and wraps
/// tokens in `<span class="hl-*">` elements for CSS-based coloring.
enum SyntaxHighlighter {

    static func highlight(_ source: String) -> String {
        var result = ""
        var i = source.startIndex

        while i < source.endIndex {
            // Line comments
            if source[i] == "/" && source.index(after: i) < source.endIndex && source[source.index(after: i)] == "/" {
                let start = i
                while i < source.endIndex && source[i] != "\n" {
                    i = source.index(after: i)
                }
                result += span("comment", escapeHTML(String(source[start..<i])))
                continue
            }

            // Block comments
            if source[i] == "/" && source.index(after: i) < source.endIndex && source[source.index(after: i)] == "*" {
                let start = i
                i = source.index(i, offsetBy: 2)
                while i < source.endIndex {
                    if source[i] == "*" && source.index(after: i) < source.endIndex && source[source.index(after: i)] == "/" {
                        i = source.index(i, offsetBy: 2)
                        break
                    }
                    i = source.index(after: i)
                }
                result += span("comment", escapeHTML(String(source[start..<i])))
                continue
            }

            // Multiline strings
            if source[i] == "\"" && source.index(i, offsetBy: 2, limitedBy: source.endIndex) != nil
                && source[source.index(after: i)] == "\"" && source[source.index(i, offsetBy: 2)] == "\"" {
                let start = i
                i = source.index(i, offsetBy: 3)
                while i < source.endIndex {
                    if source[i] == "\"" && source.index(i, offsetBy: 2, limitedBy: source.endIndex) != nil
                        && source[source.index(after: i)] == "\"" && source[source.index(i, offsetBy: 2)] == "\"" {
                        i = source.index(i, offsetBy: 3)
                        break
                    }
                    if source[i] == "\\" && source.index(after: i) < source.endIndex {
                        i = source.index(i, offsetBy: 2)
                    } else {
                        i = source.index(after: i)
                    }
                }
                result += span("string", escapeHTML(String(source[start..<i])))
                continue
            }

            // Single-line strings
            if source[i] == "\"" {
                let start = i
                i = source.index(after: i)
                while i < source.endIndex && source[i] != "\"" && source[i] != "\n" {
                    if source[i] == "\\" && source.index(after: i) < source.endIndex {
                        i = source.index(i, offsetBy: 2)
                    } else {
                        i = source.index(after: i)
                    }
                }
                if i < source.endIndex && source[i] == "\"" {
                    i = source.index(after: i)
                }
                result += span("string", escapeHTML(String(source[start..<i])))
                continue
            }

            // Attributes (@Something)
            if source[i] == "@" {
                let start = i
                i = source.index(after: i)
                while i < source.endIndex && (source[i].isLetter || source[i].isNumber || source[i] == "_") {
                    i = source.index(after: i)
                }
                result += span("attr", escapeHTML(String(source[start..<i])))
                continue
            }

            // Numbers
            if source[i].isNumber || (source[i] == "." && i < source.endIndex && source.index(after: i) < source.endIndex && source[source.index(after: i)].isNumber) {
                let start = i
                while i < source.endIndex && (source[i].isNumber || source[i] == "." || source[i] == "_" || source[i] == "x" || source[i] == "X"
                    || (source[i] >= "a" && source[i] <= "f") || (source[i] >= "A" && source[i] <= "F")) {
                    i = source.index(after: i)
                }
                result += span("number", escapeHTML(String(source[start..<i])))
                continue
            }

            // Identifiers and keywords
            if source[i].isLetter || source[i] == "_" {
                let start = i
                while i < source.endIndex && (source[i].isLetter || source[i].isNumber || source[i] == "_") {
                    i = source.index(after: i)
                }
                let word = String(source[start..<i])
                if keywords.contains(word) {
                    result += span("keyword", escapeHTML(word))
                } else if word.first?.isUppercase == true {
                    result += span("type", escapeHTML(word))
                } else {
                    result += escapeHTML(word)
                }
                continue
            }

            // Everything else (whitespace, punctuation, operators)
            result += escapeHTML(String(source[i]))
            i = source.index(after: i)
        }

        return result
    }

    private static func span(_ cls: String, _ content: String) -> String {
        "<span class=\"hl-\(cls)\">\(content)</span>"
    }

    private static let keywords: Set<String> = [
        // Declarations
        "actor", "associatedtype", "class", "deinit", "enum", "extension",
        "func", "import", "init", "let", "macro", "operator", "precedencegroup",
        "protocol", "struct", "subscript", "typealias", "var",
        // Modifiers
        "fileprivate", "internal", "open", "package", "private", "public",
        "static", "final", "override", "mutating", "nonmutating", "nonisolated",
        "required", "convenience", "lazy", "weak", "unowned", "dynamic",
        // Statements
        "break", "case", "catch", "continue", "default", "defer", "do",
        "else", "fallthrough", "for", "guard", "if", "in", "repeat",
        "return", "switch", "throw", "where", "while",
        // Expressions
        "as", "any", "await", "async", "borrowing", "consuming", "each",
        "false", "is", "nil", "self", "Self", "some", "super", "throws",
        "true", "try", "inout", "sending",
    ]
}

private func escapeHTML(_ string: String) -> String {
    string
        .replacingOccurrences(of: "&", with: "&amp;")
        .replacingOccurrences(of: "<", with: "&lt;")
        .replacingOccurrences(of: ">", with: "&gt;")
        .replacingOccurrences(of: "\"", with: "&quot;")
}
