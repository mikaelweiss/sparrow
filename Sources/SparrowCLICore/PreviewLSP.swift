import Foundation

/// Minimal LSP server that keeps Zed happy while the preview server runs.
/// Responds to initialize/shutdown/exit and forwards textDocument/didOpen
/// to the preview server so it can switch the active file.
public final class PreviewLSPHandler {
    private let previewPort: Int
    private var shouldExit = false

    public init(previewPort: Int) {
        self.previewPort = previewPort
    }

    /// Run the LSP read loop on the current thread. Blocks until exit.
    public func run() {
        while !shouldExit {
            guard let message = readMessage() else {
                // stdin closed — Zed terminated us
                break
            }

            guard let data = message.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                continue
            }

            let method = json["method"] as? String
            let id = json["id"] // request id (Int or String)

            switch method {
            case "initialize":
                let result: [String: Any] = [
                    "capabilities": [
                        "textDocumentSync": 1, // TextDocumentSyncKind.Full
                    ],
                    "serverInfo": [
                        "name": "sparrow-preview",
                        "version": "0.1.0",
                    ],
                ]
                sendResponse(id: id, result: result)

            case "initialized":
                // Notification, no response needed
                break

            case "shutdown":
                sendResponse(id: id, result: NSNull())
                shouldExit = true

            case "exit":
                shouldExit = true

            case "textDocument/didOpen":
                if let params = json["params"] as? [String: Any],
                   let textDocument = params["textDocument"] as? [String: Any],
                   let uri = textDocument["uri"] as? String {
                    notifyActiveFile(uri: uri)
                }

            case "textDocument/didSave":
                // The file watcher handles rebuilds. Just update active file.
                if let params = json["params"] as? [String: Any],
                   let textDocument = params["textDocument"] as? [String: Any],
                   let uri = textDocument["uri"] as? String {
                    notifyActiveFile(uri: uri)
                }

            default:
                // Unknown method — if it has an id, it's a request; respond with method not found
                if let id {
                    sendError(id: id, code: -32601, message: "Method not found")
                }
            }
        }
    }

    // MARK: - LSP I/O

    /// Read a single LSP message from stdin (Content-Length header + JSON body).
    private func readMessage() -> String? {
        // Read headers until empty line
        var contentLength = 0
        while let headerLine = readLine(strippingNewline: true) {
            if headerLine.isEmpty { break }
            if headerLine.lowercased().hasPrefix("content-length:") {
                let value = headerLine.dropFirst("content-length:".count).trimmingCharacters(in: .whitespaces)
                contentLength = Int(value) ?? 0
            }
        }

        guard contentLength > 0 else { return nil }

        // Read exactly contentLength bytes
        var body = Data()
        while body.count < contentLength {
            let remaining = contentLength - body.count
            var buffer = [UInt8](repeating: 0, count: remaining)
            let bytesRead = fread(&buffer, 1, remaining, stdin)
            if bytesRead <= 0 { return nil }
            body.append(contentsOf: buffer[0..<bytesRead])
        }

        return String(data: body, encoding: .utf8)
    }

    /// Write an LSP response message to stdout.
    private func sendResponse(id: Any?, result: Any) {
        var response: [String: Any] = [
            "jsonrpc": "2.0",
            "result": result,
        ]
        if let id = id as? Int {
            response["id"] = id
        } else if let id = id as? String {
            response["id"] = id
        }
        writeMessage(response)
    }

    /// Write an LSP error response to stdout.
    private func sendError(id: Any?, code: Int, message: String) {
        var response: [String: Any] = [
            "jsonrpc": "2.0",
            "error": ["code": code, "message": message],
        ]
        if let id = id as? Int {
            response["id"] = id
        } else if let id = id as? String {
            response["id"] = id
        }
        writeMessage(response)
    }

    /// Encode and write a JSON-RPC message with Content-Length header.
    private func writeMessage(_ json: [String: Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: json),
              let body = String(data: data, encoding: .utf8) else { return }
        let header = "Content-Length: \(body.utf8.count)\r\n\r\n"
        FileHandle.standardOutput.write(Data(header.utf8))
        FileHandle.standardOutput.write(Data(body.utf8))
    }

    // MARK: - Preview server communication

    /// Notify the preview server about the active file via HTTP.
    private func notifyActiveFile(uri: String) {
        // Convert file:// URI to relative path
        guard uri.hasPrefix("file://") else { return }
        let path = String(uri.dropFirst("file://".count))
            .removingPercentEncoding ?? uri

        // Fire-and-forget HTTP request to switch active file
        guard let url = URL(string: "http://127.0.0.1:\(previewPort)/_preview/active?file=\(path)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 1
        URLSession.shared.dataTask(with: request).resume()
    }
}
