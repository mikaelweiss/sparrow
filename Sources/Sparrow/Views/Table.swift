/// A data table container. Renders to `<div class="table-wrapper"><table>`.
public struct Table<Content: View>: View {
    public typealias Body = Never
    let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Never { fatalError("Table should not have body called") }
}

extension Table: Sendable where Content: Sendable {}

/// Table header section. Renders to `<thead>`.
public struct TableHeader<Content: View>: View {
    public typealias Body = Never
    let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Never { fatalError("TableHeader should not have body called") }
}

extension TableHeader: Sendable where Content: Sendable {}

/// Table body section. Renders to `<tbody>`.
public struct TableBody<Content: View>: View {
    public typealias Body = Never
    let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Never { fatalError("TableBody should not have body called") }
}

extension TableBody: Sendable where Content: Sendable {}

/// Table footer section. Renders to `<tfoot>`.
public struct TableFooter<Content: View>: View {
    public typealias Body = Never
    let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Never { fatalError("TableFooter should not have body called") }
}

extension TableFooter: Sendable where Content: Sendable {}

/// A table row. Renders to `<tr>`.
public struct TableRow<Content: View>: View {
    public typealias Body = Never
    let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Never { fatalError("TableRow should not have body called") }
}

extension TableRow: Sendable where Content: Sendable {}

/// A table data cell. Renders to `<td>`.
public struct TableCell<Content: View>: View {
    public typealias Body = Never
    let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Never { fatalError("TableCell should not have body called") }
}

extension TableCell: Sendable where Content: Sendable {}

/// A table header cell. Renders to `<th>`.
public struct TableHead: PrimitiveView, Sendable {
    let text: String

    public init(_ text: String) {
        self.text = text
    }
}

/// A table caption. Renders to `<caption>`.
public struct TableCaption: PrimitiveView, Sendable {
    let text: String

    public init(_ text: String) {
        self.text = text
    }
}
