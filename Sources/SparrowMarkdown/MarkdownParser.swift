import Markdown

/// Converts a Markdown string to an HTML string using swift-markdown.
/// Lives in its own target to avoid name collisions between the
/// `Markdown` module and Sparrow's `Markdown` view struct.
public enum MarkdownParser {
    public static func html(from markdown: String) -> String {
        let document = Document(parsing: markdown)
        var converter = HTMLConverter()
        return converter.visit(document)
    }
}

// MARK: - HTML Converter

private struct HTMLConverter: MarkupVisitor {
    typealias Result = String

    // MARK: - Block elements

    mutating func defaultVisit(_ markup: any Markup) -> String {
        markup.children.map { visit($0) }.joined()
    }

    mutating func visitDocument(_ document: Document) -> String {
        document.children.map { visit($0) }.joined()
    }

    mutating func visitParagraph(_ paragraph: Paragraph) -> String {
        "<p>\(paragraph.children.map { visit($0) }.joined())</p>"
    }

    mutating func visitHeading(_ heading: Heading) -> String {
        let tag = "h\(heading.level)"
        let id = slugify(heading.plainText)
        return "<\(tag) id=\"\(id)\">\(heading.children.map { visit($0) }.joined())</\(tag)>"
    }

    mutating func visitBlockQuote(_ blockQuote: BlockQuote) -> String {
        "<blockquote>\(blockQuote.children.map { visit($0) }.joined())</blockquote>"
    }

    mutating func visitCodeBlock(_ codeBlock: CodeBlock) -> String {
        let lang = codeBlock.language ?? ""
        let langAttr = lang.isEmpty ? "" : " class=\"language-\(escapeAttr(lang))\""
        let code = escapeHTML(codeBlock.code)
        return "<pre><code\(langAttr)>\(code)</code></pre>"
    }

    mutating func visitThematicBreak(_ thematicBreak: ThematicBreak) -> String {
        "<hr>"
    }

    // MARK: - List elements

    mutating func visitUnorderedList(_ unorderedList: UnorderedList) -> String {
        "<ul>\(unorderedList.children.map { visit($0) }.joined())</ul>"
    }

    mutating func visitOrderedList(_ orderedList: OrderedList) -> String {
        "<ol>\(orderedList.children.map { visit($0) }.joined())</ol>"
    }

    mutating func visitListItem(_ listItem: ListItem) -> String {
        "<li>\(listItem.children.map { visit($0) }.joined())</li>"
    }

    // MARK: - Inline elements

    mutating func visitText(_ text: Markdown.Text) -> String {
        escapeHTML(text.string)
    }

    mutating func visitStrong(_ strong: Strong) -> String {
        "<strong>\(strong.children.map { visit($0) }.joined())</strong>"
    }

    mutating func visitEmphasis(_ emphasis: Emphasis) -> String {
        "<em>\(emphasis.children.map { visit($0) }.joined())</em>"
    }

    mutating func visitInlineCode(_ inlineCode: InlineCode) -> String {
        "<code>\(escapeHTML(inlineCode.code))</code>"
    }

    mutating func visitLink(_ link: Markdown.Link) -> String {
        let href = escapeAttr(link.destination ?? "")
        return "<a href=\"\(href)\">\(link.children.map { visit($0) }.joined())</a>"
    }

    mutating func visitImage(_ image: Markdown.Image) -> String {
        let src = escapeAttr(image.source ?? "")
        let alt = escapeAttr(image.plainText)
        return "<img src=\"\(src)\" alt=\"\(alt)\">"
    }

    mutating func visitSoftBreak(_ softBreak: SoftBreak) -> String {
        "\n"
    }

    mutating func visitLineBreak(_ lineBreak: LineBreak) -> String {
        "<br>"
    }

    mutating func visitStrikethrough(_ strikethrough: Strikethrough) -> String {
        "<s>\(strikethrough.children.map { visit($0) }.joined())</s>"
    }

    // MARK: - Table elements

    mutating func visitTable(_ table: Markdown.Table) -> String {
        "<table>\(table.children.map { visit($0) }.joined())</table>"
    }

    mutating func visitTableHead(_ tableHead: Markdown.Table.Head) -> String {
        "<thead><tr>\(tableHead.children.map { visit($0) }.joined())</tr></thead>"
    }

    mutating func visitTableBody(_ tableBody: Markdown.Table.Body) -> String {
        "<tbody>\(tableBody.children.map { visit($0) }.joined())</tbody>"
    }

    mutating func visitTableRow(_ tableRow: Markdown.Table.Row) -> String {
        "<tr>\(tableRow.children.map { visit($0) }.joined())</tr>"
    }

    mutating func visitTableCell(_ tableCell: Markdown.Table.Cell) -> String {
        let tag = tableCell.parent is Markdown.Table.Head ? "th" : "td"
        return "<\(tag)>\(tableCell.children.map { visit($0) }.joined())</\(tag)>"
    }
}

// MARK: - Helpers

private func escapeHTML(_ string: String) -> String {
    string
        .replacingOccurrences(of: "&", with: "&amp;")
        .replacingOccurrences(of: "<", with: "&lt;")
        .replacingOccurrences(of: ">", with: "&gt;")
        .replacingOccurrences(of: "\"", with: "&quot;")
}

private func escapeAttr(_ string: String) -> String {
    escapeHTML(string)
}

private func slugify(_ text: String) -> String {
    text.lowercased()
        .replacingOccurrences(of: " ", with: "-")
        .filter { $0.isLetter || $0.isNumber || $0 == "-" }
}
