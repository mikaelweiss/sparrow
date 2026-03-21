/// Pagination component matching ShadCN Pagination.
public struct Pagination: PrimitiveView, Sendable {
    public let currentPage: Int
    public let totalPages: Int
    public let onPageChange: @Sendable (Int) -> Void

    public init(currentPage: Int, totalPages: Int, onPageChange: @escaping @Sendable (Int) -> Void) {
        self.currentPage = currentPage
        self.totalPages = totalPages
        self.onPageChange = onPageChange
    }
}
