/// A multi-column data table.
/// On mobile: collapses to card layout or horizontal scroll.
/// On desktop: full multi-column table.
public struct DataTable: PrimitiveView, Sendable {
    public let columns: [TableColumn]
    public let rows: [[String]]

    public init(columns: [TableColumn], rows: [[String]]) {
        self.columns = columns
        self.rows = rows
    }
}

public struct TableColumn: Sendable {
    public let header: String
    public let key: String
    public let alignment: ColumnAlignment

    public init(
        _ header: String,
        key: String? = nil,
        alignment: ColumnAlignment = .leading
    ) {
        self.header = header
        self.key = key ?? header.lowercased()
        self.alignment = alignment
    }

    public enum ColumnAlignment: String, Sendable {
        case leading
        case center
        case trailing
    }
}
