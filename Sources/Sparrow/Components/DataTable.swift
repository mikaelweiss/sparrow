/// Protocol for type-erased DataTable rendering.
protocol _DataTableRenderable {
    func renderDataTableVNode(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> VNode
}

/// Data table with sorting/filtering/pagination matching ShadCN DataTable.
/// Composes Table + Pagination with column definitions.
public struct DataTable<Row: Sendable>: PrimitiveView, Sendable {
    public let columns: [DataTableColumn<Row>]
    public let rows: [Row]
    public let currentPage: Int
    public let pageSize: Int
    public let totalPages: Int
    public let sortColumn: String?
    public let sortAscending: Bool
    public let onSort: @Sendable (String) -> Void
    public let onPageChange: @Sendable (Int) -> Void

    public init(
        columns: [DataTableColumn<Row>],
        rows: [Row],
        currentPage: Int = 1,
        pageSize: Int = 10,
        totalPages: Int = 1,
        sortColumn: String? = nil,
        sortAscending: Bool = true,
        onSort: @escaping @Sendable (String) -> Void,
        onPageChange: @escaping @Sendable (Int) -> Void
    ) {
        self.columns = columns
        self.rows = rows
        self.currentPage = currentPage
        self.pageSize = pageSize
        self.totalPages = totalPages
        self.sortColumn = sortColumn
        self.sortAscending = sortAscending
        self.onSort = onSort
        self.onPageChange = onPageChange
    }
}

public struct DataTableColumn<Row: Sendable>: Sendable {
    public let id: String
    public let header: String
    public let accessor: @Sendable (Row) -> String
    public let sortable: Bool

    public init(id: String, header: String, sortable: Bool = false, accessor: @escaping @Sendable (Row) -> String) {
        self.id = id
        self.header = header
        self.sortable = sortable
        self.accessor = accessor
    }
}

extension DataTable: _DataTableRenderable {
    func renderDataTableVNode(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> VNode {
        let id = renderer.resolveId(context: modifierContext)
        // Header
        var headerCells: [VNode] = []
        for col in columns {
            let thId = renderer.renderState.allocateId()
            let isSorted = sortColumn == col.id
            let arrow = isSorted ? (sortAscending ? " \u{2191}" : " \u{2193}") : ""
            let thChildren: [VNode] = [.text(escapeHTML(col.header + arrow))]
            var attrs: [(key: String, value: String)] = []
            if col.sortable {
                let colId = col.id
                renderer.renderState.registerHandler(id: thId) { [onSort] in onSort(colId) }
                attrs.append(("data-sparrow-event", "click"))
            }
            let th = ElementNode.build(tag: "th", id: thId, classes: ["table-head"], extraAttrs: attrs, children: thChildren)
            headerCells.append(.element(th))
        }
        let headerRowId = renderer.renderState.allocateId()
        let headerRow = ElementNode.build(tag: "tr", id: headerRowId, classes: ["table-row"], children: headerCells)
        let theadId = renderer.renderState.allocateId()
        let thead = ElementNode.build(tag: "thead", id: theadId, children: [.element(headerRow)])
        // Body
        var bodyRows: [VNode] = []
        for row in rows {
            let trId = renderer.renderState.allocateId()
            var cells: [VNode] = []
            for col in columns {
                let tdId = renderer.renderState.allocateId()
                let td = ElementNode.build(tag: "td", id: tdId, classes: ["table-cell"], children: [.text(escapeHTML(col.accessor(row)))])
                cells.append(.element(td))
            }
            let tr = ElementNode.build(tag: "tr", id: trId, classes: ["table-row"], children: cells)
            bodyRows.append(.element(tr))
        }
        let tbodyId = renderer.renderState.allocateId()
        let tbody = ElementNode.build(tag: "tbody", id: tbodyId, children: bodyRows)
        let tableId = renderer.renderState.allocateId()
        let table = ElementNode.build(tag: "table", id: tableId, classes: ["table"], children: [.element(thead), .element(tbody)])
        let wrapperId = renderer.renderState.allocateId()
        let wrapper = ElementNode.build(tag: "div", id: wrapperId, classes: ["table-wrapper"], children: [.element(table)])
        var allChildren: [VNode] = [.element(wrapper)]

        // Pagination
        if totalPages > 1 {
            let pagId = renderer.renderState.allocateId()
            var pagChildren: [VNode] = []
            if currentPage > 1 {
                let prevId = renderer.renderState.allocateId()
                let prevPage = currentPage - 1
                renderer.renderState.registerHandler(id: prevId) { [onPageChange] in onPageChange(prevPage) }
                pagChildren.append(.element(ElementNode.build(tag: "button", id: prevId, classes: ["pagination-item"], extraAttrs: [("data-sparrow-event", "click")], children: [.text("\u{2039}")])))
            }
            for page in 1...totalPages {
                let pageId = renderer.renderState.allocateId()
                let p = page
                renderer.renderState.registerHandler(id: pageId) { [onPageChange] in onPageChange(p) }
                var cls = ["pagination-item"]
                if page == currentPage { cls.append("pagination-item-active") }
                pagChildren.append(.element(ElementNode.build(tag: "button", id: pageId, classes: cls, extraAttrs: [("data-sparrow-event", "click")], children: [.text("\(page)")])))
            }
            if currentPage < totalPages {
                let nextId = renderer.renderState.allocateId()
                let nextPage = currentPage + 1
                renderer.renderState.registerHandler(id: nextId) { [onPageChange] in onPageChange(nextPage) }
                pagChildren.append(.element(ElementNode.build(tag: "button", id: nextId, classes: ["pagination-item"], extraAttrs: [("data-sparrow-event", "click")], children: [.text("\u{203A}")])))
            }
            let pag = ElementNode.build(tag: "nav", id: pagId, classes: ["pagination"], extraAttrs: [("aria-label", "pagination")], children: pagChildren)
            allChildren.append(.element(pag))
        }

        let classes = ["data-table"] + modifierContext.cssClasses
        let el = ElementNode.build(tag: "div", id: id, classes: classes, styles: modifierContext.inlineStyles, extraAttrs: modifierContext.allExtraAttributePairs, children: allChildren)
        return .element(el)
    }
}
